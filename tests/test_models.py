from brag.models import BragEntry


def test_brag_entry_creation():
    entry = BragEntry(content="Test content")
    assert entry.content == "Test content"
    assert entry.timestamp.endswith("Z")
    assert entry.tags == []
    assert entry.project is None


def test_brag_entry_full_creation():
    timestamp = "2023-01-01T12:00:00Z"
    entry = BragEntry(
        content="Test content",
        timestamp=timestamp,
        tags=["tag1", "tag2"],
        project="project1",
    )
    assert entry.content == "Test content"
    assert entry.timestamp == timestamp
    assert entry.tags == ["tag1", "tag2"]
    assert entry.project == "project1"


def test_serialization():
    entry = BragEntry(content="Test content", tags=["tag1"], project="proj")
    data = entry.to_dict()
    assert data["content"] == "Test content"
    assert data["tags"] == ["tag1"]
    assert data["project"] == "proj"

    json_str = entry.to_json()
    loaded_entry = BragEntry.from_json(json_str)
    assert loaded_entry.content == entry.content
    assert loaded_entry.timestamp == entry.timestamp
    assert loaded_entry.tags == entry.tags
    assert loaded_entry.project == entry.project


def test_multiline_content():
    content = "Line 1\nLine 2"
    entry = BragEntry(content=content)
    assert entry.content == content
    json_str = entry.to_json()
    loaded_entry = BragEntry.from_json(json_str)
    assert loaded_entry.content == content
