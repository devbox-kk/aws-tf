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
- [x] 静的ウェブサイトホスティング対応
- [ ] tokenをapptokenにする

## 📁 プロジェクト構造

```
aws-tf/
├── README.md
├── deploy-website.sh              # 静的ウェブサイトデプロイスクリプト
├── sample-website/                # 静的ウェブサイトファイル
│   ├── index.html
│   ├── styles.css
│   ├── script.js
│   └── error.html
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

### 🌐 静的ウェブサイトデプロイ

このプロジェクトには、S3バケットに静的ウェブサイトをデプロイする機能が含まれています。

#### 対象ファイル
- `sample-website/index.html` - メインページ
- `sample-website/styles.css` - スタイルシート
- `sample-website/script.js` - JavaScriptファイル
- `sample-website/error.html` - エラーページ

#### デプロイ方法

**Option 1: 自動デプロイスクリプト**
```bash
# 開発環境にデプロイ
./deploy-website.sh dev

# 本番環境にデプロイ
./deploy-website.sh prod
```

**Option 2: 手動デプロイ**
```bash
# S3モジュールディレクトリに移動
cd terragrunt/environments/dev/s3

# 初期化
terragrunt init

# プランの確認
terragrunt plan

# デプロイ
terragrunt apply

# ウェブサイトURLの確認
terragrunt output website_endpoint
```

#### 設定のポイント
- 静的ウェブサイトホスティングを有効にするには、`enable_website_hosting = true` を設定
- パブリックアクセスを許可するには、`block_public_access = false` を設定
- バケットポリシーが自動的に設定され、ウェブサイトファイルへのパブリック読み取りアクセスが許可されます
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

2. **認証テストの実行**（推奨）：
   - Actions タブから "AWS Credentials Test" を選択
   - "Run workflow" で認証情報をテスト

3. ワークフローの実行：
   - Actions タブから "Terragrunt CI/CD" を選択
   - "Run workflow" で環境とアクションを選択

詳細は [GITHUB_ACTIONS_README.md](GITHUB_ACTIONS_README.md) を参照してください。

詳細な使用方法は以下を参照：
- [USAGE.md](terragrunt/USAGE.md) - 基本的な使用方法
- [MAKE_COMMANDS.md](terragrunt/MAKE_COMMANDS.md) - Makeコマンドリファレンス
- [GITHUB_ACTIONS_README.md](GITHUB_ACTIONS_README.md) - GitHub Actions設定ガイド
- [AWS_CREDENTIALS_TEST_GUIDE.md](.github/AWS_CREDENTIALS_TEST_GUIDE.md) - AWS認証テストガイド

## 📦 作成されるリソース

- S3バケット
  - 暗号化有効（AES256）
  - バージョニング有効
  - パブリックアクセスブロック設定（ウェブサイトホスティング時は調整）
  - 環境別タグ付け
  - 静的ウェブサイトホスティング対応
  - 自動ファイルアップロード（HTML, CSS, JavaScript）
