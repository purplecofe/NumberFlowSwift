//
//  NumberFlowText.swift
//  NumberFlowSwift
//
//  An animated number display component inspired by barvian/number-flow.
//  Uses a spinning wheel effect where each digit position contains a
//  vertical stack of 0-9, animating via Y-axis translation.
//

import SwiftUI

// MARK: - NumberFlowText

/// An animated number display that creates a slot-machine style spinning effect
/// when values change. Each digit spins independently based on the direction
/// of change (up for increase, down for decrease).
///
/// ```swift
/// // Basic usage
/// NumberFlowText(value: 12345)
///
/// // With custom formatting
/// let formatter = NumberFormatter()
/// formatter.numberStyle = .currency
/// NumberFlowText(value: amount, formatter: formatter, font: .largeTitle)
/// ```
public struct NumberFlowText: View {
    private let value: Double
    private let formatter: NumberFormatter
    private let font: Font
    private let textColor: Color
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Animation configuration
    private let digitHeight: CGFloat = 1.2
    private let animation: Animation = .spring(response: 0.5, dampingFraction: 0.8)
    
    /// Creates an animated number display.
    /// - Parameters:
    ///   - value: The numeric value to display
    ///   - formatter: Optional NumberFormatter for custom formatting. Defaults to decimal style.
    ///   - font: The font to use for digits. Defaults to `.body`
    ///   - textColor: The color for the text. Defaults to `.primary`
    public init(
        value: Double,
        formatter: NumberFormatter? = nil,
        font: Font = .body,
        textColor: Color = .primary
    ) {
        self.value = value
        self.formatter = formatter ?? {
            let f = NumberFormatter()
            f.numberStyle = .decimal
            f.maximumFractionDigits = 0
            return f
        }()
        self.font = font
        self.textColor = textColor
    }
    
    /// Creates an animated number display from a Decimal value.
    /// - Parameters:
    ///   - value: The Decimal value to display
    ///   - formatter: Optional NumberFormatter for custom formatting
    ///   - font: The font to use for digits
    ///   - textColor: The color for the text
    public init(
        value: Decimal,
        formatter: NumberFormatter? = nil,
        font: Font = .body,
        textColor: Color = .primary
    ) {
        self.init(
            value: (value as NSDecimalNumber).doubleValue,
            formatter: formatter,
            font: font,
            textColor: textColor
        )
    }
    
    public var body: some View {
        let parts = formattedParts
        HStack(spacing: 0) {
            ForEach(Array(parts.enumerated()), id: \.offset) { _, part in
                if part.isDigit {
                    AnimatedDigit(
                        digit: part.digit,
                        font: font,
                        textColor: textColor,
                        digitHeight: digitHeight,
                        animation: reduceMotion ? nil : animation
                    )
                } else {
                    Text(part.symbol)
                        .font(font)
                        .foregroundStyle(textColor)
                }
            }
        }
    }
    
    // MARK: - Number Parsing
    
    private var formattedParts: [NumberPart] {
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "0"
        
        return formatted.map { char in
            if let digit = char.wholeNumberValue, digit >= 0 && digit <= 9 {
                return NumberPart(digit: digit)
            } else {
                return NumberPart(symbol: String(char))
            }
        }
    }
}

// MARK: - NumberPart

private struct NumberPart {
    let isDigit: Bool
    let digit: Int
    let symbol: String
    
    init(digit: Int) {
        self.isDigit = true
        self.digit = digit
        self.symbol = ""
    }
    
    init(symbol: String) {
        self.isDigit = false
        self.digit = 0
        self.symbol = symbol
    }
}

// MARK: - AnimatedDigit

/// A single digit that animates between values using a vertical spinning wheel.
private struct AnimatedDigit: View {
    let digit: Int
    let font: Font
    let textColor: Color
    let digitHeight: CGFloat
    let animation: Animation?
    
    @State private var displayedDigit: Int = 0
    
    var body: some View {
        Text("0")
            .font(font)
            .foregroundStyle(.clear)
            .overlay {
                GeometryReader { geo in
                    let height = geo.size.height * digitHeight
                    
                    VStack(spacing: 0) {
                        ForEach(0..<10, id: \.self) { num in
                            Text("\(num)")
                                .font(font)
                                .foregroundStyle(textColor)
                                .frame(height: height)
                        }
                    }
                    .offset(y: -CGFloat(displayedDigit) * height)
                }
            }
            .clipped()
            .onChange(of: digit) { _, newValue in
                if let animation {
                    withAnimation(animation) {
                        displayedDigit = newValue
                    }
                } else {
                    displayedDigit = newValue
                }
            }
            .onAppear {
                displayedDigit = digit
            }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("NumberFlowText Demo") {
    struct PreviewWrapper: View {
        @State private var value: Double = 12345
        
        private var currencyFormatter: NumberFormatter {
            let f = NumberFormatter()
            f.numberStyle = .currency
            f.currencyCode = "USD"
            return f
        }
        
        var body: some View {
            VStack(spacing: 32) {
                Text("Currency Style")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                NumberFlowText(
                    value: value,
                    formatter: currencyFormatter,
                    font: .system(size: 48, weight: .bold, design: .rounded)
                )
                
                Text("Decimal Style")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                NumberFlowText(
                    value: value,
                    font: .title
                )
                
                HStack(spacing: 16) {
                    Button("-1000") { value -= 1000 }
                    Button("+1000") { value += 1000 }
                }
                .buttonStyle(.borderedProminent)
                
                HStack(spacing: 16) {
                    Button("-1") { value -= 1 }
                    Button("+1") { value += 1 }
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
#endif
