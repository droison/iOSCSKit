Pod::Spec.new do |s|
s.name = 'CSKit'
s.version = '0.0.1'
s.license = 'MIT'
s.summary = '包含总线管理、router、单例管理的小工具箱'
s.homepage = 'https://github.com/droison/iOSCSKit'
s.authors = { 'droison' => 'chaisong.cn@gmail.com' }
s.source = { :git => 'https://github.com/droison/iOSCSKit.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '8.0'
s.source_files = 'CSKit/*.{h,m}'
s.resources = 'CSKit/images/*.{png,xib}'
end
