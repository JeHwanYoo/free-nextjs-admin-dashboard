FROM public.ecr.aws/docker/library/node:22-alpine AS base

# 작업 디렉토리 설정
WORKDIR /app

# 종속 항목 설치를 위해 package.json과 package-lock.json 복사
COPY package.json package-lock.json ./

# 종속 항목 설치
RUN npm install

# 애플리케이션 소스 코드를 복사
COPY . .

FROM base AS build

# Next.js 애플리케이션 빌드
RUN npm run build

FROM public.ecr.aws/docker/library/node:22-alpine AS production

# 작업 디렉토리 설정
WORKDIR /app

# 빌드된 파일과 필요한 파일들만 복사
COPY --from=build /app/package.json /app/package-lock.json ./
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/next.config.mjs ./

# 포트 설정
EXPOSE 80

# 환경 변수 설정
ENV PORT 80

# Next.js 애플리케이션 시작
CMD ["npm", "start"]
