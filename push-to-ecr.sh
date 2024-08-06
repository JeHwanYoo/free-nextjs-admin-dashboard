#!/bin/bash

# 변수 설정
AWS_REGION=$1
AWS_ACCOUNT_ID=$2
REPOSITORY_NAME=$3
IMAGE_TAG=$4
AWS_PROFILE=$5

# 변수 출력 (디버깅용)
echo "-------------------------------------"
echo "AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"
echo "AWS_REGION: $AWS_REGION"
echo "AWS_PROFILE: $AWS_PROFILE"
echo "REPOSITORY_NAME: $REPOSITORY_NAME"
echo "IMAGE_TAG: $IMAGE_TAG"
echo "-------------------------------------"

# ECR 로그인
aws ecr get-login-password --region "$AWS_REGION" --profile "$AWS_PROFILE" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Docker 이미지 빌드
docker build -t "$REPOSITORY_NAME:$IMAGE_TAG" .

# ECR 리포지토리 URL
ECR_REPO_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME"

# Docker 이미지에 태그 추가
echo "Tagging Docker image..."
docker tag "$REPOSITORY_NAME:$IMAGE_TAG" "$ECR_REPO_URL:$IMAGE_TAG"

# Docker 이미지 푸시
if docker push "$ECR_REPO_URL:$IMAGE_TAG"; then
  echo "Docker 이미지가 성공적으로 ECR에 푸시되었습니다: $ECR_REPO_URL:$IMAGE_TAG"
else
  echo "Docker 이미지 푸시에 실패했습니다."
fi
