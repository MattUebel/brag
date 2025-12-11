import { Action, ActionPanel, List, showToast, Toast } from "@raycast/api";
import { exec } from "child_process";
import { useEffect, useState } from "react";
import util from "util";
import { getBragPath } from "./config";

const execPromise = util.promisify(exec);

interface BragEntry {
    content: string;
    timestamp: string;
    tags: string[];
    project: string | null;
}

export default function Command() {
    const [entries, setEntries] = useState([] as BragEntry[]);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        async function fetchEntries() {
            try {
                const bragPath = getBragPath();
                const { stdout } = await execPromise(`${bragPath} export --format json`);
                const data = JSON.parse(stdout) as BragEntry[];
                setEntries(data);
            } catch (error) {
                showToast({
                    style: Toast.Style.Failure,
                    title: "Failed to load brags",
                    message: String(error),
                });
                setEntries([]);
            } finally {
                setIsLoading(false);
            }
        }

        fetchEntries();
    }, []);

    return (
        <List isLoading={isLoading} searchBarPlaceholder="Search brags...">
            {entries.map((entry, index) => (
                <List.Item
                    key={index}
                    title={entry.content}
                    subtitle={entry.project || ""}
                    accessories={[
                        { text: new Date(entry.timestamp).toLocaleDateString() },
                        ...entry.tags.map((tag) => ({ tag: { value: tag } })),
                    ]}
                    actions={
                        <ActionPanel>
                            <Action.CopyToClipboard content={entry.content} title="Copy Content" />
                            <Action.CopyToClipboard
                                content={JSON.stringify(entry, null, 2)}
                                title="Copy as JSON"
                            />
                        </ActionPanel>
                    }
                />
            ))}
        </List>
    );
}
