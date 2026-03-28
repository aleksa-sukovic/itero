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

type Accent = {
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

const accents: Accent[] = [
    { id: "blue",     title: "Blue",     icon: "🔵", keywords: ["blue"] },
    { id: "teal",     title: "Teal",     icon: "🩵", keywords: ["teal", "cyan"] },
    { id: "green",    title: "Green",    icon: "🟢", keywords: ["green"] },
    { id: "yellow",   title: "Yellow",   icon: "🟡", keywords: ["yellow"] },
    { id: "peach",    title: "Peach",    icon: "🟠", keywords: ["peach", "orange"] },
    { id: "red",      title: "Red",      icon: "🔴", keywords: ["red"] },
    { id: "pink",     title: "Pink",     icon: "🩷", keywords: ["pink"] },
    { id: "mauve",    title: "Mauve",    icon: "🟣", keywords: ["mauve", "purple"] },
    { id: "lavender", title: "Lavender", icon: "🪻", keywords: ["lavender", "slate"] },
];

export default function SelectTheme() {
    const [current_theme, setCurrentTheme] = useState<string | null>(null);
    const [current_accent, setCurrentAccent] = useState<string | null>(null);
    const [is_loading, setIsLoading] = useState(true);

    useEffect(() => {
        void loadCurrent();
    }, []);

    async function loadCurrent() {
        try {
            const [theme_result, accent_result] = await Promise.all([
                exec_file(itero_theme_path, ["--current"]),
                exec_file(itero_theme_path, ["--current-accent"]),
            ]);
            setCurrentTheme(theme_result.stdout.trim());
            setCurrentAccent(accent_result.stdout.trim());
        } catch {
            setCurrentTheme(null);
            setCurrentAccent(null);
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

    async function applyAccent(accent: Accent) {
        const toast = await showToast(Toast.Style.Animated, "Applying accent", accent.title);

        try {
            await exec_file(itero_theme_path, ["--accent", accent.id]);
            setCurrentAccent(accent.id);
            toast.style = Toast.Style.Success;
            toast.title = "Applied accent";
            toast.message = accent.title;
        } catch (error) {
            toast.style = Toast.Style.Failure;
            toast.title = "Failed to apply accent";
            toast.message = error instanceof Error ? error.message : String(error);
        }
    }

    return (
        <List isLoading={is_loading} searchBarPlaceholder="Search themes and accents...">
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
            <List.Section title="Accent Colors">
                {accents.map((accent) => (
                    <List.Item
                        key={accent.id}
                        title={accent.title}
                        subtitle={accent.id}
                        icon={accent.icon}
                        keywords={accent.keywords}
                        accessories={accent.id === current_accent ? [{ text: "Current" }] : []}
                        actions={
                            <ActionPanel>
                                <Action
                                    title="Apply Accent"
                                    icon={Icon.PaintBrush}
                                    onAction={() => void applyAccent(accent)}
                                />
                                <Action.CopyToClipboard
                                    title="Copy Accent Name"
                                    content={accent.id}
                                />
                            </ActionPanel>
                        }
                    />
                ))}
            </List.Section>
        </List>
    );
}
