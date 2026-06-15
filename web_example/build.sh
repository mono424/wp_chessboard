# --wasm emits the dart2wasm/skwasm build AND a dart2js/canvaskit fallback.
# The skwasm build is auto-selected on Blink (Chrome/Edge/Android Chrome);
# Safari/WebKit and Firefox fall back to main.dart.js. skwasm runs
# single-threaded — no cross-origin isolation (COOP/COEP) required.
flutter build web --wasm

rm -rf ../react_example/public/flutter
mkdir ../react_example/public/flutter
cp -r build/web/* ../react_example/public/flutter

rm -rf ../solid_example/public/flutter
mkdir -p ../solid_example/public/flutter
cp -r build/web/* ../solid_example/public/flutter