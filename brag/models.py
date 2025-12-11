from dataclasses import dataclass, field, asdict
from typing import List, Optional
import datetime
import json

@dataclass
class BragEntry:
    content: str
    timestamp: str = field(default_factory=lambda: datetime.datetime.utcnow().isoformat() + "Z")
    tags: List[str] = field(default_factory=list)
    project: Optional[str] = None

    def to_dict(self) -> dict:
        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict) -> "BragEntry":
        return cls(**data)

    def to_json(self) -> str:
        return json.dumps(self.to_dict())

    @classmethod
    def from_json(cls, json_str: str) -> "BragEntry":
        return cls.from_dict(json.loads(json_str))
