Pod::Spec.new do |s|
  s.name         = 'VENTouchLock'
  s.version      = '0.0.1'
  s.summary      = 'A passcode framework that features touch ID'
  s.description   = <<-DESC
                   An easy to use passcode framework used in the Venmo app
                   DESC
  s.homepage     = 'https://www.github.com/dasmer/VENTouchLock'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Venmo' => 'ios@venmo.com'}
  s.source       = { :git => 'https://github.com/dasmer/VENTouchLock.git', :tag => "v#{s.version}"}
  s.source_files = 'VENTouchLock/**/*.{h,m}'
  s.resources   = ["VENTouchLock/**/*.{xib}"]
  s.dependency 'SSKeychain', '~> 1.2.2'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
end