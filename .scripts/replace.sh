FILE=$(node -p "require('fs').readFileSync('$1', 'utf-8').replaceAll('$2', '$3')")

echo "$FILE" >$1
