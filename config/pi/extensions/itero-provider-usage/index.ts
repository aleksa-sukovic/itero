import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { get_codex_usage } from "./codex.js";

const usage_refresh_interval_ms = 5 * 60 * 1000;
const usage_event = "itero:provider-usage";

export default function (pi: ExtensionAPI) {
    let active = false;
    let refresh_timer: ReturnType<typeof setTimeout> | undefined;
    let controller: AbortController | undefined;

    const clear_refresh_timer = () => {
        if (refresh_timer) clearTimeout(refresh_timer);
        refresh_timer = undefined;
    };

    const publish = (provider: string | undefined, text: string | undefined) => {
        pi.events.emit(usage_event, { provider, text });
    };

    const schedule_refresh = (ctx: ExtensionContext) => {
        clear_refresh_timer();
        refresh_timer = setTimeout(() => refresh(ctx), usage_refresh_interval_ms);
        refresh_timer.unref?.();
    };

    const refresh = async (ctx: ExtensionContext) => {
        const model = ctx.model;
        controller?.abort();
        controller = undefined;

        if (!model || model.provider !== "openai-codex") {
            publish(model?.provider, undefined);
            return;
        }

        const request = new AbortController();
        controller = request;
        publish(model.provider, "checking");

        try {
            const usage = await get_codex_usage(ctx, request.signal);
            if (active && !request.signal.aborted && is_current_model(ctx, model)) {
                publish(model.provider, usage ?? "unavailable");
            }
        } catch {
            if (active && !request.signal.aborted && is_current_model(ctx, model)) {
                publish(model.provider, "unavailable");
            }
        } finally {
            if (controller === request) controller = undefined;
            if (active && is_current_model(ctx, model)) schedule_refresh(ctx);
        }
    };

    pi.on("session_start", (_event, ctx) => {
        if (ctx.mode !== "tui") return;
        active = true;
        void refresh(ctx);
    });

    pi.on("model_select", (_event, ctx) => {
        if (ctx.mode === "tui") void refresh(ctx);
    });

    pi.on("session_shutdown", (_event, ctx) => {
        active = false;
        clear_refresh_timer();
        controller?.abort();
        controller = undefined;
        publish(ctx.model?.provider, undefined);
    });
}

function is_current_model(ctx: ExtensionContext, model: NonNullable<ExtensionContext["model"]>): boolean {
    const current = ctx.model;
    return current?.provider === model.provider && current.id === model.id;
}
