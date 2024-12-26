#
# Be sure to run `pod lib lint JLBlueLink.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JLBlueLink'
  s.version          = '1.0.0'
  s.summary          = 'Library for Jieli bluetooth device link with iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/EzioChen/JLBlueLink'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'EzioChan' => 'chenguanjie@zh-jieli.com' }
  s.source           = { :git => 'https://github.com/EzioChen/JLBlueLink.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'JLBlueLink/Classes/**/*.{h,m,mm,swift}'
  
  s.frameworks = 'UIKit', 'Foundation', 'CoreBluetooth'
  
  s.libraries  = ['c++','c']
  
  s.vendored_frameworks = [
   'JLBlueLink/Frameworks/*.framework'
  ]
  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC'
  }
  s.pod_target_xcconfig = {
    # 将 arm64 从模拟器的架构中排除
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  
  s.user_target_xcconfig = {
    # 将 arm64 从模拟器的架构中排除
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  # 动态剥离架构
  s.prepare_command = <<-CMD
  FRAMEWORK_DIR="JLBlueLink/Frameworks"
  for framework in "$FRAMEWORK_DIR"/*.framework; do
    INFO_PLIST="$framework/Info.plist"

    if [ ! -f "$INFO_PLIST" ]; then
      echo "Info.plist not found for $framework"
      continue
    fi

    FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$INFO_PLIST" CFBundleExecutable 2>/dev/null || echo "")
    if [ -z "$FRAMEWORK_EXECUTABLE_NAME" ]; then
      echo "CFBundleExecutable not found in $INFO_PLIST, skipping $framework"
      continue
    fi

    FRAMEWORK_EXECUTABLE_PATH="$framework/$FRAMEWORK_EXECUTABLE_NAME"

    if [ -f "$FRAMEWORK_EXECUTABLE_PATH" ]; then
      ARCHS=$(lipo -info "$FRAMEWORK_EXECUTABLE_PATH" | awk -F ': ' '{print $2}')
      echo "Processing $framework with architectures: $ARCHS"

      if [[ $ARCHS == *"i386"* ]]; then
        echo "Removing i386 from $framework"
        lipo -remove i386 -output "${FRAMEWORK_EXECUTABLE_PATH}_cleaned" "$FRAMEWORK_EXECUTABLE_PATH"
        mv "${FRAMEWORK_EXECUTABLE_PATH}_cleaned" "$FRAMEWORK_EXECUTABLE_PATH"
      fi

      if [[ $ARCHS == *"x86_64"* ]]; then
        echo "Removing x86_64 from $framework"
        lipo -remove x86_64 -output "${FRAMEWORK_EXECUTABLE_PATH}_cleaned" "$FRAMEWORK_EXECUTABLE_PATH"
        mv "${FRAMEWORK_EXECUTABLE_PATH}_cleaned" "$FRAMEWORK_EXECUTABLE_PATH"
      fi
    else
      echo "Executable not found at $FRAMEWORK_EXECUTABLE_PATH, skipping $framework"
    fi
  done
CMD

 
  
  # s.resource_bundles = {
  #   'JLBlueLink' => ['JLBlueLink/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'
end
