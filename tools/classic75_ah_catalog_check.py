#!/usr/bin/env python3
"""Report AH catalog vs listings (auction_house_items vs auction_house)."""

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
        rows = conn.execute(
            text(
                "SELECT "
                "(SELECT COUNT(*) FROM auction_house_items) AS catalog, "
                "(SELECT COUNT(*) FROM auction_house WHERE buyer_name IS NULL AND sale = 0) AS listings, "
                "(SELECT COUNT(*) FROM auction_house_items ahi "
                " JOIN item_equipment ie ON ie.itemid = ahi.itemid WHERE ie.level > 75) AS catalog_over_75"
            )
        ).one()
        print(
            f"catalog={rows.catalog} active_listings={rows.listings} catalog_lvl76plus={rows.catalog_over_75}"
        )


if __name__ == "__main__":
    main()
