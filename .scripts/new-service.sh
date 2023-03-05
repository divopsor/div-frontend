user=divopsor
gitdomain=divopsor
domains=(
  "app.divops.kr"
  "div.homes"
)

if gh auth status 2>&1 | grep -q "divopsor"; then
  echo "✅ 환영합니다, divopsor 님"
else
  echo "❌ divopsor로 로그인해주세요."
  exit 1
fi

if [ -z "$CRECO_STORAGE_PAT" ]; then
  echo "CRECO_STORAGE_PAT is empty"
  exit 1
fi

if [ -z "$PAT" ]; then
  echo "PAT is empty"
  exit 1
fi

printf "도메인을 선택해주세요!\n"

select domain in "${domains[@]}"; do
  case $domain in "app.divops.kr" | "div.homes")
    echo "$domain 을 선택했습니다."
    break
    ;;
  *)
    echo "1 혹은 2를 입력해주세요."
    exit 1
    ;;
  esac
done

printf "서비스 이름을 입력하세요 (e.g. hello-world) >>> "

read serviceName

if gh repo list | grep -q "$user/$domain-$serviceName"; then
  echo "✅ REPO가 이미 존재합니다."
else
  gh repo create --public --add-readme $user/$domain-$serviceName || exit 1
  echo "✅ REPO create 완료"
fi

cd div.homes/hello-world || exit 1

git remote add $serviceName git@$gitdomain:$user/$domain-$serviceName.git || exit 1

git push $serviceName main -f || exit 1

git remote remove $serviceName || exit 1

cd -

git submodule add git@github.com:$user/$domain-$serviceName.git ./$domain/$serviceName || exit 1

echo "✅ REPO clone 완료"

cd ./$domain/$serviceName

git remote update

git switch main

echo "# $domain-$serviceName" >./README.md

../../.scripts/replace.sh ./package.json div.homes $domain || exit 1

../../.scripts/replace.sh ./package.json hello-world $serviceName || exit 1

../../.scripts/replace.sh ./next.config.js hello-world $serviceName || exit 1

echo "✅ REPO 초기 설정 완료"

git update-ref -d HEAD || exit 1

echo "✅ REPO commits 리셋 완료"

case $domain in "div.homes")
  cp ../../.template/deploy-$domain.yml ./.github/workflows/deploy.yml
  ;;
esac

yarn || exit 1

yarn prepare || exit 1

git config --local user.email "divopsor@gmail.com"

git config --local user.name "divopsor"

git add -A || exit 1

git commit -m "initial commit [skip vercel] [skip ci]" || exit 1

git push origin main -f || exit 1

gh secret set PAT --body $PAT
gh secret set CRECO_STORAGE --body $CRECO_STORAGE_PAT

echo "✅ REPO initial 완료"

cd -

yarn || exit 1

git config --local user.email "divopsor@gmail.com"

git config --local user.name "divopsor"

git add -A

git commit -m "feat: $domain/$serviceName 스캐폴딩"

git push origin HEAD

case $domain in "app.divops.kr")
  echo "✅ VERCEL 설정을 하세요!"

  COMMAND="npx vercel-submodules --all && yarn install"
  echo "👉 INSTALL COMMAND: \"$COMMAND\""

  IGNORE='[[ $VERCEL_GIT_COMMIT_MESSAGE == *"skip vercel"* ]] && exit 0 || exit 1'
  echo "👉 Ignored Build Step: \"$IGNORE\""

  open "https://vercel.com/new/divops-monorepo"

  break
  ;;
"div.homes")

  echo "✅ .github 을 설정하세요"
  break
  ;;
esac
