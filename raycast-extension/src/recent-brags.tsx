import { Action, ActionPanel, List, showToast, Toast, Dropdown } from "@raycast/api";
import { exec } from "child_process";
import { useEffect, useState } from "react";
import util from "util";

const execPromise = util.promisify(exec);

interface BragEntry {
    content: string;
    timestamp: string;
    tags: string[];
    project: string | null;
}

export default function Command() {
    const [entries, setEntries] = useState<BragEntry[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [days, setDays] = useState("7");

    useEffect(() => {
        async function fetchEntries() {
            setIsLoading(true);
            try {
                // We can't easily filter by days with export json yet without parsing all
                // But `brag list --days N` outputs text.
                // Let's use `brag export` and filter in JS for now as it returns JSON.
                // Or we could add --days to export? The architecture didn't specify it.
                // But `brag export` has --start. We can calculate start date.

                const date = new Date();
                date.setDate(date.getDate() - parseInt(days));
                const start = date.toISOString().split("T")[0];

                const { stdout } = await execPromise(`brag export --start ${start} --format json`);
                const data = JSON.parse(stdout);
                // Sort by timestamp desc
                data.sort((a: BragEntry, b: BragEntry) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime());
                setEntries(data);
            } catch (error) {
                showToast({
                    style: Toast.Style.Failure,
                    title: "Failed to load brags",
                    message: String(error),
                });
            } finally {
                setIsLoading(false);
            }
        }

        fetchEntries();
    }, [days]);

    return (
        <List
            isLoading={isLoading}
            searchBarPlaceholder="Filter recent brags..."
            searchBarAccessory={
                <Dropdown tooltip="Time Period" storeValue={true} onChange={setDays}>
                    <Dropdown.Item title="Last 7 Days" value="7" />
                    <Dropdown.Item title="Last 14 Days" value="14" />
                    <Dropdown.Item title="Last 30 Days" value="30" />
                    <Dropdown.Item title="Last 90 Days" value="90" />
                </Dropdown>
            }
        >
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
