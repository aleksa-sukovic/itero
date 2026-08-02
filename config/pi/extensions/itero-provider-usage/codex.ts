import type { ExtensionContext } from "@earendil-works/pi-coding-agent";

const CODEX_USAGE_URL = "https://chatgpt.com/backend-api/wham/usage";

type CodexUsageResponse = {
    rate_limit?: {
        primary_window?: {
            used_percent?: number;
            limit_window_seconds?: number;
        };
    };
};

export async function get_codex_usage(ctx: ExtensionContext, signal: AbortSignal): Promise<string | undefined> {
    const model = ctx.model;
    if (!model || model.provider !== "openai-codex") return undefined;
    if (new URL(model.baseUrl).origin !== "https://chatgpt.com") return undefined;

    const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
    if (!auth.ok) throw new Error("Codex authentication is unavailable");

    const authorization = auth.headers?.Authorization ?? (auth.apiKey ? `Bearer ${auth.apiKey}` : undefined);
    if (!authorization) throw new Error("Codex authentication is unavailable");

    const response = await fetch(CODEX_USAGE_URL, {
        headers: {
            Authorization: authorization,
            "User-Agent": "itero-pi-usage",
        },
        signal,
    });
    if (!response.ok) throw new Error("Codex usage is unavailable");

    const usage = (await response.json()) as CodexUsageResponse;
    const window = usage.rate_limit?.primary_window;
    if (!window || typeof window.used_percent !== "number") throw new Error("Codex usage is unavailable");

    const remaining = Math.max(0, Math.min(100, 100 - window.used_percent));
    return `${Math.round(remaining)}% left (${format_window(window.limit_window_seconds)})`;
}

function format_window(seconds: number | undefined): string {
    if (!seconds || !Number.isFinite(seconds) || seconds <= 0) return "unknown period";

    const minutes = Math.round(seconds / 60);
    if (minutes === 10_080) return "week";
    if (minutes % 10_080 === 0) return `${minutes / 10_080} weeks`;
    if (minutes % 1_440 === 0) return `${minutes / 1_440} days`;
    if (minutes % 60 === 0) return `${minutes / 60} hours`;
    return `${minutes} minutes`;
}
