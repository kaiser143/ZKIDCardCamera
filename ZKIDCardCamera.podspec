#
# Be sure to run `pod lib lint ZKIDCardCamera.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
  s.name             = 'ZKIDCardCamera'
  s.version          = '0.3.0'
  s.summary          = '身份证拍摄 UI 组件，支持自定义、多语言与第三方 OCR 对接'

  s.description      = <<-DESC
ZKIDCardCamera 是 iOS 身份证拍摄 UI 组件，提供取景框、拍照预览、点击/连续对焦与证件框裁剪。
证件 OCR 识别由宿主通过 ZKIDCardRecognitionProvider 协议接入第三方 SDK。
支持多语言（en / zh-Hans）、ZKIDCardCameraConfiguration 自定义 UI，最低 iOS 12.0。
                       DESC

  s.homepage         = 'https://github.com/kaiser143/ZKIDCardCamera'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'deyang143@126.com' => 'deyang143@126.com' }
  s.source           = { :git => 'https://github.com/kaiser143/ZKIDCardCamera.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'ZKIDCardCamera/Classes/**/*'
  s.public_header_files = 'ZKIDCardCamera/Classes/*.h'
  s.requires_arc = true

  s.resource  = 'ZKIDCardCamera/ZKIDCardCamera.bundle'

  s.dependency 'Masonry'
  s.dependency 'ZKCategories', '~> 0.3.12'
end
