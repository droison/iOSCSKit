Pod::Spec.new do |s|
  s.name         = 'QDKit'
  s.version      = '0.0.9'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary      = '包含总线管理、router、单例管理、网络下载的小工具箱'
  s.homepage     = 'https://github.com/droison/iOSCSKit'
  s.author       = { 'droison' => 'chaisong.cn@gmail.com' }
  s.source       = { :git => 'https://github.com/droison/iOSCSKit.git', :tag => s.version.to_s }
  s.platform     = :ios
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'CSYYCache', '~> 11.0.1'
  s.source_files = 'QDKit/*.h', 'QDKit/Download/*.{h,m}', 'QDKit/Bus/*.{h,m}', 'QDKit/ServiceCenter/*.{h,m}' , 'QDKit/Router/*.{h,m}'
end