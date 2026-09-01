# AGENTS.md

このファイルは、AIコーディングエージェント（GitHub Copilot Coding Agent、Claude Code など）がこのリポジトリで作業する際のガイドラインを記載します。

## プロジェクト概要

MySQL MCP（Model Context Protocol）デモプロジェクト。Docker Compose で MySQL を起動し、MCP サーバー経由で AI エージェントがデータベースにアクセスできる環境を提供します。

## 共通ルール

詳細は `.github/instructions/pj-rule.instructions.md` を参照してください。

- **言語**: 日本語で思考・応答する
- **Python**: 3.11+ / パッケージ管理は `uv` を使用
- **Docker**: `docker compose up -d` / `docker compose down -v`

## よく使うコマンド

```bash
# 依存関係インストール
uv sync

# リント
uv run ruff check .

# フォーマット
uv run black .

# テスト
uv run pytest

# サービス起動
docker compose up -d

# サービス停止
docker compose down -v

# ログ確認
docker compose logs mysql
docker compose logs mcp-server
```

## ドキュメント参照先

- `README.md` — セットアップ手順・使用方法
- `spec/` — 詳細仕様・アーキテクチャ・設定・トラブルシューティング

## 変更ポリシー

- Docker サービス名・環境変数名は明示的な要求がない限り変更しない
- 起動手順や設定を変更した場合は `spec/` 配下のドキュメントも同時に更新する
- 既存ドキュメントの内容を複製しない
