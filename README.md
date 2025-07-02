# aws-tf
AWS環境のIaC（Infrastructure as Code）環境

TerragruntとTerraformを使用してS3バケットを管理するプロジェクトです。

## 🚀 機能

- [x] Terragrunt実行ディレクトリ作成
- [x] S3バケット作成・管理
- [x] 環境別設定（dev/prod）
- [x] GitHub Actions CI/CD パイプライン
- [x] 定期的なdev環境削除（コスト削減）
- [x] プルリクエスト時の自動plan実行
- [ ] tokenをapptokenにする

## 📁 プロジェクト構造

```
aws-tf/
├── README.md
└── terragrunt/
    ├── USAGE.md                    # 詳細な使用方法
    ├── MAKE_COMMANDS.md            # Makeコマンドリファレンス
    ├── Makefile                    # Make実行設定
    ├── run.sh                      # 実行スクリプト
    ├── root.hcl                    # ルート設定
    ├── modules/s3/             # S3 Terraformモジュール
    └── environments/           # 環境別設定
        ├── dev/s3/
        └── prod/s3/
```

## 🏃‍♂️ クイックスタート

### Method 1: Makeコマンド（推奨）
```bash
# 前提条件チェック
make init

# ステート用リソース作成（初回のみ）
make setup-state

# 開発環境作成
make dev-plan
make dev-apply
```

### Method 2: 実行スクリプト
```bash
./run.sh -e dev -a plan
./run.sh -e dev -a apply
```

## 🔄 GitHub Actions CI/CD

このプロジェクトはGitHub Actionsによる自動化されたCI/CDパイプラインを提供しています。

### 主な機能
- **手動実行**: plan/apply/destroy操作を手動でトリガー
- **自動plan**: プルリクエスト時に自動でplanを実行
- **定期destroy**: 毎日18時（UTC）にdev環境を自動削除
- **環境分離**: dev/prod環境を安全に管理

### セットアップ
1. GitHub Secretsに以下を設定：
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

2. ワークフローの実行：
   - Actions タブから "Terragrunt CI/CD" を選択
   - "Run workflow" で環境とアクションを選択

詳細は [GITHUB_ACTIONS_README.md](GITHUB_ACTIONS_README.md) を参照してください。

詳細な使用方法は以下を参照：
- [USAGE.md](terragrunt/USAGE.md) - 基本的な使用方法
- [MAKE_COMMANDS.md](terragrunt/MAKE_COMMANDS.md) - Makeコマンドリファレンス
- [GITHUB_ACTIONS_README.md](GITHUB_ACTIONS_README.md) - GitHub Actions設定ガイド

## 📦 作成されるリソース

- S3バケット
  - 暗号化有効（AES256）
  - バージョニング有効
  - パブリックアクセスブロック設定
  - 環境別タグ付け
