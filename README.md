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

### テーブル（8テーブル）

- **users**: ユーザー情報（ID、名前、メール、年齢、部署）
- **categories**: 商品カテゴリ（階層構造、親カテゴリへの自己参照）
- **products**: 商品情報（ID、名前、価格、在庫、カテゴリID、説明）
- **coupons**: クーポン情報（コード、割引種別、割引額、有効期限）
- **orders**: 注文情報（ID、ユーザーID、クーポンID、小計、割引額、合計金額、ステータス）
- **order_items**: 注文明細（注文ID、商品ID、数量、単価）
- **shipping**: 配送情報（注文ID、住所、配送業者、発送日、届け日）
- **reviews**: 商品レビュー（ユーザーID、商品ID、星評価、コメント）

### ビュー

- **order_summary**: 注文サマリー（顧客名、注文日、ステータス、金額、商品数、クーポンコード）

## 🎯 使用方法

GitHub Copilot Chat / Claude Code で以下のようなクエリを試してみてください：

### 基本的なクエリ

- "ユーザー一覧を表示してください"
- "在庫が20個以下の商品を価格の高い順に教えてください"

### JOIN・集約クエリ

- "各商品の平均レビュー評価を教えてください"
- "現在有効なクーポンの一覧を表示してください"

### 多段JOINクエリ

- "田中太郎さんが購入した商品の一覧と各商品の金額を表示してください"
- "カテゴリ別の売上合計を教えてください"

### CASE式・サブクエリ

- "各注文の割引内容を表示してください（パーセント割引ならXX%OFF、固定額ならXXXX円引き、クーポンなしなら割引なし）"
- "平均注文金額より高い注文をしたユーザーを教えてください"

### 高度な分析クエリ

- "月別の売上推移と、各月の注文件数、平均注文単価を教えてください"
- "レビュー評価が4以上の商品だけを買っているユーザーで、合計購入額が5万円以上の人を教えてください"
- "配送に3日以上かかった注文について、ユーザー名、商品名、配送業者、所要日数を教えてください"

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
