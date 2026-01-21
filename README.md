# GitHub Copilot /Claude Code MySQL MCP Demo

このプロジェクトは、GitHub Copilot/Claude Code/KiroでMySQL MCP（Model Context Protocol）を使用するデモです。GitHub Copilot Chat/Claude Code/KiroからMySQLデータベースに直接アクセスしてクエリを実行できます。

## 簡易手順

```bash
# コンテナ起動
docker compose up -d
claude
# 接続確認
/mcp
# 実行テスト
MCPを使ってユーザ情報を取得して

# コンテナ停止
docker compose down -v
```

## 🎯 概要

- **Docker Compose**: MySQLデータベースを簡単にセットアップ
- **MySQL MCP**: GitHub CopilotからMySQLにアクセス
- **サンプルデータ**: ユーザー、商品、注文データを含む実用的な例

## 📋 前提条件

以下がインストールされている必要があります：

- Docker & Docker Compose
- Visual Studio Code
- GitHub Copilot Extension or Claude Code

## 💾 データベース構造

### テーブル

- **users**: ユーザー情報（ID、名前、メール、年齢、部署）
- **products**: 商品情報（ID、名前、価格、在庫、カテゴリ、説明）
- **orders**: 注文情報（ID、ユーザーID、商品ID、数量、合計金額、ステータス）

### ビュー

- **order_summary**: 注文の詳細情報（顧客名、商品名、数量、金額、ステータス）

## 🎯 使用方法

GitHub Copilot Chat / Claude Code で以下のようなクエリを試してみてください：

### 基本的なクエリ

- "ユーザー一覧を表示してください"
- "商品テーブルの構造を教えてください"
- "注文テーブルの中身を見せてください"

### 分析クエリ

- "在庫が30個以下の商品を教えてください"
- "価格が10,000円以上の商品を見つけてください"
- "開発部のユーザーを表示してください"
- "注文状況別の件数を教えてください"

### 複雑なクエリ

- "田中太郎さんの注文履歴を表示してください"
- "最も人気のある商品を教えてください"
- "部署別の注文金額の合計を計算してください"
- "今月の売上トップ3の商品を教えてください"

### データベース操作

- "新しいユーザーを追加してください"
- "商品の在庫を更新してください"
- "注文ステータスを変更してください"

## 🐛 トラブルシューティング

### MySQL接続エラー

1. **コンテナが完全に起動するまで待つ**

   ```bash
   docker-compose logs mysql
   ```

2. **ポート3306が使用中**

   ```bash
   # 使用中のポートを確認
   lsof -i :3306
   
   # docker-compose.ymlでポートを変更
   ports:
     - "3307:3306"  # 3307に変更
   ```

3. **MCP設定ファイルの確認**

- GitHub Copilot Chat: .vscode/mcp.json
- Claude Code: .mcp.json

## 📚 参考資料

- [Model Context Protocol](https://github.com/modelcontextprotocol)
- [MySQL MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/mysql)
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)

## 🤝 貢献

バグ報告や機能要望は、GitHubのIssueでお知らせください。

## 📄 ライセンス

MIT License
