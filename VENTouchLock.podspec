Pod::Spec.new do |s|
  s.name         = 'VENTouchLock'
  s.version      = '1.13.0'
  s.summary      = 'A passcode framework that features Touch ID'
  s.description   = <<-DESC
                   An easy to use passcode framework used in the Venmo app.
                   DESC
  s.homepage     = 'https://www.github.com/venmo/VENTouchLock'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Venmo' => 'ios@venmo.com'}
  s.source       = { :git => 'https://github.com/venmo/VENTouchLock.git', :tag => "v#{s.version}"}
  s.source_files = 'VENTouchLock/**/*.{h,m}'
  s.resources   = ["VENTouchLock/**/*.{xib}"]
  s.dependency 'SAMKeychain', '~> 1.0'
  s.frameworks = 'LocalAuthentication'
  s.platform     = :ios, '7.0'
  s.requires_arc = true
end
