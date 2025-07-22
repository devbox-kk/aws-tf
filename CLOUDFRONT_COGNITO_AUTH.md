# CloudFront with Cognito Authentication

このプロジェクトでは、AWS CloudFrontとCognito User Poolを使用してS3バケットの静的ウェブサイトに認証機能を追加しています。

## アーキテクチャ

```
ユーザー → CloudFront → Lambda@Edge (認証) → S3 バケット
                ↓
            Cognito User Pool
```

## 構成要素

### 1. Cognito User Pool
- **場所**: `terragrunt/modules/cognito/`
- **機能**: ユーザー認証とトークン発行
- **設定**: メール認証、パスワードポリシー、OAuthフロー

### 2. Lambda@Edge認証関数
- **場所**: `terragrunt/modules/lambda-auth/`
- **機能**: CloudFrontリクエストの認証チェック
- **トリガー**: `viewer-request`イベント

### 3. CloudFront Distribution
- **場所**: `terragrunt/modules/cloudfront/`
- **機能**: CDN配信とLambda@Edge統合
- **認証**: 全てのリクエストに対して認証チェック

## デプロイ手順

### 1. 依存関係の順序
```bash
# 1. S3バケット
cd terragrunt/environments/dev/s3
terragrunt apply

# 2. CloudFront（認証なし）
cd ../cloudfront
terragrunt apply

# 3. Cognito User Pool
cd ../cognito
terragrunt apply

# 4. Lambda@Edge認証関数
cd ../lambda-auth
terragrunt apply

# 5. CloudFront（認証あり）
cd ../cloudfront
terragrunt apply
```

### 2. 環境別設定

#### Dev環境
- **Cognito Domain**: `dev-website-auth`
- **Price Class**: `PriceClass_100`
- **Callback URL**: `https://{cloudfront-domain}/callback`

#### Prod環境
- **Cognito Domain**: `prod-website-auth`
- **Price Class**: `PriceClass_All`
- **Callback URL**: `https://{cloudfront-domain}/callback`

## 認証フロー

### 1. 初回アクセス
1. ユーザーがCloudFrontにアクセス
2. Lambda@EdgeがJWTトークンをチェック
3. トークンがない場合、Cognito ログインページにリダイレクト
4. ユーザーがログイン
5. 認証後、元のページにリダイレクト

### 2. 認証済みアクセス
1. ユーザーがCloudFrontにアクセス
2. Lambda@EdgeがJWTトークンを検証
3. 有効な場合、S3リソースにアクセス許可

## ユーザー管理

### 1. Cognitoコンソールでユーザー作成
```bash
# AWS CLIでユーザー作成
aws cognito-idp admin-create-user \
    --user-pool-id {user-pool-id} \
    --username {username} \
    --user-attributes Name=email,Value={email} \
    --temporary-password {temp-password}
```

### 2. パスワードリセット
```bash
# パスワードリセット
aws cognito-idp admin-set-user-password \
    --user-pool-id {user-pool-id} \
    --username {username} \
    --password {new-password} \
    --permanent
```

## セキュリティ設定

### 1. パスワードポリシー
- 最小長: 8文字
- 大文字・小文字・数字・記号を含む

### 2. トークン設定
- ID Token: 1時間有効
- Access Token: 1時間有効
- Refresh Token: 30日有効

### 3. セッション管理
- HTTPOnly Cookie使用
- Secure フラグ有効
- SameSite=Strict

## トラブルシューティング

### 1. Lambda@Edge エラー
```bash
# CloudWatch Logsで確認
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/us-east-1.{function-name}
```

### 2. Cognito認証エラー
```bash
# User Pool設定確認
aws cognito-idp describe-user-pool --user-pool-id {user-pool-id}
```

### 3. CloudFrontキャッシュ問題
```bash
# キャッシュ無効化
aws cloudfront create-invalidation \
    --distribution-id {distribution-id} \
    --paths "/*"
```

## 監視とログ

### 1. CloudWatch Metrics
- Lambda@Edge実行数
- エラー率
- 実行時間

### 2. CloudWatch Logs
- Lambda@Edge関数ログ
- 認証エラーログ

### 3. X-Ray Tracing
- リクエストトレース
- パフォーマンス分析

## 注意事項

1. **Lambda@Edge制限**:
   - 関数サイズ: 1MB以下
   - メモリ: 128MB固定
   - タイムアウト: 5秒以下

2. **Cognito制限**:
   - ドメイン名はグローバルでユニーク
   - リージョンごとのUser Pool制限

3. **CloudFront制限**:
   - Lambda@EdgeはUS-East-1でのみデプロイ
   - 変更反映に時間がかかる場合がある

## カスタマイズ

### 1. 認証ページのカスタマイズ
- CognitoホストUIをカスタマイズ
- カスタムCSS適用

### 2. 追加認証ロジック
- Lambda@Edge関数を拡張
- 複数認証プロバイダー対応

### 3. セッション管理
- Redis/DynamoDBでセッション管理
- より複雑な認証ロジック
