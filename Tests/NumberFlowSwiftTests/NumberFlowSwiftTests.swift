import XCTest
@testable import NumberFlowSwift

final class NumberFlowTextTests: XCTestCase {
    
    func testDoubleInitialization() {
        let view = NumberFlowText(value: 123.0)
        XCTAssertNotNil(view)
    }
    
    func testDecimalInitialization() {
        let decimal: Decimal = 456.78
        let view = NumberFlowText(value: decimal)
        XCTAssertNotNil(view)
    }
    
    func testCustomFormatter() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        let view = NumberFlowText(value: 99.99, formatter: formatter)
        XCTAssertNotNil(view)
    }
}
