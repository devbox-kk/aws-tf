# 開発環境の親設定
# この設定により、dev ディレクトリ内の全ての子モジュールが
# terragrunt run-all コマンドで一括実行可能になります

# 共通設定は各子モジュールで読み込まれるため、
# ここでは最小限の設定のみを記述します

locals {
  tags = {
    Environment = "dev"
    Application = "helloworld"
    Project     = "aws-tf"
    ManagedBy   = "terragrunt"
  }
}

inputs = {
  tags = local.tags
  name_prefix = "${local.tags.Application}-${local.tags.Environment}"
}
