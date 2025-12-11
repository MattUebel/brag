import { Action, ActionPanel, Form, showToast, Toast, useNavigation } from "@raycast/api";
import { execFile } from "child_process";
import { useState } from "react";
import util from "util";
import { getBragPath } from "./config";

const execFilePromise = util.promisify(execFile);

interface FormValues {
  content: string;
  tags: string;
  project: string;
}

export default function Command() {
  const { pop } = useNavigation();
  const [isLoading, setIsLoading] = useState(false);

  async function handleSubmit(values: FormValues) {
    setIsLoading(true);
    try {
      const args = ["add", values.content];

      if (values.tags) {
        values.tags.split(",").forEach((t) => {
          const trimmed = t.trim();
          if (trimmed) {
            args.push("--tags", trimmed);
          }
        });
      }

      if (values.project) {
        args.push("--project", values.project);
      }

      const bragPath = getBragPath();
      await execFilePromise(bragPath, args);

      showToast({
        style: Toast.Style.Success,
        title: "Brag added!",
      });
      pop();
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to add brag",
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
          <Action.SubmitForm title="Add Brag" onSubmit={handleSubmit} />
        </ActionPanel>
      }
      isLoading={isLoading}
    >
      <Form.TextArea
        id="content"
        title="Content"
        placeholder="What did you accomplish?"
        enableMarkdown
      />
      <Form.TextField
        id="project"
        title="Project"
        placeholder="Project name"
      />
      <Form.TextField
        id="tags"
        title="Tags"
        placeholder="Comma separated tags"
      />
    </Form>
  );
}
