# AWS認証情報テストガイド

## 🎯 概要

GitHub ActionsでAWS認証情報が正しく設定されているかを確認するためのワークフローです。

## 🚀 実行方法

### 1. GitHub Secretsの設定

まず、以下のシークレットがGitHubに設定されていることを確認してください：

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

**設定手順:**
1. GitHubリポジトリの **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** をクリック
3. 上記の2つのシークレットを追加

### 2. テストワークフローの実行

1. **Actions** タブに移動
2. **"AWS Credentials Test"** ワークフローを選択
3. **"Run workflow"** をクリック
4. **Detailed check** オプション：
   - `true`: 詳細な権限チェックを実行
   - `false`: 基本的な認証チェックのみ
5. **"Run workflow"** をクリックして実行

## 🔍 テスト内容

### 基本テスト
- ✅ GitHub Secretsの存在確認
- ✅ AWS STS認証テスト
- ✅ アカウント情報の取得
- ✅ S3権限の確認
- ✅ DynamoDB権限の確認

### 詳細テスト（オプション）
- 🔍 IAM権限の詳細確認
- 🔍 S3バケット作成権限テスト
- 🔍 DynamoDB操作権限テスト
- 🔍 Terragrunt前提条件チェック

## 📋 テスト結果の見方

### ✅ 成功パターン

```
=== Basic AWS Authentication Test ===
✅ AWS authentication successful

📋 Account Information:
   Account ID: xxx
   User ARN: xxx
   User ID: xxx

=== S3 Permissions Test ===
✅ S3 ListBuckets permission: OK
   Found 3 existing buckets

=== DynamoDB Permissions Test ===
✅ DynamoDB ListTables permission: OK
   Found 1 existing tables
```

### ❌ 失敗パターン

#### Secretsが設定されていない場合
```
❌ AWS_ACCESS_KEY_ID secret is NOT set
❌ AWS_SECRET_ACCESS_KEY secret is NOT set
```

#### 認証情報が間違っている場合
```
❌ AWS authentication failed
InvalidUserID.NotFound: The Access Key ID or security token is invalid
```

#### 権限が不足している場合
```
⚠️ S3 ListBuckets permission: Limited or denied
⚠️ DynamoDB ListTables permission: Limited or denied
```

## 🛠️ トラブルシューティング

### 1. Secret設定エラー

**問題:** GitHub Secretsが認識されない
```
AWS_ACCESS_KEY_ID secret is NOT set
```

**解決策:**
- Secret名が正確か確認（大文字小文字を含む）
- Secretに余分なスペースや改行がないか確認
- リポジトリレベルのSecretが設定されているか確認

### 2. 認証エラー

**問題:** AWS認証に失敗
```
InvalidUserID.NotFound: The Access Key ID or security token is invalid
```

**解決策:**
- AWS Access Key IDが正確か確認
- AWS Secret Access Keyが正確か確認
- IAMユーザーが有効化されているか確認
- アクセスキーが期限切れでないか確認

### 3. 権限エラー

**問題:** 特定のAWSサービスにアクセスできない
```
⚠️ S3 ListBuckets permission: Limited or denied
```

**解決策:**
- IAMポリシーを確認
- 必要な権限が付与されているか確認
- リソースのARNが正しいか確認

## 📝 必要なIAM権限

最小限必要な権限：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:GetCallerIdentity"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow", 
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "s3:CreateBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:ListTables",
                "dynamodb:DescribeTable",
                "dynamodb:CreateTable"
            ],
            "Resource": "*"
        }
    ]
}
```

## 🎯 次のステップ

### テストが成功した場合
1. ✅ メインのTerragruntワークフローを実行
2. ✅ `make setup-state` でTerraformステート管理の初期化
3. ✅ 実際のインフラ操作（plan/apply）を実行

### テストが失敗した場合
1. ❌ エラーメッセージを確認
2. ❌ GitHub Secretsの再設定
3. ❌ IAM権限の見直し
4. ❌ AWS認証情報の確認

## 🔄 定期的なメンテナンス

### 推奨事項
- 月1回の認証テスト実行
- 四半期ごとのアクセスキーローテーション
- 権限の最小化確認
- セキュリティログの監視

### 自動化オプション
```yaml
# 毎週月曜日にテストを実行
schedule:
  - cron: '0 9 * * 1'  # UTC 09:00 every Monday
```

このテストワークフローにより、AWS認証情報の問題を事前に発見し、安全にTerragruntワークフローを実行できます。
