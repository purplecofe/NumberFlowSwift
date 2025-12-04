// The Swift Programming Language
// https://docs.swift.org/swift-book

/// NumberFlowSwift provides animated number transitions for SwiftUI.
///
/// The main component is ``NumberFlowText``, which creates a slot-machine
/// style spinning animation when numeric values change.
///
/// ## Quick Start
///
/// ```swift
/// import NumberFlowSwift
///
/// struct ContentView: View {
///     @State private var count = 0
///
///     var body: some View {
///         VStack {
///             NumberFlowText(value: Double(count), font: .largeTitle)
///             Button("Increment") { count += 1 }
///         }
///     }
/// }
/// ```
///
/// ## Custom Formatting
///
/// Use a `NumberFormatter` for currency, percentages, or other formats:
///
/// ```swift
/// let formatter = NumberFormatter()
/// formatter.numberStyle = .currency
/// formatter.currencyCode = "USD"
///
/// NumberFlowText(value: 99.99, formatter: formatter)
/// ```
@_exported import SwiftUI
