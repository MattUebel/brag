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
  const [days, setDays] = useState("7");

  useEffect(() => {
    async function fetchEntries() {
      setIsLoading(true);
      try {
        const date = new Date();
        date.setDate(date.getDate() - parseInt(days));
        const start = date.toISOString().split("T")[0];

        const bragPath = getBragPath();
        const { stdout } = await execPromise(
          `${bragPath} export --start ${start} --format json`,
        );
        const data = JSON.parse(stdout) as BragEntry[];
        // Sort by timestamp desc
        data.sort(
          (a, b) =>
            new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime(),
        );
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
  }, [days]);

  return (
    <List
      isLoading={isLoading}
      searchBarPlaceholder="Filter recent brags..."
      searchBarAccessory={
        <List.Dropdown
          tooltip="Time Period"
          storeValue={true}
          onChange={setDays}
        >
          <List.Dropdown.Item title="Last 7 Days" value="7" />
          <List.Dropdown.Item title="Last 14 Days" value="14" />
          <List.Dropdown.Item title="Last 30 Days" value="30" />
          <List.Dropdown.Item title="Last 90 Days" value="90" />
        </List.Dropdown>
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
              <Action.CopyToClipboard
                content={entry.content}
                title="Copy Content"
              />
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
