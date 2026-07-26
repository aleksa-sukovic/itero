import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { Action, ActionPanel, List, Toast, showToast } from "@vicinae/api";
import { useEffect, useState } from "react";

const exec_file = promisify(execFile);
const itero_monitor_path = `${process.env.HOME}/.local/share/itero/bin/itero-monitor`;

type InputSource = {
    code: string;
    label: string;
};

function parse_input_sources(output: string): InputSource[] {
    return output
        .trim()
        .split("\n")
        .filter(Boolean)
        .map((line) => {
            const [code, label] = line.split("\t");
            return { code, label };
        })
        .filter((source) => source.code && source.label);
}

export default function ControlMonitor() {
    const [input_sources, set_input_sources] = useState<InputSource[]>([]);
    const [is_loading, set_is_loading] = useState(true);
    const [error, set_error] = useState<string | null>(null);

    useEffect(() => {
        void load_input_sources();
    }, []);

    async function load_input_sources() {
        set_is_loading(true);

        try {
            const result = await exec_file(itero_monitor_path, ["input", "--list"]);
            set_input_sources(parse_input_sources(result.stdout));
            set_error(null);
        } catch (error) {
            set_input_sources([]);
            set_error(error instanceof Error ? error.message : String(error));
        } finally {
            set_is_loading(false);
        }
    }

    async function adjust_brightness(direction: "--up" | "--down") {
        const action = direction === "--up" ? "Increasing" : "Decreasing";
        const toast = await showToast(Toast.Style.Animated, `${action} brightness`);

        try {
            await exec_file(itero_monitor_path, ["brightness", direction]);
            toast.style = Toast.Style.Success;
            toast.title = "Brightness adjusted";
        } catch (error) {
            toast.style = Toast.Style.Failure;
            toast.title = "Failed to adjust brightness";
            toast.message = error instanceof Error ? error.message : String(error);
        }
    }

    async function switch_input(source: InputSource) {
        const toast = await showToast(Toast.Style.Animated, "Switching input", source.label);

        try {
            await exec_file(itero_monitor_path, ["input", source.code]);
            toast.style = Toast.Style.Success;
            toast.title = "Switched input";
            toast.message = source.label;
        } catch (error) {
            toast.style = Toast.Style.Failure;
            toast.title = "Failed to switch input";
            toast.message = error instanceof Error ? error.message : String(error);
        }
    }

    return (
        <List isLoading={is_loading} searchBarPlaceholder="Search monitor controls...">
            <List.Section title="Brightness">
                <List.Item
                    title="Increase Brightness"
                    icon="🔆"
                    keywords={["brightness", "up", "increase"]}
                    actions={
                        <ActionPanel>
                            <Action
                                title="Increase Brightness"
                                onAction={() => void adjust_brightness("--up")}
                            />
                        </ActionPanel>
                    }
                />
                <List.Item
                    title="Decrease Brightness"
                    icon="🔅"
                    keywords={["brightness", "down", "decrease"]}
                    actions={
                        <ActionPanel>
                            <Action
                                title="Decrease Brightness"
                                onAction={() => void adjust_brightness("--down")}
                            />
                        </ActionPanel>
                    }
                />
            </List.Section>
            <List.Section title="Input Sources">
                {input_sources.map((source) => (
                    <List.Item
                        key={source.code}
                        title={source.label}
                        subtitle={source.code}
                        icon="🖥️"
                        keywords={[source.label, source.code, "input", "source"]}
                        actions={
                            <ActionPanel>
                                <Action
                                    title="Switch Input"
                                    onAction={() => void switch_input(source)}
                                />
                            </ActionPanel>
                        }
                    />
                ))}
                {!is_loading && input_sources.length === 0 && (
                    <List.Item
                        title={error ? "Monitor unavailable" : "No input sources reported"}
                        subtitle={error ?? "This monitor does not report selectable inputs through DDC/CI"}
                        icon="⚠️"
                    />
                )}
            </List.Section>
        </List>
    );
}
