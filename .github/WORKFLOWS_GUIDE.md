# GitHub Actions Workflows 設定概要

## 📁 ワークフローファイル構成

```
.github/workflows/
├── terragrunt.yml              # メインワークフロー（plan/apply/destroy）
└── destroy-dev-scheduled.yml   # 定期削除専用ワークフロー
```

## 🔄 ワークフロートリガー

### 1. terragrunt.yml（メインワークフロー）

| トリガー | 条件 | アクション |
|---------|------|----------|
| `workflow_dispatch` | 手動実行 | plan/apply/destroy（選択可能） |
| `pull_request` | `terragrunt/**`への変更 | dev環境でplan実行 |
| `push` | `main/master`ブランチの`terragrunt/**` | dev環境でplan実行 |
| `schedule` | 毎日18時（UTC） | dev環境のdestroy |

### 2. destroy-dev-scheduled.yml（定期削除専用）

| トリガー | 条件 | アクション |
|---------|------|----------|
| `schedule` | 毎日18時（UTC） | dev環境のdestroy |
| `workflow_dispatch` | 手動実行 | dev環境のdestroy |

## ⚙️ 環境変数

### 自動設定される環境変数

```bash
# AWS設定
AWS_DEFAULT_REGION=ap-northeast-1
TF_INPUT=false
TF_IN_AUTOMATION=true

# CI検出
CI=true
GITHUB_ACTIONS=true
```

### 実行時に設定される変数

| 変数 | 値 | 説明 |
|-----|----|----|
| `ENVIRONMENT` | `dev`/`prod` | 対象環境 |
| `ACTION` | `plan`/`apply`/`destroy` | 実行アクション |
| `TARGET` | `all`/`s3` | 対象モジュール |
| `AUTO_APPROVE` | `true`/`false` | 自動承認フラグ |

## 🎯 実行パターン

### パターン1: 手動でdev環境にplan実行
```
trigger: workflow_dispatch
inputs:
  environment: dev
  action: plan
  target: all
  auto_approve: false
```

### パターン2: プルリクエスト時の自動plan
```
trigger: pull_request (terragrunt/**)
environment: dev
action: plan
target: all
auto_approve: false
```

### パターン3: 定期削除（夜間）
```
trigger: schedule (cron: '0 18 * * *')
environment: dev
action: destroy
target: all
auto_approve: true
```

### パターン4: 本番環境への適用
```
trigger: workflow_dispatch
inputs:
  environment: prod
  action: apply
  target: s3
  auto_approve: false
```

## 🔒 セキュリティ機能

### 1. 環境分離
- dev環境: 自動化対応、対話確認なし
- prod環境: 手動実行のみ、追加確認あり

### 2. 権限管理
- GitHub Secrets使用
- 最小権限IAMポリシー
- 実行ログの自動記録

### 3. 安全装置
- 本番環境は手動確認必須
- 実行前後のリソース状態確認
- 失敗時の自動通知

## 📊 モニタリング

### ログ出力
- 実行前後のリソース状態
- エラー詳細とスタックトレース
- 実行時間とパフォーマンス

### 通知機能
- プルリクエストへのplan結果コメント
- 失敗時のIssue自動作成
- Slack通知（要カスタマイズ）

## 🚀 カスタマイズポイント

### 1. 実行時間の変更
```yaml
schedule:
  - cron: '0 9 * * *'  # UTC 9:00 = JST 18:00
```

### 2. 通知先の追加
```yaml
- name: Slack notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### 3. 環境保護の追加
```yaml
jobs:
  terragrunt:
    environment: production  # GitHub環境保護
```

### 4. 承認フローの追加
```yaml
- name: Wait for approval
  uses: trstringer/manual-approval@v1
  if: env.ENVIRONMENT == 'prod'
```

## 💡 ベストプラクティス

### 1. シークレット管理
- 環境ごとにシークレットを分離
- 定期的なキーローテーション
- 最小権限の原則

### 2. 実行制御
- 本番環境は手動トリガーのみ
- 重要な操作は複数人チェック
- ロールバック手順の文書化

### 3. コスト管理
- 開発環境の定期削除
- リソース作成の事前承認
- 使用量モニタリング

### 4. 監査とコンプライアンス
- 全操作のログ保存
- 変更履歴の追跡
- 定期的なセキュリティレビュー
