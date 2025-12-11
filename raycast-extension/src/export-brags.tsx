import { Action, ActionPanel, Form, showToast, Toast, useNavigation } from "@raycast/api";
import { exec } from "child_process";
import { useState } from "react";
import util from "util";

const execPromise = util.promisify(exec);

interface FormValues {
    start: string | null;
    end: string | null;
    format: string;
}

export default function Command() {
    const { pop } = useNavigation();
    const [isLoading, setIsLoading] = useState(false);

    async function handleSubmit(values: FormValues) {
        setIsLoading(true);
        try {
            const start = values.start ? `--start ${new Date(values.start).toISOString().split("T")[0]}` : "";
            const end = values.end ? `--end ${new Date(values.end).toISOString().split("T")[0]}` : "";
            const format = `--format ${values.format}`;

            const cmd = `brag export ${start} ${end} ${format}`;
            const { stdout } = await execPromise(cmd);

            // Copy to clipboard is handled by Action.CopyToClipboard usually, but here we want to do it after generation?
            // Or we can just return the output and let the user copy it?
            // The architecture says "Auto-copy to clipboard".
            // Raycast has a Clipboard API.

            const { Clipboard } = require("@raycast/api");
            await Clipboard.copy(stdout);

            showToast({
                style: Toast.Style.Success,
                title: "Exported and copied to clipboard!",
            });
            pop();
        } catch (error) {
            showToast({
                style: Toast.Style.Failure,
                title: "Failed to export",
                message: String(error),
            });
        } finally {
            setIsLoading(false);
        }
    }

    return (
        <Form
            actions={
                <ActionPanel>
                    <Action.SubmitForm title="Export" onSubmit={handleSubmit} />
                </ActionPanel>
            }
            isLoading={isLoading}
        >
            <Form.DatePicker
                id="start"
                title="Start Date"
            />
            <Form.DatePicker
                id="end"
                title="End Date"
            />
            <Form.Dropdown id="format" title="Format" defaultValue="json">
                <Form.Dropdown.Item value="json" title="JSON" />
                <Form.Dropdown.Item value="markdown" title="Markdown" />
                <Form.Dropdown.Item value="text" title="Plain Text" />
            </Form.Dropdown>
        </Form>
    );
}
