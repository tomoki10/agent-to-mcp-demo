"""パッケージが正しくインストールされていることを確認する最小テスト。

CI の lint ジョブで `uv run pytest` を実行するため、テストが 0 件だと
pytest が exit code 5 で失敗する。その回避も兼ねている。
"""

import mysql_mcp_demo


def test_package_is_importable() -> None:
    """`uv sync` 後にパッケージが import できる。"""
    assert mysql_mcp_demo.__name__ == "mysql_mcp_demo"
