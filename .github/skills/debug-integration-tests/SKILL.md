---
name: debug-integration-tests
description: Use when integration test failures need triage, reproduction, root cause analysis, and a fix plan.
argument-hint: failing test name or error message
user-invocable: true
disable-model-invocation: false
---

# Debug Integration Tests

このスキルは統合テスト失敗の切り分けに使う。

手順:

1. 失敗テストを特定する
2. 再現手順を明確化する
3. ログと依存サービスを確認する
4. 根本原因を仮説化する
5. 最小修正案を出す
6. 必要なら追加テスト案を示す

確認項目:

- 環境差分
- DB 初期化
- 非同期タイミング
- 外部 API 依存
