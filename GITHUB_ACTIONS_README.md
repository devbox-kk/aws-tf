# GitHub Actions CI/CD for Terragrunt

このリポジトリでは、GitHub Actionsを使用してTerragruntの自動化されたCI/CDパイプラインを提供しています。

## 🚀 機能

- **手動実行**: plan/apply/destroy操作を手動でトリガー
- **自動plan**: プルリクエスト時に自動でplanを実行
- **定期destroy**: 毎日18時（UTC）にdev環境を自動削除
- **環境分離**: dev/prod環境を安全に管理
- **モジュール選択**: 特定のモジュール（s3など）のみ実行可能

## 🔧 セットアップ

### 1. AWS認証情報の設定

GitHubリポジトリのSettings > Secrets and variablesで以下のシークレットを設定してください：

```
AWS_ACCESS_KEY_ID     # AWSアクセスキーID
AWS_SECRET_ACCESS_KEY # AWSシークレットアクセスキー
```

### 2. IAMポリシー

GitHub Actions用のIAMユーザーには以下の権限が必要です：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "dynamodb:*",
                "sts:GetCallerIdentity"
            ],
            "Resource": "*"
        }
    ]
}
```

## 📋 使用方法

### 手動実行（workflow_dispatch）

1. GitHubリポジトリのActionsタブに移動
2. "Terragrunt CI/CD"ワークフローを選択
3. "Run workflow"をクリック
4. 以下のパラメータを設定：
   - **Environment**: `dev` または `prod`
   - **Action**: `plan`, `apply`, または `destroy`
   - **Target**: `all` または `s3`（特定モジュール）
   - **Auto approve**: apply/destroyの自動承認

### 自動実行

#### プルリクエスト時
- `terragrunt/`ディレクトリに変更がある場合、自動でdev環境のplanを実行
- 結果はプルリクエストにコメントで表示

#### プッシュ時（main/masterブランチ）
- `terragrunt/`ディレクトリに変更がある場合、dev環境のplanを実行

#### 定期実行（スケジュール）
- 毎日18時（UTC）にdev環境のリソースを自動削除
- 開発コストの削減に有効

## ⚠️ 注意事項

### セキュリティ

1. **本番環境**: 本番環境での操作は手動確認が入ります
2. **シークレット管理**: AWS認証情報は必ずGitHub Secretsを使用
3. **権限最小化**: IAMユーザーには必要最小限の権限のみ付与

### 運用

1. **時間設定**: destroyの定期実行時間はUTCで設定（JST + 9時間）
2. **環境変数**: CI環境では対話的な確認をスキップ
3. **状態管理**: Terraformステートは自動でS3とDynamoDBで管理

## 🔍 トラブルシューティング

### よくある問題

1. **AWS認証エラー**
   ```
   Error: NoCredentialsError
   ```
   → GitHub Secretsの設定を確認

2. **権限エラー**
   ```
   Error: AccessDenied
   ```
   → IAMユーザーの権限を確認

3. **ステートロックエラー**
   ```
   Error: Error acquiring the state lock
   ```
   → DynamoDBのterraform-state-lockテーブルを確認

### デバッグ方法

1. GitHub Actionsのログを確認
2. ローカルで同じコマンドを実行
3. AWS CloudTrailでAPI呼び出しを確認

## 📊 ワークフロー状態の確認

各実行後にリソースの状態が自動で確認され、ログに出力されます：

```bash
make status
```

## 🔄 カスタマイズ

### 実行時間の変更

`.github/workflows/terragrunt.yml`の`cron`設定を変更：

```yaml
schedule:
  - cron: '0 18 * * *'  # UTC 18:00 = JST 03:00
```

### 対象環境の変更

定期実行の対象環境を変更する場合：

```yaml
- name: Setup environment variables
  run: |
    if [ "${{ github.event_name }}" = "schedule" ]; then
      echo "ENVIRONMENT=dev" >> $GITHUB_ENV  # ここを変更
```

## 🏗️ 拡張

新しいモジュールを追加する場合：

1. `terragrunt/modules/`に新しいモジュールを追加
2. `terragrunt/environments/*/`に環境固有の設定を追加
3. ワークフローの`target`オプションに新しいモジュール名を追加

## 📝 ログとモニタリング

- すべての実行ログはGitHub Actionsで保存
- 重要な操作（apply/destroy）は詳細ログを出力
- エラー時は自動でslackやメール通知を設定可能（要カスタマイズ）
