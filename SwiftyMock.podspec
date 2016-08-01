Pod::Spec.new do |s|
  s.name             = 'SwiftyMock'
  s.version          = '0.1.0'
  s.summary          = 'Some helpers to do Mocking in Swift.'
  s.description      = <<-DESC
    Some helpers to do Mocking in Swift.
    Mostly useful for mocking via protocols. Simple solution. Handles most of the cases. Easy setup
                       DESC

  s.homepage         = 'https://github.com/Stanfy/SwiftyMock'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Stanfy' => 'hello@stanfy.com'  }
  s.source           = { :git => 'https://github.com/Stanfy/SwiftyMock.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.default_subspec = 'Core'

  s.subspec 'Core' do |cs|
    cs.source_files = 'SwiftyMock/Classes/Core/**/*'
  end

  s.subspec 'ReactiveCocoa' do |rs|
    rs.dependency 'SwifyMock/Core'
    rs.dependency 'ReactiveCocoa', '~> 4.1'
    rs.source_files = 'SwiftyMock/Classes/ReactiveCocoa/**/*'
  end

end
