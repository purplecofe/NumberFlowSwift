Pod::Spec.new do |s|
  s.name             = 'NumberFlowSwift'
  s.version          = '0.1.0'
  s.summary          = 'Animated number transitions for SwiftUI and UIKit - slot machine style spinning digits'

  s.description      = <<-DESC
  NumberFlowSwift provides beautiful, animated number transitions for Swift apps.
  When numeric values change, each digit spins like a slot machine to the new value,
  creating a polished, premium feel. Inspired by barvian/number-flow.
  
  Features:
  - Slot machine style spinning digit animation
  - Support for any NumberFormatter (currency, decimal, percent, etc.)
  - SwiftUI: NumberFlowText view with reduce motion support
  - UIKit: NumberFlowLabel with spring animations
  - Works on iOS and macOS
                       DESC

  s.homepage         = 'https://github.com/purplecofe/NumberFlowSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kai Huang' => 'annyeongbatman@gmail.com' }
  s.source           = { :git => 'https://github.com/purplecofe/NumberFlowSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '17.0'
  s.osx.deployment_target = '14.0'
  
  s.swift_version = '5.9'
  s.source_files = 'Sources/NumberFlowSwift/**/*'
  
  # SwiftUI is required for all platforms
  s.frameworks = 'SwiftUI'
  
  # UIKit is required on iOS for NumberFlowLabel
  s.ios.frameworks = 'SwiftUI', 'UIKit'
end

