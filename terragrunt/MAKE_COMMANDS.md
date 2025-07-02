# Make Commands Reference

## 基本的な使用方法

### ヘルプ表示
```bash
make
# または
make help
```

### 前提条件チェック
```bash
make init
```

## 開発環境

### 基本ワークフロー
```bash
# 1. プランを確認
make dev-plan

# 2. リソースを作成
make dev-apply

# 3. リソースを削除（必要な場合）
make dev-destroy
```

### インタラクティブワークフロー
```bash
# プラン確認後、適用するかを選択
make dev-workflow
```

## 本番環境

```bash
# プラン確認
make prod-plan

# リソース作成（確認プロンプト付き）
make prod-apply

# リソース削除（確認プロンプト付き）
make prod-destroy
```

## 管理・メンテナンス

### 初期セットアップ
```bash
# Terraformステート用リソースを作成
make setup-state
```

### 設定ファイル管理
```bash
# 設定ファイルの検証
make validate

# コードフォーマット
make format
```

### キャッシュ・クリーンアップ
```bash
# Terragrunt/Terraformキャッシュをクリア
make clean
```

### ステータス確認
```bash
# 全環境のリソース状況を確認
make status
```

## Makefileの特徴

### 安全性
- 本番環境操作には確認プロンプト
- 前提条件の自動チェック
- エラー時の適切な終了

### 利便性
- 環境別コマンドの簡略化
- 設定ファイルの自動検証
- キャッシュクリア機能

### ワークフロー
- インタラクティブな操作フロー
- ステータス確認機能
- 段階的な実行サポート

## 使用例

### 新規環境作成の完全フロー
```bash
# 1. 前提条件確認
make init

# 2. ステート用リソース作成（初回のみ）
make setup-state

# 3. 開発環境作成
make dev-plan
make dev-apply

# 4. 本番環境作成
make prod-plan
make prod-apply
```

### 日常的な開発フロー
```bash
# 開発環境での変更テスト
make dev-workflow

# 検証・フォーマット
make validate
make format

# ステータス確認
make status
```

### 環境削除
```bash
# 開発環境削除
make dev-destroy

# 本番環境削除（慎重に）
make prod-destroy
```
