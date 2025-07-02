# Terragrunt Makefile
# AWS S3環境の管理用

.PHONY: help dev-plan dev-apply dev-apply-auto dev-destroy prod-plan prod-apply prod-apply-auto prod-destroy init clean validate format status dev-workflow

# デフォルトターゲット
help:
	@echo "Terragrunt S3プロジェクト 管理コマンド"
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
	@echo "環境変数:"
	@echo "  target=s3          - 特定のモジュール（s3）のみ実行"
	@echo "  target=all         - 全モジュール実行（デフォルト）"
	@echo ""
	@echo "使用例:"
	@echo "  target=s3 make dev-plan    - S3モジュールのみプラン"
	@echo "  target=all make dev-apply  - 全モジュール適用"
	@echo ""
	@echo "その他:"
	@echo "  make init          - 必要な前提条件をチェック"
	@echo "  make validate      - 設定ファイルの検証"
	@echo "  make format        - 設定ファイルのフォーマット"
	@echo "  make clean         - Terragrunt/Terraformキャッシュをクリア"
	@echo "  make status        - 全環境のリソース状況を確認"
	@echo "  make setup-state   - Terraformステート用リソースを作成"
	@echo "  make dev-workflow  - 開発環境での完全なワークフロー（plan→apply）"

# 前提条件チェック
init:
	@echo "=== 前提条件チェック ==="
	@command -v aws >/dev/null 2>&1 || { echo "AWS CLIがインストールされていません"; exit 1; }
	@command -v terragrunt >/dev/null 2>&1 || { echo "Terragruntがインストールされていません"; exit 1; }
	@command -v terraform >/dev/null 2>&1 || { echo "Terraformがインストールされていません"; exit 1; }
	@aws sts get-caller-identity >/dev/null 2>&1 || { echo "AWS認証情報が設定されていません"; exit 1; }
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
	@echo "現在のディレクトリ: $(shell pwd)"
	@echo "environments/devの内容:"
	@ls -la environments/dev/ || echo "ディレクトリが見つかりません"
	@echo "=== Terragrunt plan を実行中 (環境: dev) ==="
	@export target=$${target:-all}; ./run.sh -e dev -a plan

# 開発環境 - 適用
dev-apply: init
	@echo "=== Terragrunt apply を実行中 (環境: dev) ==="
	@export target=$${target:-all}; ./run.sh -e dev -a apply

# 開発環境 - 適用（自動承認）
dev-apply-auto: init
	@echo "=== Terragrunt apply を実行中 (環境: dev, 自動承認) ==="
	@export target=$${target:-all}; ./run.sh -e dev -a apply -y

# 開発環境 - 削除
dev-destroy: init
	@if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
		echo "⚠️  開発環境のリソースを削除中（CI環境）"; \
		export target=$${target:-all}; ./run.sh -e dev -a destroy -y; \
	else \
		echo "⚠️  開発環境のリソースを削除しようとしています"; \
		read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }; \
		export target=$${target:-all}; ./run.sh -e dev -a destroy -y; \
	fi

# 本番環境 - プラン
prod-plan: init
	@echo "=== Terragrunt plan を実行中 (環境: prod) ==="
	@export target=$${target:-all}; ./run.sh -e prod -a plan

# 本番環境 - 適用
prod-apply: init
	@if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
		echo "⚠️  本番環境にリソースを作成中（CI環境）"; \
		export target=$${target:-all}; ./run.sh -e prod -a apply; \
	else \
		echo "⚠️  本番環境にリソースを作成しようとしています"; \
		read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }; \
		export target=$${target:-all}; ./run.sh -e prod -a apply; \
	fi

# 本番環境 - 適用（自動承認）
prod-apply-auto: init
	@if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
		echo "⚠️  本番環境にリソースを作成中（CI環境、自動承認）"; \
		export target=$${target:-all}; ./run.sh -e prod -a apply -y; \
	else \
		echo "⚠️  本番環境にリソースを作成しようとしています（自動承認）"; \
		read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }; \
		export target=$${target:-all}; ./run.sh -e prod -a apply -y; \
	fi

# 本番環境 - 削除
prod-destroy: init
	@if [ "$$CI" = "true" ] || [ "$$GITHUB_ACTIONS" = "true" ]; then \
		echo "🚨 本番環境のリソースを削除中（CI環境）"; \
		export target=$${target:-all}; ./run.sh -e prod -a destroy -y; \
	else \
		echo "🚨 本番環境のリソースを削除しようとしています"; \
		read -p "本当に続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] || { echo "キャンセルしました"; exit 1; }; \
		export target=$${target:-all}; ./run.sh -e prod -a destroy -y; \
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
	@TARGET=$${target:-all}; \
	if [ "$$TARGET" = "all" ]; then \
		echo "開発環境 (全モジュール):"; \
		(cd ./environments/dev && terragrunt state list --terragrunt-non-interactive 2>/dev/null | sed 's/^/  /') || echo "  リソースなし"; \
		echo ""; \
		echo "本番環境 (全モジュール):"; \
		(cd ./environments/prod && terragrunt state list --terragrunt-non-interactive 2>/dev/null | sed 's/^/  /') || echo "  リソースなし"; \
	else \
		echo "開発環境 ($$TARGET モジュール):"; \
		(cd "./environments/dev/$$TARGET" && terragrunt state list 2>/dev/null | sed 's/^/  /') || echo "  リソースなし"; \
		echo ""; \
		echo "本番環境 ($$TARGET モジュール):"; \
		(cd "./environments/prod/$$TARGET" && terragrunt state list 2>/dev/null | sed 's/^/  /') || echo "  リソースなし"; \
	fi

# 開発環境での完全なワークフロー
dev-workflow: dev-plan
	@echo "開発環境でのプラン確認が完了しました"
	@read -p "適用しますか？ (y/N): " confirm && [ "$$confirm" = "y" ] && export target=$${target:-all} && make dev-apply || echo "スキップしました"
