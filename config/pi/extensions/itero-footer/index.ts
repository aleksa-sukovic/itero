import { type ExtensionAPI, type ExtensionContext, type Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const FOOTER_HEIGHT = 1;
const usage_event = "itero:provider-usage";

type TokenTotals = {
    input: number;
    output: number;
    cache_read: number;
    cache_write: number;
    latest_cache_hit?: number;
};

type TokenUsage = {
    input?: number;
    output?: number;
    cacheRead?: number;
    cacheWrite?: number;
};

type UsageEvent = {
    provider?: string;
    text?: string;
};

export default function (pi: ExtensionAPI) {
    let usage: UsageEvent | undefined;
    let request_render: (() => void) | undefined;
    const remove_usage_listener = pi.events.on(usage_event, (event) => {
        usage = is_usage_event(event) ? event : undefined;
        request_render?.();
    });

    pi.on("session_start", (_event, ctx) => {
        if (ctx.mode !== "tui") return;

        ctx.ui.setFooter((tui, theme, footer_data) => {
            const unsubscribe = footer_data.onBranchChange(() => tui.requestRender());
            request_render = () => tui.requestRender();
            const footer_component = {
                dispose() {
                    unsubscribe();
                    request_render = undefined;
                },
                invalidate() {},
                render(width: number): string[] {
                    const content_height = tui.children.reduce(
                        (height, component) => component === footer_component ? height : height + component.render(width).length,
                        0,
                    );
                    const spacer_height = Math.max(0, tui.terminal.rows - content_height - FOOTER_HEIGHT);

                    return [
                        ...Array.from({ length: spacer_height }, () => ""),
                        render_footer(ctx, footer_data.getGitBranch(), usage, theme, width),
                    ];
                },
            };

            return footer_component;
        });
    });

    pi.on("session_shutdown", (_event, ctx) => {
        usage = undefined;
        request_render = undefined;
        remove_usage_listener();
        if (ctx.mode === "tui") {
            ctx.ui.setFooter(undefined);
        }
    });
}

function render_footer(
    ctx: ExtensionContext,
    branch: string | null,
    usage: UsageEvent | undefined,
    theme: Theme,
    width: number,
): string {
    const tokens = get_token_totals(ctx);
    const context_usage = ctx.getContextUsage();
    const context_window = context_usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
    const context_percent = context_usage?.percent;
    const context = context_percent === null || context_percent === undefined
        ? `?/${format_tokens(context_window)}`
        : `${context_percent.toFixed(1)}%/${format_tokens(context_window)}`;
    const required_parts = [
        `${format_cwd(ctx.cwd)} (${branch ?? "no git"})`,
        `↑${format_tokens(tokens.input)}`,
        `↓${format_tokens(tokens.output)}`,
        context,
        "compact: auto",
    ];
    const optional_parts = [
        tokens.cache_read > 0 ? `cache read: ${format_tokens(tokens.cache_read)}` : undefined,
        tokens.cache_write > 0 ? `cache write: ${format_tokens(tokens.cache_write)}` : undefined,
        get_cache_hit_rate(tokens),
    ].filter((part): part is string => Boolean(part));
    const usage_text = usage?.provider === ctx.model?.provider ? usage?.text : undefined;
    const right = [get_model_label(ctx), usage_text].filter(Boolean).join(" • ");

    const parts = [...required_parts, ...optional_parts];
    while (parts.length > required_parts.length && visibleWidth(parts.join("  ")) + visibleWidth(right) + 2 > width) {
        parts.pop();
    }

    return render_stats_line(parts.join("  "), right, context_percent, theme, width);
}

function render_stats_line(
    left: string,
    right: string,
    context_percent: number | null | undefined,
    theme: Theme,
    width: number,
): string {
    const available_left_width = Math.max(0, width - visibleWidth(right) - 2);
    const truncated_left = truncateToWidth(left, available_left_width, "…");
    const padding = " ".repeat(Math.max(2, width - visibleWidth(truncated_left) - visibleWidth(right)));
    const left_style = context_percent !== null && context_percent !== undefined && context_percent > 90
        ? theme.fg("error", truncated_left)
        : context_percent !== null && context_percent !== undefined && context_percent > 70
            ? theme.fg("warning", truncated_left)
            : theme.fg("dim", truncated_left);

    return truncateToWidth(left_style + theme.fg("dim", padding + right), width);
}

function get_token_totals(ctx: ExtensionContext): TokenTotals {
    const totals: TokenTotals = { input: 0, output: 0, cache_read: 0, cache_write: 0 };

    for (const entry of ctx.sessionManager.getEntries()) {
        if (entry.type === "message" && entry.message.role === "assistant") {
            add_usage(totals, entry.message.usage);
            const request_usage = entry.message.usage;
            const prompt_tokens = request_usage.input + request_usage.cacheRead + request_usage.cacheWrite;
            totals.latest_cache_hit = prompt_tokens > 0 ? (request_usage.cacheRead / prompt_tokens) * 100 : undefined;
        } else if (entry.type === "message" && entry.message.role === "toolResult") {
            add_usage(totals, entry.message.usage);
        } else if ((entry.type === "branch_summary" || entry.type === "compaction") && entry.usage) {
            add_usage(totals, entry.usage);
        }
    }

    return totals;
}

function add_usage(totals: TokenTotals, usage: TokenUsage | undefined): void {
    if (!usage) return;
    totals.input += usage.input ?? 0;
    totals.output += usage.output ?? 0;
    totals.cache_read += usage.cacheRead ?? 0;
    totals.cache_write += usage.cacheWrite ?? 0;
}

function get_cache_hit_rate(tokens: TokenTotals): string | undefined {
    if (tokens.latest_cache_hit === undefined) return undefined;
    return `last cache hit: ${tokens.latest_cache_hit.toFixed(1)}%`;
}

function get_model_label(ctx: ExtensionContext): string {
    const model = ctx.model;
    if (!model) return "no model";
    if (!model.reasoning) return model.id;
    return `${model.id} • ${ctx.thinkingLevel ?? "off"}`;
}

function is_usage_event(event: unknown): event is UsageEvent {
    if (!event || typeof event !== "object") return false;
    const value = event as UsageEvent;
    return (value.provider === undefined || typeof value.provider === "string") &&
        (value.text === undefined || typeof value.text === "string");
}

function format_cwd(cwd: string): string {
    const home = process.env.HOME ?? process.env.USERPROFILE;
    if (!home || !cwd.startsWith(home)) return cwd;
    return cwd === home ? "~" : `~${cwd.slice(home.length)}`;
}

function format_tokens(count: number): string {
    if (count < 1_000) return String(count);
    if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
    if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
    if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
    return `${Math.round(count / 1_000_000)}M`;
}
