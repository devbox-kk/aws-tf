# ECR + HelloWorld Webサーバー + ECS Fargate デプロイガイド

このプロジェクトでは、AWS ECRリポジトリを作成し、HelloWorldを返すwebサーバーコンテナのイメージをECRにプッシュして、ECS Fargateでデプロイする完全な構成を提供しています。

## 構成

### インフラストラクチャ

- **VPCモジュール** (`terragrunt/modules/vpc/`)
  - VPC、サブネット、インターネットゲートウェイの作成
  - パブリック・プライベートサブネットの設定
  - NAT Gateway（本番環境のみ）

- **ECRモジュール** (`terragrunt/modules/ecr/`)
  - ECRリポジトリの作成
  - ライフサイクルポリシーの設定
  - イメージスキャン設定

- **ECSモジュール** (`terragrunt/modules/ecs/`)
  - ECS Fargateクラスターの作成
  - タスク定義とサービスの設定
  - CloudWatchログ設定
  - IAMロール設定

- **環境設定**
  - 開発環境 (`terragrunt/environments/dev/`)
  - 本番環境 (`terragrunt/environments/prod/`)

### アプリケーション

- **HelloWorld Webサーバー** (`docker/helloworld/`)
  - Python Flask ベースのwebサーバー
  - `GET /` で "Hello World!" を返す
  - `GET /health` でヘルスチェックエンドポイント
  - ポート 8080 で動作

## 使用方法

### 1. 前提条件の確認

```bash
cd terragrunt
make init
```

必要なツール:
- AWS CLI (設定済み)
- Terraform
- Terragrunt
- Docker

### 2. 開発環境への完全デプロイ

ECRリポジトリ作成 + Dockerイメージプッシュを一括実行:

```bash
make deploy-dev-complete
```

または段階的に実行:

```bash
# ECRリポジトリのみ作成
target=ecr make dev-apply

# Dockerイメージをビルド&プッシュ
make build-and-push-dev
```

### 3. 本番環境への完全デプロイ

```bash
make deploy-prod-complete
```

### 4. 特定バージョンのイメージをプッシュ

```bash
IMAGE_TAG=v1.0.0 make build-and-push-dev
IMAGE_TAG=v1.0.0 make build-and-push-prod
```

### 5. ローカルでのテスト

Dockerイメージをローカルでビルド・テスト:

```bash
# ビルド
make build-dev

# 実行
docker run -p 8080:8080 helloworld-dev:latest

# テスト
curl http://localhost:8080
curl http://localhost:8080/health
```

## コマンド一覧

### Terraform/Terragrunt関連

```bash
# プラン確認
target=ecr make dev-plan
target=ecr make prod-plan

# リソース作成
target=ecr make dev-apply
target=ecr make prod-apply

# リソース削除
target=ecr make dev-destroy
target=ecr make prod-destroy

# 状況確認
make status
```

### Docker/ECR関連

```bash
# ローカルビルド
make build-dev
make build-prod

# ECRにプッシュ
make build-and-push-dev
make build-and-push-prod

# 完全デプロイ
make deploy-dev-complete
make deploy-prod-complete
```

## ディレクトリ構造

```
aws-tf/
├── terragrunt/
│   ├── Makefile                    # 管理コマンド
│   ├── run.sh                      # Terragrunt実行スクリプト
│   ├── root.hcl                    # 共通設定
│   ├── modules/
│   │   ├── s3/                     # S3モジュール
│   │   └── ecr/                    # ECRモジュール
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       ├── dev/
│       │   ├── s3/
│       │   └── ecr/                # 開発環境ECR設定
│       └── prod/
│           ├── s3/
│           └── ecr/                # 本番環境ECR設定
├── docker/
│   └── helloworld/                 # HelloWorldアプリケーション
│       ├── Dockerfile
│       ├── app.py
│       └── requirements.txt
└── scripts/
    └── build-and-push.sh           # Docker ビルド&プッシュスクリプト
```

## ECR設定の違い

### 開発環境
- イメージタグ: MUTABLE（同じタグで上書き可能）
- ライフサイクル: 最新10イメージを保持
- 未タグイメージ: 1日後に削除

### 本番環境
- イメージタグ: IMMUTABLE（上書き不可）
- ライフサイクル: 最新20イメージを保持
- 未タグイメージ: 3日後に削除

## トラブルシューティング

### Dockerのlegacy builderの警告について

現在の設定では、古いDocker builderの警告が表示されますが、これは正常です。この警告を解消するには以下の方法があります：

#### 方法1: Docker BuildKitを有効にする（推奨）

1. Docker buildxをインストール:
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install docker-buildx-plugin

# または手動インストール
mkdir -p ~/.docker/cli-plugins/
curl -SL "https://github.com/docker/buildx/releases/latest/download/buildx-linux-amd64" -o ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx
```

2. Makefileを以下のように修正:
```makefile
# DOCKER_BUILDKIT=0 を DOCKER_BUILDKIT=1 に変更
DOCKER_BUILDKIT=1 docker build -t helloworld-dev:$$IMAGE_TAG ../docker/helloworld
```

#### 方法2: 警告を無視して現在の設定を続行

現在の設定（DOCKER_BUILDKIT=0）のまま使用しても、機能的には問題ありません。BuildKitの機能が不要な場合はこのまま使用できます。

### ECRログインエラー
```bash
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-northeast-1.amazonaws.com
```

### イメージプッシュエラー
ECRリポジトリが作成されているか確認:
```bash
make status
```

### Docker関連エラー
Dockerデーモンが動作しているか確認:
```bash
docker ps
```

## セキュリティベストプラクティス

1. **イメージスキャン**: 有効化済み（プッシュ時に脆弱性スキャン）
2. **ライフサイクルポリシー**: 古いイメージの自動削除
3. **タグ戦略**: 本番環境では IMMUTABLE タグを使用
4. **最小権限**: 必要最小限のIAM権限のみ使用
