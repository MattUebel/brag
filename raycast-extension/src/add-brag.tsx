import { Action, ActionPanel, Form, showToast, Toast, useNavigation } from "@raycast/api";
import { exec } from "child_process";
import { useState } from "react";
import util from "util";
import { getBragPath } from "./config";

const execPromise = util.promisify(exec);

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
      const tags = values.tags
        ? values.tags.split(",").map((t) => `--tags "${t.trim()}"`).join(" ")
        : "";
      const project = values.project ? `--project "${values.project}"` : "";
      const content = values.content.replace(/"/g, '\\"'); // Simple escaping

      const bragPath = getBragPath();
      const cmd = `${bragPath} add "${content}" ${tags} ${project}`;

      await execPromise(cmd);

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
