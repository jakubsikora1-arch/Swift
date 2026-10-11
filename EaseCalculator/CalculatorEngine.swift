import Foundation

enum CalculatorOperation: String {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
}

struct CalculatorEngine {
    private(set) var display = "0"
    private(set) var expression = ""
    private var storedValue: Double?
    private var pendingOperation: CalculatorOperation?
    private var isEnteringValue = false

    mutating func inputDigit(_ digit: String) {
        if display == "Error" { clear() }
        if isEnteringValue {
            display = display == "0" ? digit : display + digit
        } else {
            display = digit
            isEnteringValue = true
        }
    }

    mutating func inputDecimal() {
        if display == "Error" { clear() }
        if !isEnteringValue {
            display = "0."
            isEnteringValue = true
        } else if !display.contains(".") {
            display += "."
        }
    }

    mutating func toggleSign() {
        guard display != "0", display != "Error" else { return }
        display = display.hasPrefix("-") ? String(display.dropFirst()) : "-" + display
    }

    mutating func percent() {
        guard let value = Double(display) else { return }
        display = formatted(value / 100)
        isEnteringValue = true
    }

    mutating func chooseOperation(_ operation: CalculatorOperation) {
        guard let value = Double(display) else { return }
        if let pendingOperation, storedValue != nil, isEnteringValue {
            perform(pendingOperation, with: value)
        } else {
            storedValue = value
        }
        pendingOperation = operation
        expression = "\(formatted(storedValue ?? value)) \(operation.rawValue)"
        isEnteringValue = false
    }

    mutating func calculate() {
        guard let operation = pendingOperation, let value = Double(display) else { return }
        perform(operation, with: value)
        pendingOperation = nil
        expression = ""
        isEnteringValue = false
    }

    mutating func clear() {
        display = "0"
        expression = ""
        storedValue = nil
        pendingOperation = nil
        isEnteringValue = false
    }

    private mutating func perform(_ operation: CalculatorOperation, with value: Double) {
        guard let storedValue else { return }
        let result: Double?
        switch operation {
        case .add: result = storedValue + value
        case .subtract: result = storedValue - value
        case .multiply: result = storedValue * value
        case .divide: result = value == 0 ? nil : storedValue / value
        }
        guard let result, result.isFinite else {
            display = "Error"
            self.storedValue = nil
            return
        }
        display = formatted(result)
        self.storedValue = result
    }

    private func formatted(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...8)).grouping(.never))
    }
}
