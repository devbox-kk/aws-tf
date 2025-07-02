# aws-tf
AWS環境のIaC（Infrastructure as Code）環境

TerragruntとTerraformを使用してS3バケットを管理するプロジェクトです。

## 🚀 機能

- [x] Terragrunt実行ディレクトリ作成
- [x] S3バケット作成・管理
- [x] 環境別設定（dev/prod）
- [ ] plan/apply用action作成（予定）
- [ ] CodeBuildでのデプロイ実行を検討
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

詳細な使用方法は以下を参照：
- [USAGE.md](USAGE.md) - 基本的な使用方法
- [MAKE_COMMANDS.md](MAKE_COMMANDS.md) - Makeコマンドリファレンス

## 📦 作成されるリソース

- S3バケット
  - 暗号化有効（AES256）
  - バージョニング有効
  - パブリックアクセスブロック設定
  - 環境別タグ付け
