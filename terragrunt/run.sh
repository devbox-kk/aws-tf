#!/bin/bash

# Terragrunt実行スクリプト

set -e

ENVIRONMENT=""
ACTION=""
TARGET="${target:-all}"
AUTO_APPROVE=false

usage() {
    echo "使用方法: $0 -e <environment> -a <action> [-y]"
    echo "  -e: 環境 (dev, prod)"
    echo "  -a: アクション (plan, apply, destroy)"
    echo "  -y: 自動承認（apply/destroyで確認プロンプトをスキップ）"
    echo ""
    echo "環境変数:"
    echo "  target: 対象モジュール (s3, ecr, vpc, ecs, iam, security-group, load-balancer, cloudwatch, cognito, ssl-certificate, cloudfront, all) - 未指定時は 'all'"
    echo ""
    echo "例:"
    echo "  $0 -e dev -a plan"
    echo "  $0 -e dev -a apply -y"
    echo "  target=s3 $0 -e dev -a plan"
    echo "  target=ecr $0 -e dev -a plan"
    echo "  target=vpc $0 -e dev -a plan"
    echo "  target=ecs $0 -e dev -a plan"
    echo "  target=iam $0 -e dev -a plan"
    echo "  target=all $0 -e prod -a apply"
    exit 1
}

while getopts "e:a:yh" opt; do
    case $opt in
        e)
            ENVIRONMENT=$OPTARG
            ;;
        a)
            ACTION=$OPTARG
            ;;
        y)
            AUTO_APPROVE=true
            ;;
        h)
            usage
            ;;
        \?)
            echo "無効なオプション: -$OPTARG" >&2
            usage
            ;;
    esac
done

if [[ -z "$ENVIRONMENT" || -z "$ACTION" ]]; then
    echo "エラー: 環境とアクションの両方を指定してください"
    usage
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|prod)$ ]]; then
    echo "エラー: 環境は 'dev' または 'prod' を指定してください"
    exit 1
fi

if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    echo "エラー: アクションは 'plan', 'apply', または 'destroy' を指定してください"
    exit 1
fi

# ターゲットの検証
if [[ ! "$TARGET" =~ ^(s3|ecr|vpc|ecs|iam|security-group|load-balancer|cloudwatch|cognito|ssl-certificate|cloudfront|all)$ ]]; then
    echo "エラー: ターゲットは 's3', 'ecr', 'vpc', 'ecs', 'iam', 'security-group', 'load-balancer', 'cloudwatch', 'cognito', 'ssl-certificate', 'cloudfront', または 'all' を指定してください"
    exit 1
fi

# ディレクトリの設定
if [[ "$TARGET" == "all" ]]; then
    TERRAGRUNT_DIR="./environments/${ENVIRONMENT}"
else
    TERRAGRUNT_DIR="./environments/${ENVIRONMENT}/${TARGET}"
fi

if [[ ! -d "$TERRAGRUNT_DIR" ]]; then
    echo "エラー: ディレクトリ $TERRAGRUNT_DIR が存在しません"
    exit 1
fi

echo "=== Terragrunt ${ACTION} を実行中 (環境: ${ENVIRONMENT}, ターゲット: ${TARGET}) ==="
echo "ディレクトリ: $TERRAGRUNT_DIR"

cd "$TERRAGRUNT_DIR"

if [[ "$TARGET" == "all" ]]; then
    case $ACTION in
        plan)
            terragrunt plan --all
            ;;
        apply)
            if [[ "$AUTO_APPROVE" == "true" ]]; then
                terragrunt apply --all --non-interactive
            else
                terragrunt apply --all
            fi
            ;;
        destroy)
            if [[ "$AUTO_APPROVE" == "true" ]]; then
                terragrunt destroy --all --non-interactive
            else
                terragrunt destroy --all
            fi
            ;;
    esac
else
    case $ACTION in
        plan)
            terragrunt plan
            ;;
        apply)
            if [[ "$AUTO_APPROVE" == "true" ]]; then
                terragrunt apply -auto-approve --non-interactive
            else
                terragrunt apply
            fi
            ;;
        destroy)
            if [[ "$AUTO_APPROVE" == "true" ]]; then
                terragrunt destroy --auto-approve --non-interactive
            else
                terragrunt destroy
            fi
            ;;
    esac
fi

echo "=== 完了 ==="
