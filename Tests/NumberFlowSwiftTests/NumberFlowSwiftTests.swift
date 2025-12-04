import Testing
@testable import NumberFlowSwift

@Suite("NumberFlowText Tests")
struct NumberFlowTextTests {
    
    @Test("NumberFlowText initializes with Double value")
    func testDoubleInitialization() {
        let view = NumberFlowText(value: 123.0)
        #expect(view != nil)
    }
    
    @Test("NumberFlowText initializes with Decimal value")
    func testDecimalInitialization() {
        let decimal: Decimal = 456.78
        let view = NumberFlowText(value: decimal)
        #expect(view != nil)
    }
    
    @Test("NumberFlowText works with custom formatter")
    func testCustomFormatter() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        let view = NumberFlowText(value: 99.99, formatter: formatter)
        #expect(view != nil)
    }
}
