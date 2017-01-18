Pod::Spec.new do |s|
  s.name         = 'iOSCSKit'
  s.version      = '0.0.1'
  s.summary      = '包含总线管理、router、单例管理的小工具箱'
  s.description  = '包含总线管理、router、单例管理的小工具箱'
  s.homepage     = 'https://github.com/droison/iOSCSKit'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'droison' => 'chaisong.cn@gmail.com' }
  s.source       = { :git => 'https://github.com/droison/iOSCSKit.git', :tag => s.version.to_s }
  s.platform     = :ios
  s.source_files = 'CSKit/Bus/*.{h,m}', 'CSKit/ServiceCenter/*.{h,m}' , 'CSKit/Router/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
end