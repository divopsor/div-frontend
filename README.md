# div-frontend

git submodule init

git submodule update --remote

git submodule foreach git remote update

git submodule foreach git switch main

git submodule foreach git reset --hard origin/main

git submodule foreach bash -c "yarn prepare || exit 0;"
