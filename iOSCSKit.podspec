Pod::Spec.new do |s|
  s.name         = 'iOSCSKit'
  s.version      = '0.0.2'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary      = '包含总线管理、router、单例管理、网络下载的小工具箱'
  s.homepage     = 'https://github.com/droison/iOSCSKit'
  s.author       = { 'droison' => 'chaisong.cn@gmail.com' }
  s.source       = { :git => 'https://github.com/droison/iOSCSKit.git', :tag => s.version.to_s }
  s.platform     = :ios
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.dependency 'AFNetworking', '~> 3.1.0'
  
  s.public_header_files = 'CSKit/CSKit.h'
  s.source_files = 'CSKit/CSKit.h', 'CSKit/CSKitMacro.h', 'CSKit/Download/*.{h,m}', 'CSKit/Bus/*.{h,m}', 'CSKit/ServiceCenter/*.{h,m}' , 'CSKit/Router/*.{h,m}'
end