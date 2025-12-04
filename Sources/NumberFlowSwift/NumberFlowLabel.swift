//
//  NumberFlowLabel.swift
//  NumberFlowSwift
//
//  UIKit version of the animated number display.
//  Uses CAScrollLayer-based vertical digit stacks with CABasicAnimation.
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

// MARK: - NumberFlowLabel

/// A UILabel subclass that animates number changes with a slot-machine style spinning effect.
///
/// ```swift
/// let label = NumberFlowLabel()
/// label.font = .systemFont(ofSize: 48, weight: .bold)
/// label.textColor = .label
/// label.setValue(12345, animated: false)
///
/// // Later, animate to new value
/// label.setValue(12346, animated: true)
/// ```
@MainActor
public final class NumberFlowLabel: UIView {
    
    // MARK: - Public Properties
    
    /// The font used for displaying digits
    public var font: UIFont = .systemFont(ofSize: 17) {
        didSet { rebuildDigitViews() }
    }
    
    /// The text color for digits
    public var textColor: UIColor = .label {
        didSet { updateColors() }
    }
    
    /// The number formatter used to format the value
    public var formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }() {
        didSet { updateDisplay(animated: false) }
    }
    
    /// Animation duration in seconds
    public var animationDuration: TimeInterval = 0.5
    
    /// Spring damping ratio for the animation
    public var springDamping: CGFloat = 0.8
    
    // MARK: - Private Properties
    
    private var currentValue: Double = 0
    private var digitContainers: [DigitContainer] = []
    private var symbolLabels: [UILabel] = []
    private let stackView = UIStackView()
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    /// Sets the displayed value with optional animation.
    /// - Parameters:
    ///   - value: The numeric value to display
    ///   - animated: Whether to animate the change
    public func setValue(_ value: Double, animated: Bool) {
        let oldValue = currentValue
        currentValue = value
        
        if animated && oldValue != value {
            updateDisplay(animated: true)
        } else {
            updateDisplay(animated: false)
        }
    }
    
    /// Sets the displayed value from a Decimal with optional animation.
    public func setValue(_ value: Decimal, animated: Bool) {
        setValue((value as NSDecimalNumber).doubleValue, animated: animated)
    }
    
    // MARK: - Private Methods
    
    private func updateDisplay(animated: Bool) {
        let formatted = formatter.string(from: NSNumber(value: currentValue)) ?? "0"
        let parts = parseFormattedString(formatted)
        
        // Rebuild views if structure changed
        if needsRebuild(for: parts) {
            rebuildViews(for: parts, animated: animated)
        } else {
            // Just update existing digit values
            updateDigitValues(for: parts, animated: animated)
        }
    }
    
    private func parseFormattedString(_ string: String) -> [CharacterPart] {
        string.map { char in
            if let digit = char.wholeNumberValue, digit >= 0 && digit <= 9 {
                return .digit(digit)
            } else {
                return .symbol(String(char))
            }
        }
    }
    
    private func needsRebuild(for parts: [CharacterPart]) -> Bool {
        let currentParts = stackView.arrangedSubviews.map { view -> CharacterPart in
            if view is DigitContainer {
                return .digit(0)
            } else {
                return .symbol("")
            }
        }
        
        guard parts.count == currentParts.count else { return true }
        
        for (new, old) in zip(parts, currentParts) {
            switch (new, old) {
            case (.digit, .digit), (.symbol, .symbol):
                continue
            default:
                return true
            }
        }
        return false
    }
    
    private func rebuildViews(for parts: [CharacterPart], animated: Bool) {
        // Clear existing views
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        digitContainers.removeAll()
        symbolLabels.removeAll()
        
        for part in parts {
            switch part {
            case .digit(let value):
                let container = DigitContainer(font: font, textColor: textColor)
                container.setDigit(value, animated: false)
                stackView.addArrangedSubview(container)
                digitContainers.append(container)
                
            case .symbol(let char):
                let label = UILabel()
                label.text = char
                label.font = font
                label.textColor = textColor
                stackView.addArrangedSubview(label)
                symbolLabels.append(label)
            }
        }
    }
    
    private func updateDigitValues(for parts: [CharacterPart], animated: Bool) {
        var digitIndex = 0
        
        for part in parts {
            if case .digit(let value) = part {
                if digitIndex < digitContainers.count {
                    digitContainers[digitIndex].setDigit(
                        value,
                        animated: animated,
                        duration: animationDuration,
                        damping: springDamping
                    )
                }
                digitIndex += 1
            }
        }
    }
    
    private func rebuildDigitViews() {
        digitContainers.forEach { $0.font = font }
        symbolLabels.forEach { $0.font = font }
    }
    
    private func updateColors() {
        digitContainers.forEach { $0.textColor = textColor }
        symbolLabels.forEach { $0.textColor = textColor }
    }
    
    public override var intrinsicContentSize: CGSize {
        stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}

// MARK: - CharacterPart

private enum CharacterPart {
    case digit(Int)
    case symbol(String)
}

// MARK: - DigitContainer

/// A container view that holds a vertical stack of digits and animates between them.
private final class DigitContainer: UIView {
    
    var font: UIFont {
        didSet { rebuildDigits() }
    }
    
    var textColor: UIColor {
        didSet { digitLabels.forEach { $0.textColor = textColor } }
    }
    
    private var digitLabels: [UILabel] = []
    private var currentDigit: Int = 0
    private var digitHeight: CGFloat = 0
    private let contentView = UIView()
    
    init(font: UIFont, textColor: UIColor) {
        self.font = font
        self.textColor = textColor
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.font = .systemFont(ofSize: 17)
        self.textColor = .label
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        clipsToBounds = true
        addSubview(contentView)
        rebuildDigits()
    }
    
    private func rebuildDigits() {
        digitLabels.forEach { $0.removeFromSuperview() }
        digitLabels.removeAll()
        
        // Create labels for 0-9
        for i in 0..<10 {
            let label = UILabel()
            label.text = "\(i)"
            label.font = font
            label.textColor = textColor
            label.textAlignment = .center
            contentView.addSubview(label)
            digitLabels.append(label)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !digitLabels.isEmpty else { return }
        
        // Calculate digit size
        let sampleSize = "0".size(withAttributes: [.font: font])
        digitHeight = ceil(sampleSize.height * 1.2)
        let digitWidth = ceil(sampleSize.width)
        
        // Size this container
        frame.size = CGSize(width: digitWidth, height: digitHeight)
        
        // Layout the vertical stack of digits
        contentView.frame = CGRect(x: 0, y: 0, width: digitWidth, height: digitHeight * 10)
        
        for (index, label) in digitLabels.enumerated() {
            label.frame = CGRect(x: 0, y: CGFloat(index) * digitHeight, width: digitWidth, height: digitHeight)
        }
        
        // Position to show current digit
        contentView.frame.origin.y = -CGFloat(currentDigit) * digitHeight
    }
    
    func setDigit(_ digit: Int, animated: Bool, duration: TimeInterval = 0.5, damping: CGFloat = 0.8) {
        guard digit != currentDigit else { return }
        
        let oldDigit = currentDigit
        currentDigit = digit
        
        if animated {
            let targetY = -CGFloat(digit) * digitHeight
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                usingSpringWithDamping: damping,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut]
            ) {
                self.contentView.frame.origin.y = targetY
            }
        } else {
            contentView.frame.origin.y = -CGFloat(digit) * digitHeight
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let sampleSize = "0".size(withAttributes: [.font: font])
        return CGSize(width: ceil(sampleSize.width), height: ceil(sampleSize.height * 1.2))
    }
}
#endif
