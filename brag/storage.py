import datetime
from pathlib import Path
from typing import List, Optional

from brag.models import BragEntry


class BragStorage:
    def __init__(self, data_dir: Optional[str] = None):
        if data_dir:
            self.data_dir = Path(data_dir)
        else:
            self.data_dir = Path.home() / ".brag" / "data"

    def _get_file_path(self, timestamp: str) -> Path:
        # timestamp format: YYYY-MM-DDTHH:MM:SSZ
        # We want to handle the Z correctly
        dt = datetime.datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
        year = str(dt.year)
        month = f"{dt.month:02d}"
        day = f"{dt.day:02d}"
        return self.data_dir / year / month / f"{day}.jsonl"

    def add_entry(self, entry: BragEntry) -> None:
        file_path = self._get_file_path(entry.timestamp)
        file_path.parent.mkdir(parents=True, exist_ok=True)

        with open(file_path, "a") as f:
            f.write(entry.to_json() + "\n")

    def get_entries(self, date_str: str) -> List[BragEntry]:
        # date_str format: YYYY-MM-DD
        try:
            year, month, day = date_str.split("-")
            file_path = self.data_dir / year / month / f"{day}.jsonl"
        except ValueError:
            return []

        if not file_path.exists():
            return []

        entries = []
        with open(file_path, "r") as f:
            for line in f:
                if line.strip():
                    entries.append(BragEntry.from_json(line.strip()))
        return entries

    def get_entries_range(self, start_date: str, end_date: str) -> List[BragEntry]:
        # start_date and end_date: YYYY-MM-DD
        start = datetime.date.fromisoformat(start_date)
        end = datetime.date.fromisoformat(end_date)

        entries = []
        current = start
        while current <= end:
            date_str = current.isoformat()
            entries.extend(self.get_entries(date_str))
            current += datetime.timedelta(days=1)

        return entries

    def list_available_dates(self) -> List[str]:
        dates = []
        if not self.data_dir.exists():
            return []

        for year_dir in self.data_dir.iterdir():
            if not year_dir.is_dir():
                continue
            for month_dir in year_dir.iterdir():
                if not month_dir.is_dir():
                    continue
                for day_file in month_dir.glob("*.jsonl"):
                    year = year_dir.name
                    month = month_dir.name
                    day = day_file.stem
                    dates.append(f"{year}-{month}-{day}")

        return sorted(dates)
