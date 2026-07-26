import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { Action, ActionPanel, List, Toast, showToast } from "@vicinae/api";
import { useEffect, useState } from "react";

const exec_file = promisify(execFile);

type AudioPort = {
    name: string;
    description?: string;
    availability?: string;
};

type AudioDevice = {
    name: string;
    description?: string;
    active_port?: string;
    ports?: AudioPort[];
    properties?: {
        "device.class"?: string;
        "device.description"?: string;
    };
};

type AudioDirection = "input" | "output";

function parse_devices(output: string, direction: AudioDirection): AudioDevice[] {
    const devices: AudioDevice[] = JSON.parse(output) as AudioDevice[];

    return devices.filter((device) => {
        const is_monitor = device.name.endsWith(".monitor") || device.properties?.["device.class"] === "monitor";
        const has_available_port = !device.ports?.length || device.ports.some((port) => port.availability !== "not available");

        return (direction === "output" || !is_monitor) && has_available_port;
    });
}

function device_label(device: AudioDevice): string {
    const active_port = device.ports?.find((port) => port.name === device.active_port);
    const device_description = device.properties?.["device.description"];

    if (active_port?.description && device_description) {
        return `${active_port.description} - ${device_description}`;
    }

    return device.description ?? device.name;
}

export default function SelectAudioDevice() {
    const [input_devices, setInputDevices] = useState<AudioDevice[]>([]);
    const [output_devices, setOutputDevices] = useState<AudioDevice[]>([]);
    const [current_input, setCurrentInput] = useState<string | null>(null);
    const [current_output, setCurrentOutput] = useState<string | null>(null);
    const [is_loading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        void load_devices();
    }, []);

    async function load_devices() {
        setIsLoading(true);

        try {
            const [inputs_result, outputs_result, current_input_result, current_output_result] = await Promise.all([
                exec_file("pactl", ["--format=json", "list", "sources"]),
                exec_file("pactl", ["--format=json", "list", "sinks"]),
                exec_file("pactl", ["get-default-source"]),
                exec_file("pactl", ["get-default-sink"]),
            ]);

            setInputDevices(parse_devices(inputs_result.stdout, "input"));
            setOutputDevices(parse_devices(outputs_result.stdout, "output"));
            setCurrentInput(current_input_result.stdout.trim());
            setCurrentOutput(current_output_result.stdout.trim());
            setError(null);
        } catch (error) {
            setInputDevices([]);
            setOutputDevices([]);
            setCurrentInput(null);
            setCurrentOutput(null);
            setError(error instanceof Error ? error.message : String(error));
        } finally {
            setIsLoading(false);
        }
    }

    async function select_device(device: AudioDevice, direction: AudioDirection) {
        const direction_label = direction === "input" ? "input" : "output";
        const toast = await showToast(
            Toast.Style.Animated,
            `Selecting ${direction_label} device`,
            device_label(device)
        );
        const command = direction === "input" ? "set-default-source" : "set-default-sink";

        try {
            await exec_file("pactl", [command, device.name]);

            if (direction === "input") {
                setCurrentInput(device.name);
            } else {
                setCurrentOutput(device.name);
            }

            toast.style = Toast.Style.Success;
            toast.title = `Selected ${direction_label} device`;
            toast.message = device_label(device);
        } catch (error) {
            toast.style = Toast.Style.Failure;
            toast.title = `Failed to select ${direction_label} device`;
            toast.message = error instanceof Error ? error.message : String(error);
        }
    }

    function render_devices(devices: AudioDevice[], direction: AudioDirection, current_device: string | null) {
        const direction_label = direction === "input" ? "Input" : "Output";
        const device_icon = direction === "input" ? "🎙️" : "🔊";

        if (!is_loading && devices.length === 0) {
            return (
                <List.Item
                    title={error ? "Audio service unavailable" : `No ${direction_label.toLowerCase()} devices found`}
                    subtitle={error ?? "Connect a device, then reopen this command"}
                    icon="⚠️"
                />
            );
        }

        return devices.map((device) => (
            <List.Item
                key={device.name}
                title={device_label(device)}
                subtitle={device.name}
                icon={device_icon}
                keywords={[device_label(device), device.name, direction_label.toLowerCase()]}
                accessories={device.name === current_device ? [{ text: "Current" }] : []}
                actions={
                    <ActionPanel>
                        <Action
                            title={`Select ${direction_label} Device`}
                            onAction={() => void select_device(device, direction)}
                        />
                    </ActionPanel>
                }
            />
        ));
    }

    return (
        <List isLoading={is_loading} searchBarPlaceholder="Search audio devices...">
            <List.Section title="Input">
                {render_devices(input_devices, "input", current_input)}
            </List.Section>
            <List.Section title="Output">
                {render_devices(output_devices, "output", current_output)}
            </List.Section>
        </List>
    );
}
