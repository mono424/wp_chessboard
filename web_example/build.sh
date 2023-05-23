flutter build web
rm -rf ../react_example/public/flutter
mkdir ../react_example/public/flutter
cp -r build/web/* ../react_example/public/flutter

rm -rf ../react/flutter
mkdir ../react/flutter
cp -r build/web/* ../react/flutter