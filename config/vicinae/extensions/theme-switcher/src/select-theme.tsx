import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { Action, ActionPanel, Icon, List, Toast, showToast } from "@vicinae/api";
import { useEffect, useState } from "react";

const exec_file = promisify(execFile);
const itero_theme_path = `${process.env.HOME}/.local/share/itero/bin/itero-theme`;

type Theme = {
    id: string;
    title: string;
    icon: string;
    keywords: string[];
};

const themes: Theme[] = [
    {
        id: "catppuccin-latte",
        title: "Catppuccin Latte",
        icon: "🌞",
        keywords: ["catppuccin", "latte", "light"],
    },
    {
        id: "catppuccin-frappe",
        title: "Catppuccin Frappe",
        icon: "🌆",
        keywords: ["catppuccin", "frappe", "dark"],
    },
    {
        id: "catppuccin-macchiato",
        title: "Catppuccin Macchiato",
        icon: "🌃",
        keywords: ["catppuccin", "macchiato", "dark"],
    },
    {
        id: "catppuccin-mocha",
        title: "Catppuccin Mocha",
        icon: "🌙",
        keywords: ["catppuccin", "mocha", "dark"],
    },
];

export default function SelectTheme() {
    const [current_theme, setCurrentTheme] = useState<string | null>(null);
    const [is_loading, setIsLoading] = useState(true);

    useEffect(() => {
        void loadCurrentTheme();
    }, []);

    async function loadCurrentTheme() {
        try {
            const { stdout } = await exec_file(itero_theme_path, ["--current"]);
            setCurrentTheme(stdout.trim());
        } catch {
            setCurrentTheme(null);
        } finally {
            setIsLoading(false);
        }
    }

    async function applyTheme(theme: Theme) {
        const toast = await showToast(Toast.Style.Animated, "Applying theme", theme.title);

        try {
            await exec_file(itero_theme_path, [theme.id]);
            setCurrentTheme(theme.id);
            toast.style = Toast.Style.Success;
            toast.title = "Applied theme";
            toast.message = theme.title;
        } catch (error) {
            toast.style = Toast.Style.Failure;
            toast.title = "Failed to apply theme";
            toast.message = error instanceof Error ? error.message : String(error);
        }
    }

    return (
        <List isLoading={is_loading} searchBarPlaceholder="Search themes...">
            <List.Section title="Themes">
                {themes.map((theme) => (
                    <List.Item
                        key={theme.id}
                        title={theme.title}
                        subtitle={theme.id}
                        icon={theme.icon}
                        keywords={theme.keywords}
                        accessories={theme.id === current_theme ? [{ text: "Current" }] : []}
                        actions={
                            <ActionPanel>
                                <Action
                                    title="Apply Theme"
                                    icon={Icon.PaintBrush}
                                    onAction={() => void applyTheme(theme)}
                                />
                                <Action.CopyToClipboard
                                    title="Copy Theme Name"
                                    content={theme.id}
                                />
                            </ActionPanel>
                        }
                    />
                ))}
            </List.Section>
        </List>
    );
}
