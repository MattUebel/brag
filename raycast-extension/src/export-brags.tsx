import {
  Action,
  ActionPanel,
  Form,
  showToast,
  Toast,
  useNavigation,
  Clipboard,
} from "@raycast/api";
import { execFile } from "child_process";
import { useState } from "react";
import util from "util";
import { getBragPath } from "./config";

const execFilePromise = util.promisify(execFile);

interface FormValues {
  start: Date | null;
  end: Date | null;
  format: string;
}

export default function Command() {
  const { pop } = useNavigation();
  const [isLoading, setIsLoading] = useState(false);

  async function handleSubmit(values: FormValues) {
    setIsLoading(true);
    try {
      const args = ["export"];

      if (values.start) {
        args.push("--start", values.start.toISOString().split("T")[0]);
      }
      if (values.end) {
        args.push("--end", values.end.toISOString().split("T")[0]);
      }
      args.push("--format", values.format);

      const bragPath = getBragPath();
      const { stdout } = await execFilePromise(bragPath, args);

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
      <Form.DatePicker id="start" title="Start Date" />
      <Form.DatePicker id="end" title="End Date" />
      <Form.Dropdown id="format" title="Format" defaultValue="json">
        <Form.Dropdown.Item value="json" title="JSON" />
        <Form.Dropdown.Item value="markdown" title="Markdown" />
        <Form.Dropdown.Item value="text" title="Plain Text" />
      </Form.Dropdown>
    </Form>
  );
}
