#!/usr/bin/env python3
"""Run classic75_purge.sql after verifying Awesome exists."""

from __future__ import annotations

import sys
from pathlib import Path

from sqlalchemy import text

from ffxiahbot.config import Config
from ffxiahbot.database import Database


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    sql_path = repo_root / "tools" / "classic75_purge.sql"
    cfg_path = Path("/home/jason/ffxiahbot/bin/config.yaml")

    config = Config.from_yaml(cfg_path)
    db = Database.pymysql(
        hostname=config.hostname,
        database=config.database,
        username=config.username,
        password=config.password.get_secret_value()
        if hasattr(config.password, "get_secret_value")
        else str(config.password),
        port=config.port,
    )

    with db.engine.connect() as conn:
        row = conn.execute(
            text(
                "SELECT charid, charname, gmlevel, accid "
                "FROM chars WHERE charname = :name"
            ),
            {"name": "Awesome"},
        ).fetchone()
        if row is None:
            print("ERROR: character Awesome not found — aborting purge")
            return 1
        print(f"Keeping charid={row.charid} accid={row.accid} ({row.charname}, gm={row.gmlevel})")

        script = sql_path.read_text()
        # Drop full-line comments; keep statements that may follow inline comment blocks.
        lines = [
            line
            for line in script.splitlines()
            if line.strip() and not line.strip().startswith("--")
        ]
        for statement in "\n".join(lines).split(";"):
            stmt = statement.strip()
            if not stmt:
                continue
            if stmt.upper().startswith("SELECT IF("):
                result = conn.execute(text(stmt)).fetchone()
                print(result[0] if result else "purge_status check")
                continue
            conn.execute(text(stmt))
        conn.commit()

    print("Purge complete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
