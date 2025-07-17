# Docker Build and Push Scripts

このディレクトリには、DockerイメージのビルドとECRへのプッシュを行うスクリプトが含まれています。

## ファイル構成

```
scripts/
├── lib/
│   └── common.sh          # 共通関数とユーティリティ
├── build.sh               # ビルド専用スクリプト
├── push.sh                # プッシュ専用スクリプト
├── build-and-push.sh      # 統合スクリプト（ビルド→プッシュ）
└── SCRIPTS_README.md      # このファイル
```

## 使用方法

### 1. 統合スクリプト（推奨）
ビルドとプッシュを連続して実行:
```bash
./build-and-push.sh [dev|prod] [image-tag]
```

例:
```bash
./build-and-push.sh dev latest
./build-and-push.sh prod v1.0.0
```

### 2. 個別スクリプト

#### ビルドのみ
```bash
./build.sh [dev|prod] [image-tag]
```

#### プッシュのみ
```bash
./push.sh [dev|prod] [image-tag]
```

#### ビルド後にプッシュ
```bash
# ビルド実行
./build.sh dev latest

# 環境変数が設定されているので、引数なしでプッシュ可能
./push.sh
```

## 環境変数

### build.sh実行後に設定される変数
- `BUILT_IMAGE_NAME`: 完全なイメージ名
- `BUILT_REPOSITORY_NAME`: リポジトリ名
- `BUILT_IMAGE_TAG`: イメージタグ
- `BUILT_ECR_REGISTRY`: ECRレジストリURL
- `BUILT_AWS_REGION`: AWSリージョン

### push.sh用の設定変数
- `CLEANUP_LOCAL_IMAGES`: `true`に設定すると、プッシュ後にローカルイメージを削除

## 前提条件

1. AWS CLIが設定されていること
2. Dockerがインストールされていること
3. 適切なECRリポジトリが作成されていること

## 特徴

- **モジュール化**: 共通機能は`lib/common.sh`に集約
- **再利用性**: ビルドとプッシュを個別に実行可能
- **エラーハンドリング**: 各段階でエラーチェック
- **環境変数連携**: ビルド後の環境変数をプッシュ時に活用
- **色付きログ**: 視認性の高いログ出力
- **柔軟性**: 用途に応じてスクリプトを選択可能
