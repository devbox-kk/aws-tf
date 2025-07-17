#!/bin/bash

# 共通関数とユーティリティ
# 他のスクリプトで以下のようにsourceして使用:
# source "$(dirname "$0")/lib/common.sh"

# 色付きログ用関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

# 環境変数の検証
validate_environment() {
    local env=$1
    if [[ ! "$env" =~ ^(dev|prod)$ ]]; then
        log_error "Invalid environment. Please specify 'dev' or 'prod'"
        return 1
    fi
    return 0
}

# AWS CLI の設定確認
check_aws_config() {
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log_error "AWS CLI is not configured. Please run 'aws configure' first."
        return 1
    fi
    return 0
}

# AWS Account ID を取得
get_aws_account_id() {
    aws sts get-caller-identity --query Account --output text
}

# ECR に対する認証
login_to_ecr() {
    local region=$1
    local registry=$2
    
    log_info "Logging in to ECR..."
    aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$registry"
}

# 設定値の表示
show_config() {
    local account_id=$1
    local registry=$2
    local repository=$3
    local full_image_name=$4
    
    log_info "AWS Account ID: $account_id"
    log_info "ECR Registry: $registry"
    log_info "Repository Name: $repository"
    log_info "Full Image Name: $full_image_name"
}

# ローカルイメージの削除
cleanup_local_images() {
    local repository_name=$1
    local image_tag=$2
    local full_image_name=$3
    
    log_info "Cleaning up local images..."
    docker rmi "$repository_name:$image_tag" || true
    docker rmi "$full_image_name" || true
}
