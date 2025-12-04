# NumberFlowSwift

Animated number transitions for SwiftUI and UIKit — slot machine style spinning digits.

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B%20%7C%20macOS%2014%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

Inspired by [barvian/number-flow](https://github.com/barvian/number-flow).

## Demo

When numeric values change, each digit spins like a slot machine to the new value:

```
$12,345  →  $12,346
     ↑          ↑
    spins from 5 to 6
```

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/purplecofe/NumberFlowSwift.git", from: "0.1.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → paste the repository URL.

### CocoaPods

```ruby
pod 'NumberFlowSwift', '~> 0.1.0'
```

## Usage

### SwiftUI

```swift
import NumberFlowSwift

struct ContentView: View {
    @State private var count: Double = 0
    
    var body: some View {
        VStack {
            NumberFlowText(value: count, font: .largeTitle)
            
            Button("Increment") { count += 1 }
        }
    }
}
```

### UIKit

```swift
import NumberFlowSwift

class ViewController: UIViewController {
    let label = NumberFlowLabel()
    var count: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .label
        label.setValue(count, animated: false)
        view.addSubview(label)
    }
    
    @IBAction func increment() {
        count += 1
        label.setValue(count, animated: true)
    }
}
```

### Currency Formatting

```swift
let formatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    return f
}()

// SwiftUI
NumberFlowText(
    value: 99.99,
    formatter: formatter,
    font: .system(size: 48, weight: .bold, design: .rounded)
)

// UIKit
label.formatter = formatter
label.setValue(99.99, animated: true)
```

### Custom Colors

```swift
// SwiftUI
NumberFlowText(
    value: amount,
    font: .title,
    textColor: amount >= 0 ? .green : .red
)

// UIKit
label.textColor = amount >= 0 ? .systemGreen : .systemRed
```

## Accessibility

NumberFlowSwift automatically respects the **Reduce Motion** accessibility setting (SwiftUI only). When enabled, numbers change instantly without animation.

## Requirements

- iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 17.0+ / visionOS 1.0+
- Swift 5.9+
- Xcode 15.0+

> **Note:** `NumberFlowLabel` (UIKit) is not available on watchOS.

## License

MIT License. See [LICENSE](LICENSE) for details.

## Credits

Animation concept inspired by [number-flow](https://github.com/barvian/number-flow) by Maxwell Barvian.

