# div-frontend

## Overview

divopsor's 서비스 모노레포입니다. 각 서비스는 서브모듈로 분리되어 있고, 각 서브모듈 레포에서 배포됩니다.

## Deploy Configuration

각 서비스는 모두 Next.js 프레임워크로 구성되어 있고, SSG(next export)를 통해 빌드된 파일들이 github repo 로 올라갑니다.
CloudFront 에서 github raw 파일들을 Origin 으로 바라보도록 구성되어있습니다.

CDN(AWS CF) -> GitHub(raw files)

## 서브 모듈 관련 명령어들

git submodule init

git submodule update --remote

git submodule foreach git remote update

git submodule foreach git switch main

git submodule foreach git reset --hard origin/main

git submodule foreach bash -c "yarn prepare || exit 0;"
