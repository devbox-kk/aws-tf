# Terragrunt S3 プロジェクト使用方法

## 前提条件

1. AWS CLIがインストールされ、適切に設定されていること
2. Terragruntがインストールされていること
3. Terraformがインストールされていること

## インストール

### Terragruntのインストール
```bash
# Linux
curl -LO https://github.com/gruntwork-io/terragrunt/releases/download/v0.82.3/terragrunt_linux_amd64
chmod +x terragrunt_linux_amd64
sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# または
brew install terragrunt  # macOS
```

### Terraformのインストール
```bash
# tfenvを使用する場合
tfenv install 1.12.2
tfenv use 1.12.2
```

## AWS認証設定

```bash
# AWS CLIの設定
aws configure

# または環境変数で設定
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=ap-northeast-1
```

## 初回セットアップ

### 1. Terraformステート用S3バケットとDynamoDBテーブルの作成

```bash
# 手動でステート用リソースを作成
aws s3 mb s3://terraform-state-$(aws sts get-caller-identity --query Account --output text) --region ap-northeast-1

aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ap-northeast-1
```

## 使用方法

### Method 1: Makeコマンド（推奨）

```bash
# ヘルプ表示
make help

# 前提条件チェック
make init

# ステート用リソース作成（初回のみ）
make setup-state

# 開発環境
make dev-plan       # プラン表示
make dev-apply      # リソース作成
make dev-apply-auto # リソース作成（自動承認）
make dev-destroy    # リソース削除

# 本番環境（確認プロンプト付き）
make prod-plan      # プラン表示
make prod-apply     # リソース作成
make prod-apply-auto # リソース作成（自動承認）
make prod-destroy   # リソース削除

# メンテナンス
make validate       # 設定ファイル検証
make format         # コードフォーマット
make clean          # キャッシュクリア
make status         # ステータス確認
```

### Method 2: 実行スクリプト

```bash
# 開発環境のプラン実行
./run.sh -e dev -a plan

# 開発環境にリソース作成
./run.sh -e dev -a apply

# 開発環境にリソース作成（自動承認）
./run.sh -e dev -a apply -y

# 本番環境のプラン実行
./run.sh -e prod -a plan

# 本番環境にリソース作成
./run.sh -e prod -a apply

# 本番環境にリソース作成（自動承認）
./run.sh -e prod -a apply -y

# リソースの削除
./run.sh -e dev -a destroy

# リソースの削除（自動承認）
./run.sh -e dev -a destroy -y
```

### Method 3: Terragruntを直接実行

```bash
# 開発環境
cd terragrunt/environments/dev/s3
terragrunt init
terragrunt plan
terragrunt apply

# 本番環境
cd terragrunt/environments/prod/s3
terragrunt init
terragrunt plan
terragrunt apply
```

## プロジェクト構造

```
aws-tf/
├── README.md
├── run.sh                              # 実行スクリプト
├── USAGE.md                            # 使用方法
└── terragrunt/
    ├── root.hcl                        # ルート設定
    ├── modules/
    │   └── s3/                         # S3モジュール
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    └── environments/
        ├── dev/
        │   └── s3/
        │       └── terragrunt.hcl      # 開発環境設定
        └── prod/
            └── s3/
                └── terragrunt.hcl      # 本番環境設定
```

## 作成されるリソース

- S3バケット（暗号化、バージョニング有効）
- パブリックアクセスブロック設定

## トラブルシューティング

### エラー: バケット名が既に存在する
- バケット名はグローバルでユニークである必要があります
- 設定ファイルでランダムサフィックスを使用していますが、それでも競合する場合は手動で変更してください

### エラー: 認証情報が無効
```bash
aws sts get-caller-identity
```
で認証情報を確認してください

### エラー: Terragruntが見つからない
PATH環境変数にterragruntの実行ファイルパスが含まれているか確認してください
