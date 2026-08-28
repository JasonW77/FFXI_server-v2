#!/usr/bin/env python3
"""Quick DB status check after classic75 purge."""

from __future__ import annotations

from pathlib import Path

from sqlalchemy import text

from ffxiahbot.config import Config
from ffxiahbot.database import Database


def main() -> None:
    config = Config.from_yaml(Path("/home/jason/ffxiahbot/bin/config.yaml"))
    db = Database.pymysql(
        hostname=config.hostname,
        database=config.database,
        username=config.username,
        password=config.password.get_secret_value(),
        port=config.port,
    )
    with db.engine.connect() as conn:
        for label, sql in [
            ("chars", "SELECT charid, charname, accid FROM chars"),
            ("accounts", "SELECT id, login FROM accounts"),
            ("ah", "SELECT COUNT(*) FROM auction_house"),
            ("unlocked", "SELECT COUNT(*) FROM ahbot_unlocked_items"),
        ]:
            print(f"--- {label} ---")
            rows = conn.execute(text(sql)).fetchall()
            for row in rows:
                print(row)


if __name__ == "__main__":
    main()
