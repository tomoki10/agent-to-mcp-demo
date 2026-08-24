---
applyTo: '**/*.{py,toml,yml,yaml,sql,md}'
description: 'agent-to-mcp-demo の共通運用ルール。日本語、uv、Docker Compose、spec 参照方針を統一する。'
---

# Project Rules (agent-to-mcp-demo)

## Language

- 日本語で思考し、日本語で応答する。

## Tooling and Runtime

- Python は 3.11+ を前提とする。
- Python の依存関係管理は `uv` を使う（pip ワークフローへ切り替えない）。
- 標準コマンドは `uv sync`、`uv run ruff check .`、`uv run black .`、`uv run pytest`。

## Docker and Service Startup

- 基本の起動・停止は `docker compose up -d` と `docker compose down -v`。
- 障害調査時は `docker compose logs mysql` と `docker compose logs mcp-server` を優先する。
- MySQL が healthy になる前提で mcp-server が起動するため、起動直後の失敗は healthcheck 状態を確認する。

## Change Policy

- Docker サービス名・環境変数名は、明示的な要求がない限り維持する。
- 起動手順や設定を変更した場合は、同一変更で `spec/` 配下ドキュメントも更新する。
- 既存ドキュメントの内容を複製せず、詳細は `README.md` と `spec/` を参照する。
