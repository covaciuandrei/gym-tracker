#shellcheck disable=SC2155
export PATH=$(pwd)/flutter/bin:$PATH
if command -v spider &> /dev/null
then
echo "spider is already installed"
else
echo "Installing spider"
dart pub global activate spider &> /dev/null
# shellcheck disable=SC2140
export PATH="$PATH":"$HOME/.pub-cache/bin"
echo "spider activated"
fi
spider build
# sed -i '' "1s/^/part 'app_icons.g.dart'; \\n/g" ./lib/resources/app_icons.dart
# sed -i '' '1s/^/\/\/GENERATED CODE - DO NOT MODIFY BY HAND\'$'\n/g' ./lib/resources/app_icons.dart
# sed -i '' "1s/^/part 'app_images.g.dart'; \\n/g" ./lib/resources/app_images.dart
sed -i '' '1s/^/\/\/GENERATED CODE - DO NOT MODIFY BY HAND\'$'\n/g' ./lib/presentation/resources/app_images.dart