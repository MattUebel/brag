import { Action, ActionPanel, Form, showToast, Toast, useNavigation } from "@raycast/api";
import { exec } from "child_process";
import { useState } from "react";
import util from "util";

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

      // Assuming brag is in PATH or we use full path. 
      // For now, let's assume 'brag' works if setup_shell.sh was run and shell env is picked up.
      // Or we might need to find where it is.
      // A safer bet for the extension is to try to run it directly if we know where it is, 
      // but we don't know the user's install path easily.
      // Let's assume 'brag' is in the path.
      
      const cmd = `brag add "${content}" ${tags} ${project}`;
      
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
