set -euo pipefail

cd "$(dirname "$0")"
rm -rf build dist
mkdir -p build dist

cp index.mjs crop-image.mjs package.json build/
[ -f package-lock.json ] && cp package-lock.json build/

cd build

npm install --omit=dev --os=linux --cpu=x64 --libc=glibc


ls node_modules/@img | grep -q "sharp-linux-x64" || { echo "ERROR: falta sharp-linux-x64"; exit 1; }

zip -rq ../dist/crop.zip .
cd ..
echo "ZIP listo: lambdas/crop/dist/crop.zip"