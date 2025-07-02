# GitHub Actions用AWS認証設定ガイド

## 🔧 AWS認証情報の設定手順

### 1. IAMユーザーの作成

1. **AWS Management Console** にログイン
2. **IAM** サービスに移動
3. **Users** → **Create user** をクリック
4. ユーザー名を入力（例：`github-actions-terragrunt`）
5. **Attach policies directly** を選択
6. 以下のポリシーをアタッチ：
   - カスタムポリシー（下記参照）

### 2. 必要なIAMポリシー

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "TerraformStateManagement",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:GetBucketVersioning",
                "s3:GetBucketLocation",
                "s3:CreateBucket",
                "s3:PutBucketVersioning",
                "s3:PutBucketEncryption",
                "s3:PutBucketPublicAccessBlock"
            ],
            "Resource": [
                "arn:aws:s3:::terraform-state-*",
                "arn:aws:s3:::terraform-state-*/*"
            ]
        },
        {
            "Sid": "DynamoDBStateLock",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:DescribeTable",
                "dynamodb:CreateTable"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
        },
        {
            "Sid": "S3ResourceManagement",
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:GetBucketLocation",
                "s3:GetBucketVersioning",
                "s3:GetBucketEncryption",
                "s3:GetBucketPublicAccessBlock",
                "s3:PutBucketVersioning",
                "s3:PutBucketEncryption",
                "s3:PutBucketPublicAccessBlock",
                "s3:ListBucket",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Sid": "GeneralPermissions",
            "Effect": "Allow",
            "Action": [
                "sts:GetCallerIdentity"
            ],
            "Resource": "*"
        }
    ]
}
```

### 3. アクセスキーの作成

1. 作成したユーザーをクリック
2. **Security credentials** タブ
3. **Create access key** をクリック
4. **Command Line Interface (CLI)** を選択
5. **Next** → **Create access key**
6. **Access key ID** と **Secret access key** をメモ

### 4. GitHub Secretsの設定

1. GitHubリポジトリに移動
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret** をクリック
4. 以下の2つのシークレットを作成：

#### AWS_ACCESS_KEY_ID
- **Name**: `AWS_ACCESS_KEY_ID`
- **Secret**: 上記で取得したAccess key ID

#### AWS_SECRET_ACCESS_KEY
- **Name**: `AWS_SECRET_ACCESS_KEY`
- **Secret**: 上記で取得したSecret access key

### 5. 設定の確認

GitHub Actionsでワークフローを手動実行して確認：

1. **Actions** タブ → **Terragrunt CI/CD**
2. **Run workflow** をクリック
3. 以下を設定：
   - Environment: `dev`
   - Action: `plan`
   - Target: `all`
   - Auto approve: チェックなし
4. **Run workflow** をクリック

### 6. トラブルシューティング

#### 認証エラーの場合
```
Error: Credentials could not be loaded
```

**確認項目:**
1. GitHub Secretsの名前が正確か（`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`）
2. Secret値にスペースや改行が含まれていないか
3. IAMユーザーのアクセスキーが有効か

#### 権限エラーの場合
```
Error: AccessDenied
```

**確認項目:**
1. IAMポリシーが正しくアタッチされているか
2. リソースのARNが正確か
3. アクション（Action）の権限が含まれているか

### 7. セキュリティのベストプラクティス

1. **最小権限の原則**: 必要最小限の権限のみ付与
2. **定期的なローテーション**: アクセスキーを定期的に更新
3. **モニタリング**: CloudTrailでAPI呼び出しを監視
4. **環境分離**: 本番環境用は別のIAMユーザーを使用

### 8. 本番環境用の追加設定

本番環境用には別のIAMユーザーを作成し、以下のSecretを追加：

- `PROD_AWS_ACCESS_KEY_ID`
- `PROD_AWS_SECRET_ACCESS_KEY`

ワークフローで環境に応じて使い分け可能です。

## 🔍 確認用コマンド

ローカルでAWS設定を確認：

```bash
# AWS認証情報の確認
aws sts get-caller-identity

# S3バケット一覧
aws s3 ls

# DynamoDBテーブル一覧
aws dynamodb list-tables --region ap-northeast-1
```

この設定により、GitHub ActionsからAWSリソースを安全に管理できます。
