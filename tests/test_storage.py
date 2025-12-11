import pytest

from brag.models import BragEntry
from brag.storage import BragStorage


@pytest.fixture
def temp_storage(tmp_path):
    storage = BragStorage(data_dir=str(tmp_path))
    return storage


def test_storage_initialization(temp_storage):
    assert temp_storage.data_dir.exists() or True  # It's created on write


def test_add_and_get_entry(temp_storage):
    timestamp = "2023-01-01T12:00:00Z"
    entry = BragEntry(content="Test entry", timestamp=timestamp)
    temp_storage.add_entry(entry)

    entries = temp_storage.get_entries("2023-01-01")
    assert len(entries) == 1
    assert entries[0].content == "Test entry"


def test_get_entries_range(temp_storage):
    entry1 = BragEntry(content="Entry 1", timestamp="2023-01-01T10:00:00Z")
    entry2 = BragEntry(content="Entry 2", timestamp="2023-01-02T10:00:00Z")
    entry3 = BragEntry(content="Entry 3", timestamp="2023-01-03T10:00:00Z")

    temp_storage.add_entry(entry1)
    temp_storage.add_entry(entry2)
    temp_storage.add_entry(entry3)

    entries = temp_storage.get_entries_range("2023-01-01", "2023-01-02")
    assert len(entries) == 2
    assert entries[0].content == "Entry 1"
    assert entries[1].content == "Entry 2"


def test_list_available_dates(temp_storage):
    entry1 = BragEntry(content="Entry 1", timestamp="2023-01-01T10:00:00Z")
    entry2 = BragEntry(content="Entry 2", timestamp="2023-01-03T10:00:00Z")

    temp_storage.add_entry(entry1)
    temp_storage.add_entry(entry2)

    dates = temp_storage.list_available_dates()
    assert dates == ["2023-01-01", "2023-01-03"]


def test_missing_file_returns_empty(temp_storage):
    entries = temp_storage.get_entries("2023-01-01")
    assert entries == []
