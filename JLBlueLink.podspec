#
# Be sure to run `pod lib lint JLBlueLink.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JLBlueLink'
  s.version          = '1.0.1'
  s.summary          = 'Library for Jieli bluetooth device link with iOS.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/EzioChen/JLBlueLink'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'EzioChan' => 'chenguanjie@zh-jieli.com' }
  s.source           = { :git => 'https://github.com/EzioChen/JLBlueLink.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'JLBlueLink/Classes/**/*.{h,m,mm,swift}'
  
  s.frameworks = 'UIKit', 'Foundation', 'CoreBluetooth'
  
  s.libraries  = ['c++','c']

  s.vendored_frameworks = 'JLBlueLink/Frameworks/*.xcframework'

  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-ObjC',
    # 将 arm64 从模拟器的架构中排除（适用于 Intel Mac）
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  
  s.user_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }

end

