# Terragrunt Makefile
# AWS S3およびECR環境の管理用

.PHONY: help dev-plan dev-apply dev-apply-auto dev-destroy prod-plan prod-apply prod-apply-auto prod-destroy init clean validate format status dev-workflow build-dev build-prod build-and-push-dev build-and-push-prod deploy-dev-complete deploy-prod-complete get-alb-url-dev get-alb-url-prod get-cloudfront-url-dev get-cloudfront-url-prod

# デフォルトターゲット
help:
	@echo "Terragrunt プロジェクト 管理コマンド"
	@echo ""
	@echo "開発環境:"
	@echo "  make dev-plan      - 開発環境のプランを表示"
	@echo "  make dev-apply     - 開発環境にリソースを作成"
	@echo "  make dev-apply-auto - 開発環境にリソースを作成（自動承認）"
	@echo "  make dev-destroy   - 開発環境のリソースを削除"
	@echo ""
	@echo "本番環境:"
	@echo "  make prod-plan     - 本番環境のプランを表示"
	@echo "  make prod-apply    - 本番環境にリソースを作成"
	@echo "  make prod-apply-auto - 本番環境にリソースを作成（自動承認）"
	@echo "  make prod-destroy  - 本番環境のリソースを削除"
	@echo ""
	@echo "Docker & ECR:"
	@echo "  make build-dev     - 開発環境用Dockerイメージをビルド"
	@echo "  make build-prod    - 本番環境用Dockerイメージをビルド"
	@echo "  make build-and-push-dev  - 開発環境にビルド&プッシュ"
	@echo "  make build-and-push-prod - 本番環境にビルド&プッシュ"
	@echo ""
	@echo "完全デプロイ (VPC + ECR + ECS Fargate):"
	@echo "  make deploy-dev-complete  - 開発環境の完全デプロイ"
	@echo "  make deploy-prod-complete - 本番環境の完全デプロイ"
	@echo "  make deploy-infra-dev     - 開発環境のインフラのみデプロイ"
	@echo "  make deploy-infra-prod    - 本番環境のインフラのみデプロイ"
	@echo ""
	@echo "アクセス情報:"
	@echo "  make get-alb-url-dev      - 開発環境のALB URLを取得"
	@echo "  make get-alb-url-prod     - 本番環境のALB URLを取得"
	@echo "  make get-cloudfront-url-dev  - 開発環境のCloudFront URLを取得"
	@echo "  make get-cloudfront-url-prod - 本番環境のCloudFront URLを取得"
	@echo ""
	@echo "環境変数:"
	@echo "  target=source      - 特定のモジュール（ECR、S3）のみ実行"
	@echo "  target=iam         - 特定のモジュール（IAM）のみ実行"
	@echo "  target=network     - 特定のモジュール（VPC、SG、LB）のみ実行"
	@echo "  target=log         - 特定のモジュール（CloudWatch）のみ実行"
	@echo "  target=servise_staticweb  - 特定のモジュール（CloudFront、Cognito）のみ実行"
	@echo "  target=servise_dynamicweb - 特定のモジュール（ECS）のみ実行"
	@echo "  target=all         - 全モジュール実行（デフォルト）"
	@echo "  IMAGE_TAG=v1.0.0   - Dockerイメージのタグ（デフォルト: latest）"
	@echo ""
	@echo "使用例:"
	@echo "  target=source make dev-plan      - ソースモジュール（ECR、S3）のみプラン"
	@echo "  target=iam make dev-apply        - IAMモジュールのみ適用"
	@echo "  target=network make dev-apply    - ネットワークモジュール（VPC、SG、LB）のみ適用"
	@echo "  target=log make dev-apply        - ログモジュール（CloudWatch）のみ適用"
	@echo "  target=servise_staticweb make dev-apply  - 静的Webサービスモジュールのみ適用"
	@echo "  target=servise_dynamicweb make dev-apply - 動的Webサービスモジュール（ECS）のみ適用"
	@echo "  IMAGE_TAG=v1.0.0 make build-and-push-dev - 特定タグでビルド&プッシュ"
	@echo ""
	@echo "その他:"
	@echo "  make init          - 必要な前提条件をチェック"
	@echo "  make validate      - 設定ファイルの検証"
	@echo "  make format        - 設定ファイルのフォーマット"
	@echo "  make clean         - Terragrunt/Terraformキャッシュをクリア"
	@echo "  make status        - 全環境のリソース状況を確認"
	@echo "  make setup-state   - Terraformステート用リソースを作成"
	@echo "  make dev-workflow  - 開発環境での完全なワークフロー（plan→apply）"
	@echo ""
	@echo "注意:"
	@echo "  - 従来のDocker builderを使用します（BuildKit無効）"
	@echo "  - Dockerバージョン 20.10+ を推奨します"
	@echo "  - BuildKitを使用する場合は docker buildx をインストールしてください"

# 前提条件チェック
init:
	@echo "=== 前提条件チェック ==="
	@command -v aws >/dev/null 2>&1 || { echo "AWS CLIがインストールされていません"; exit 1; }
	@command -v terragrunt >/dev/null 2>&1 || { echo "Terragruntがインストールされていません"; exit 1; }
	@command -v terraform >/dev/null 2>&1 || { echo "Terraformがインストールされていません"; exit 1; }
	@command -v docker >/dev/null 2>&1 || { echo "Dockerがインストールされていません"; exit 1; }
	@aws sts get-caller-identity >/dev/null 2>&1 || { echo "AWS認証情報が設定されていません"; exit 1; }
	@echo "Docker BuildKit: disabled (legacy builder)"
	@echo "✅ 全ての前提条件が満たされています"

# Terraformステート用リソースの作成
setup-state:
	@echo "=== Terraformステート用リソースを作成中 ==="
	@ACCOUNT_ID=$$(aws sts get-caller-identity --query Account --output text); \
	aws s3 mb s3://terraform-state-$$ACCOUNT_ID --region ap-northeast-1 2>/dev/null || echo "S3バケットは既に存在します"; \
	aws dynamodb describe-table --table-name terraform-state-lock --region ap-northeast-1 >/dev/null 2>&1 || \
	aws dynamodb create-table \
		--table-name terraform-state-lock \
		--attribute-definitions AttributeName=LockID,AttributeType=S \
		--key-schema AttributeName=LockID,KeyType=HASH \
		--provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
		--region ap-northeast-1
	@echo "✅ ステート用リソースの準備完了"

# 開発環境 - プラン
dev-plan: init
	@echo "=== Terragrunt plan を実行中 (環境: dev) ==="
	@export target=$${target:-all}; ../scripts/terragrunt_run.sh -e dev -a plan

# 開発環境 - 適用
dev-apply: init
	@echo "=== Terragrunt apply を実行中 (環境: dev) ==="
	@export target=$${target:-all}; ../scripts/terragrunt_run.sh -e dev -a apply

# 開発環境 - 適用（自動承認）
dev-apply-auto: init
	@echo "=== Terragrunt apply を実行中 (環境: dev, 自動承認) ==="
	@export target=$${target:-all}; ../scripts/terragrunt_run.sh -e dev -a apply -y

# 開発環境 - 削除
dev-destroy: init
	@if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
		echo "⚠️  開発環境のリソースを削除中（CI環境）"; \
		export target=$${target:-all}; ../scripts/terragrunt_run.sh -e dev -a destroy -y; \
	else \
		echo "⚠️  開発環境のリソースを削除しようとしています"; \
		read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }; \
		export target=$${target:-all}; ../scripts/terragrunt_run.sh -e dev -a destroy -y; \
	fi

# 本番環境 - プラン
prod-plan: init
	@echo "=== Terragrunt plan を実行中 (環境: prod) ==="
	@export target=$${target:-all}; ../scripts/terragrunt_run.sh -e prod -a plan

# 本番環境 - 適用
prod-apply: init
	@if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
		echo "⚠️  本番環境にリソースを作成中（CI環境）"; \
		export target=$${target:-all}; ../scripts/terragrunt_run.sh -e prod -a apply; \
	else \
		echo "⚠️  本番環境にリソースを作成しようとしています"; \
		read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }; \
		export target=$${target:-all}; ../scripts/terragrunt_run.sh -e prod -a apply; \
	fi

# 本番環境 - 適用（自動承認）
prod-apply-auto: init
	@if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
		echo "⚠️  本番環境にリソースを作成中（CI環境、自動承認）"; \
		export target=$${target:-all}; ../scripts/terragrunt_run.sh -e prod -a apply -y; \
	else \
		echo "⚠️  本番環境にリソースを作成しようとしています（自動承認）"; \
		read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }; \
		export target=$${target:-all}; ../scripts/terragrunt_run.sh -e prod -a apply -y; \
	fi

# 本番環境 - 削除
prod-destroy: init
	@if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
		echo "🚨 本番環境のリソースを削除中（CI環境）"; \
		export target=$${target:-all}; ../scripts/terragrunt_run.sh -e prod -a destroy -y; \
	else \
		echo "🚨 本番環境のリソースを削除しようとしています"; \
		read -p "本当に続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }; \
		export target=$${target:-all}; ../scripts/terragrunt_run.sh -e prod -a destroy -y; \
	fi

# 設定ファイルの検証
validate:
	@echo "=== 設定ファイルの検証中 ==="
	@find -name "*.hcl" -exec echo "検証中: {}" \; -exec terragrunt hcl format --check {} \; || true
	@find -name "*.tf" -exec echo "検証中: {}" \; -exec terraform fmt -check {} \; || true
	@echo "✅ 検証完了"

# フォーマット
format:
	@echo "=== ファイルフォーマット中 ==="
	@find -name "*.hcl" -exec terragrunt hcl format {} \;
	@find -name "*.tf" -exec terraform fmt {} \;
	@echo "✅ フォーマット完了"

# キャッシュクリア
clean:
	@echo "=== キャッシュクリア中 ==="
	@find -name ".terragrunt-cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@find -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find -name "*.tfstate*" -type f -exec rm -f {} + 2>/dev/null || true
	@find -name ".terraform.lock.hcl" -type f -exec rm -f {} + 2>/dev/null || true
	@echo "✅ キャッシュクリア完了"

# 全環境のステータス確認
status:
	@echo "=== 環境ステータス確認 ==="
	@echo "現在のディレクトリ: $$(pwd)"
	@echo "environments/devの内容:"
	@ls -la ./environments/dev || echo "開発環境ディレクトリが見つかりません"
	@echo ""
	@TARGET=$${target:-all}; \
	if [ "$$TARGET" = "all" ]; then \
		echo "=== 開発環境 (全モジュール) ==="; \
		if [ -d "./environments/dev" ]; then \
			echo "ディレクトリ: ./environments/dev"; \
			cd ./environments/dev && \
			( \
				STATE_OUTPUT=$$(terragrunt state list --terragrunt-non-interactive 2>&1); \
				STATE_EXIT_CODE=$$?; \
				if [ $$STATE_EXIT_CODE -eq 0 ] && echo "$$STATE_OUTPUT" | grep -q .; then \
					echo "リソース一覧:"; \
					echo "$$STATE_OUTPUT" | sed 's/^/  /'; \
				else \
					if [ $$STATE_EXIT_CODE -ne 0 ]; then \
						echo "  初期化エラー (exit code: $$STATE_EXIT_CODE)"; \
						if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
							echo "  エラー詳細: $$STATE_OUTPUT"; \
						fi; \
					else \
						echo "  リソースなし、または初期化が必要"; \
					fi; \
				fi; \
			); \
		else \
			echo "  開発環境ディレクトリが存在しません"; \
		fi; \
		echo ""; \
		echo "=== 本番環境 (全モジュール) ==="; \
		if [ -d "./environments/prod" ]; then \
			echo "ディレクトリ: ./environments/prod"; \
			cd ./environments/prod && \
			( \
				STATE_OUTPUT=$$(terragrunt state list --terragrunt-non-interactive 2>&1); \
				STATE_EXIT_CODE=$$?; \
				if [ $$STATE_EXIT_CODE -eq 0 ] && echo "$$STATE_OUTPUT" | grep -q .; then \
					echo "リソース一覧:"; \
					echo "$$STATE_OUTPUT" | sed 's/^/  /'; \
				else \
					if [ $$STATE_EXIT_CODE -ne 0 ]; then \
						echo "  初期化エラー (exit code: $$STATE_EXIT_CODE)"; \
						if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
							echo "  エラー詳細: $$STATE_OUTPUT"; \
						fi; \
					else \
						echo "  リソースなし、または初期化が必要"; \
					fi; \
				fi; \
			); \
		else \
			echo "  本番環境ディレクトリが存在しません"; \
		fi; \
	else \
		echo "=== 開発環境 ($$TARGET モジュール) ==="; \
		if [ -d "./environments/dev/$$TARGET" ]; then \
			echo "ディレクトリ: ./environments/dev/$$TARGET"; \
			cd "./environments/dev/$$TARGET" && \
			( \
				STATE_OUTPUT=$$(terragrunt state list --terragrunt-non-interactive 2>&1); \
				STATE_EXIT_CODE=$$?; \
				if [ $$STATE_EXIT_CODE -eq 0 ] && echo "$$STATE_OUTPUT" | grep -q .; then \
					echo "リソース一覧:"; \
					echo "$$STATE_OUTPUT" | sed 's/^/  /'; \
				else \
					if [ $$STATE_EXIT_CODE -ne 0 ]; then \
						echo "  初期化エラー (exit code: $$STATE_EXIT_CODE)"; \
						if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
							echo "  エラー詳細: $$STATE_OUTPUT"; \
						fi; \
					else \
						echo "  リソースなし、または初期化が必要"; \
					fi; \
				fi; \
			); \
		else \
			echo "  モジュールディレクトリが存在しません: ./environments/dev/$$TARGET"; \
		fi; \
		echo ""; \
		echo "=== 本番環境 ($$TARGET モジュール) ==="; \
		if [ -d "./environments/prod/$$TARGET" ]; then \
			echo "ディレクトリ: ./environments/prod/$$TARGET"; \
			cd "./environments/prod/$$TARGET" && \
			( \
				STATE_OUTPUT=$$(terragrunt state list --terragrunt-non-interactive 2>&1); \
				STATE_EXIT_CODE=$$?; \
				if [ $$STATE_EXIT_CODE -eq 0 ] && echo "$$STATE_OUTPUT" | grep -q .; then \
					echo "リソース一覧:"; \
					echo "$$STATE_OUTPUT" | sed 's/^/  /'; \
				else \
				 if [ $$STATE_EXIT_CODE -ne 0 ]; then \
						echo "  初期化エラー (exit code: $$STATE_EXIT_CODE)"; \
						if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
							echo "  エラー詳細: $$STATE_OUTPUT"; \
						fi; \
					else \
						echo "  リソースなし、または初期化が必要"; \
					fi; \
				fi; \
			); \
		else \
			echo "  モジュールディレクトリが存在しません: ./environments/prod/$$TARGET"; \
		fi; \
	fi

# 開発環境での完全なワークフロー
dev-workflow: dev-plan
	@echo "開発環境でのプラン確認が完了しました"
	@read -p "適用しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] && export target=$${target:-all} && make dev-apply || echo "スキップしました"

# Docker & ECR コマンド
build-dev:
	@echo "=== 開発環境用Dockerイメージをビルド中 ==="
	@IMAGE_TAG=$${IMAGE_TAG:-latest}; \
	DOCKER_BUILDKIT=0 docker build -t helloworld-dev:$$IMAGE_TAG ../docker/helloworld
	@echo "✅ 開発環境用イメージビルド完了"

build-prod:
	@echo "=== 本番環境用Dockerイメージをビルド中 ==="
	@IMAGE_TAG=$${IMAGE_TAG:-latest}; \
	DOCKER_BUILDKIT=0 docker build -t helloworld-prod:$$IMAGE_TAG ../docker/helloworld
	@echo "✅ 本番環境用イメージビルド完了"

build-and-push-dev: init
	@echo "=== 開発環境にDockerイメージをビルド&プッシュ中 ==="
	@IMAGE_TAG=$${IMAGE_TAG:-latest}; \
	../scripts/build-and-push.sh dev $$IMAGE_TAG
	@echo "✅ 開発環境へのプッシュ完了"

build-and-push-prod: init
	@echo "=== 本番環境にDockerイメージをビルド&プッシュ中 ==="
	@IMAGE_TAG=$${IMAGE_TAG:-latest}; \
	../scripts/build-and-push.sh prod $$IMAGE_TAG
	@echo "✅ 本番環境へのプッシュ完了"

# ECRリポジトリ作成 + Dockerプッシュ + ECS Fargateの完全ワークフロー
deploy-dev-complete: 
	@echo "=== 開発環境の完全デプロイワークフロー ==="
	@echo "1. ソースリソース（ECR、S3）作成..."
	@export target=source; make dev-apply-auto
	@echo "2. Dockerイメージビルド&プッシュ..."
	@IMAGE_TAG=$${IMAGE_TAG:-latest}; make build-and-push-dev
	@echo "3. 他のリソースをデプロイ..."
	@make dev-apply-auto
	@echo "✅ 開発環境の完全デプロイ完了"
	@echo "🌐 開発環境のHelloWorldアプリケーションURLを取得中..."
	@make get-alb-url-dev

deploy-prod-complete:
	@echo "=== 本番環境の完全デプロイワークフロー ==="
	@echo "⚠️  本番環境にデプロイしようとしています"
	@read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }
	@echo "1. ソースリソース（ECR、S3）作成..."
	@export target=source; make prod-apply-auto
	@echo "2. Dockerイメージビルド&プッシュ..."
	@IMAGE_TAG=$${IMAGE_TAG:-latest}; make build-and-push-prod
	@echo "3. 他のリソースをデプロイ..."
	@make prod-apply-auto
	@echo "✅ 本番環境の完全デプロイ完了"

# インフラのみデプロイ（VPC + ECR + ECS、Dockerプッシュなし）
deploy-infra-dev:
	@echo "=== 開発環境のインフラデプロイ ==="
	@echo "1. ネットワークリソース（VPC、SG、LB）作成..."
	@export target=network; make dev-apply-auto
	@echo "2. ソースリソース（ECR、S3）作成..."
	@export target=source; make dev-apply-auto
	@echo "3. 動的Webサービス（ECS）作成..."
	@export target=servise_dynamicweb; make dev-apply-auto
	@echo "✅ 開発環境のインフラデプロイ完了"

deploy-infra-prod:
	@echo "=== 本番環境のインフラデプロイ ==="
	@echo "⚠️  本番環境にデプロイしようとしています"
	@read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }
	@echo "1. ネットワークリソース（VPC、SG、LB）作成..."
	@export target=network; make prod-apply-auto
	@echo "2. ソースリソース（ECR、S3）作成..."
	@export target=source; make prod-apply-auto
	@echo "3. 動的Webサービス（ECS）作成..."
	@export target=servise_dynamicweb; make prod-apply-auto
	@echo "✅ 本番環境のインフラデプロイ完了"

# ALB URL取得コマンド
get-alb-url-dev:
	@echo "=== 開発環境のALB URL取得 ==="
	@cd ./environments/dev/network && \
	ALB_DNS=$$(terragrunt output -raw load_balancer_dns_name 2>/dev/null); \
	if [ -n "$$ALB_DNS" ] && [ "$$ALB_DNS" != "null" ]; then \
		echo "🌐 開発環境のHelloWorldアプリケーションURL:"; \
		echo "   http://$$ALB_DNS"; \
		echo ""; \
		echo "📋 アクセス方法:"; \
		echo "   curl http://$$ALB_DNS"; \
		echo "   または、ブラウザで上記URLにアクセスしてください"; \
	else \
		echo "❌ ALBが見つかりません。まずALBをデプロイしてください:"; \
		echo "   make deploy-infra-dev"; \
	fi

get-alb-url-prod:
	@echo "=== 本番環境のALB URL取得 ==="
	@cd ./environments/prod/network && \
	ALB_DNS=$$(terragrunt output -raw load_balancer_dns_name 2>/dev/null); \
	if [ -n "$$ALB_DNS" ] && [ "$$ALB_DNS" != "null" ]; then \
		echo "🌐 本番環境のHelloWorldアプリケーションURL:"; \
		echo "   http://$$ALB_DNS"; \
		echo ""; \
		echo "📋 アクセス方法:"; \
		echo "   curl http://$$ALB_DNS"; \
		echo "   または、ブラウザで上記URLにアクセスしてください"; \
	else \
		echo "❌ ALBが見つかりません。まずALBをデプロイしてください:"; \
		echo "   make deploy-infra-prod"; \
	fi

# CloudFront URL取得コマンド
get-cloudfront-url-dev:
	@echo "=== 開発環境のCloudFront URL取得 ==="
	@cd ./environments/dev/servise_staticweb && \
	CLOUDFRONT_URL=$$(terragrunt output -raw cloudfront_url 2>/dev/null); \
	if [ -n "$$CLOUDFRONT_URL" ] && [ "$$CLOUDFRONT_URL" != "null" ]; then \
		echo "🌐 開発環境の静的WebサイトURL:"; \
		echo "   $$CLOUDFRONT_URL"; \
		echo ""; \
		echo "📋 アクセス方法:"; \
		echo "   curl $$CLOUDFRONT_URL"; \
		echo "   または、ブラウザで上記URLにアクセスしてください"; \
		echo ""; \
		DOMAIN_NAME=$$(terragrunt output -raw cloudfront_domain_name 2>/dev/null); \
		if [ -n "$$DOMAIN_NAME" ]; then \
			echo "📝 CloudFrontドメイン名: $$DOMAIN_NAME"; \
		fi; \
	else \
		echo "❌ CloudFrontが見つかりません。まずCloudFrontをデプロイしてください:"; \
		echo "   target=servise_staticweb make dev-apply"; \
	fi

get-cloudfront-url-prod:
	@echo "=== 本番環境のCloudFront URL取得 ==="
	@cd ./environments/prod/servise_staticweb && \
	CLOUDFRONT_URL=$$(terragrunt output -raw cloudfront_url 2>/dev/null); \
	if [ -n "$$CLOUDFRONT_URL" ] && [ "$$CLOUDFRONT_URL" != "null" ]; then \
		echo "🌐 本番環境の静的WebサイトURL:"; \
		echo "   $$CLOUDFRONT_URL"; \
		echo ""; \
		echo "📋 アクセス方法:"; \
		echo "   curl $$CLOUDFRONT_URL"; \
		echo "   または、ブラウザで上記URLにアクセスしてください"; \
		echo ""; \
		DOMAIN_NAME=$$(terragrunt output -raw cloudfront_domain_name 2>/dev/null); \
		if [ -n "$$DOMAIN_NAME" ]; then \
			echo "📝 CloudFrontドメイン名: $$DOMAIN_NAME"; \
		fi; \
	else \
		echo "❌ CloudFrontが見つかりません。まずCloudFrontをデプロイしてください:"; \
		echo "   target=servise_staticweb make prod-apply"; \
	fi
