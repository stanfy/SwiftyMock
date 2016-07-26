Pod::Spec.new do |s|
  s.name             = 'SwiftMock'
  s.version          = '0.1.0'
  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/SwiftMock'
  s.summary          = 'This pod will make mocking in Swift much easier'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Stanfy' => 'hello@stanfy.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/SwiftMock.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'MockUtils.swift'
  s.dependency 'ReactiveCocoa', '~> 4.1'
end
