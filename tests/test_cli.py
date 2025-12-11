import argparse
import json
from unittest.mock import MagicMock, patch

import pytest

from brag.cli import cmd_add, cmd_export, cmd_list
from brag.models import BragEntry


@pytest.fixture
def mock_storage():
    return MagicMock()


def test_cmd_add_simple(mock_storage):
    args = argparse.Namespace(
        content=["Test", "content"], tags=None, project=None, edit=False
    )
    cmd_add(args, mock_storage)

    mock_storage.add_entry.assert_called_once()
    entry = mock_storage.add_entry.call_args[0][0]
    assert entry.content == "Test content"


def test_cmd_add_with_metadata(mock_storage):
    args = argparse.Namespace(
        content=["Test"], tags=["tag1"], project="proj1", edit=False
    )
    cmd_add(args, mock_storage)

    entry = mock_storage.add_entry.call_args[0][0]
    assert entry.content == "Test"
    assert entry.tags == ["tag1"]
    assert entry.project == "proj1"


@patch("brag.cli.open_editor")
def test_cmd_add_editor(mock_editor, mock_storage):
    mock_editor.return_value = "Edited content"
    args = argparse.Namespace(content=[], tags=None, project=None, edit=True)
    cmd_add(args, mock_storage)

    mock_editor.assert_called_once()
    entry = mock_storage.add_entry.call_args[0][0]
    assert entry.content == "Edited content"


def test_cmd_add_empty_aborts(mock_storage):
    args = argparse.Namespace(content=[], tags=None, project=None, edit=False)

    # Mock sys.stdin to avoid pytest capture error and simulate empty input
    with patch("sys.stdin") as mock_stdin:
        mock_stdin.isatty.return_value = False
        mock_stdin.read.return_value = ""

        with pytest.raises(SystemExit):
            cmd_add(args, mock_storage)

    mock_storage.add_entry.assert_not_called()


def test_cmd_list(mock_storage, capsys):
    args = argparse.Namespace(date="2023-01-01", days=7)
    entry = BragEntry(content="Test entry", timestamp="2023-01-01T12:00:00Z")
    mock_storage.get_entries.return_value = [entry]

    cmd_list(args, mock_storage)

    captured = capsys.readouterr()
    assert "Test entry" in captured.out
    assert "2023-01-01" in captured.out


def test_cmd_export_json(mock_storage, capsys):
    args = argparse.Namespace(start="2023-01-01", end="2023-01-02", format="json")
    entry = BragEntry(content="Test entry", timestamp="2023-01-01T12:00:00Z")
    mock_storage.get_entries_range.return_value = [entry]

    cmd_export(args, mock_storage)

    captured = capsys.readouterr()
    data = json.loads(captured.out)
    assert len(data) == 1
    assert data[0]["content"] == "Test entry"
