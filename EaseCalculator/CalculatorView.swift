import SwiftUI

struct CalculatorView: View {
    @State private var engine = CalculatorEngine()

    private let grid: [[CalculatorButton]] = [
        [.command("AC", .clear), .command("±", .sign), .command("%", .percent), .operation("÷", .divide)],
        [.number("7"), .number("8"), .number("9"), .operation("×", .multiply)],
        [.number("4"), .number("5"), .number("6"), .operation("−", .subtract)],
        [.number("1"), .number("2"), .number("3"), .operation("+", .add)],
        [.number("0"), .decimal, .command("=", .equals)]
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.04, green: 0.08, blue: 0.13), Color(red: 0.08, green: 0.18, blue: 0.22)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                VStack(alignment: .trailing, spacing: 8) {
                    Text("EASE")
                        .font(.caption.weight(.bold))
                        .tracking(2)
                        .foregroundStyle(.mint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(engine.expression)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(maxWidth: .infinity, minHeight: 25, alignment: .trailing)
                    Text(engine.display)
                        .font(.system(size: 58, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.42)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .accessibilityLabel("Result \(engine.display)")
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                VStack(spacing: 12) {
                    ForEach(Array(grid.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: 12) {
                            ForEach(row) { button in
                                CalculatorKey(button: button, action: { tap(button) })
                            }
                        }
                    }
                }
                .padding(16)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }

    private func tap(_ button: CalculatorButton) {
        switch button.kind {
        case .number: engine.inputDigit(button.title)
        case .decimal: engine.inputDecimal()
        case .clear: engine.clear()
        case .sign: engine.toggleSign()
        case .percent: engine.percent()
        case .equals: engine.calculate()
        case .operation(let operation): engine.chooseOperation(operation)
        }
    }
}

private struct CalculatorKey: View {
    let button: CalculatorButton
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(button.title)
                .font(.title2.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(background, in: Capsule())
                .foregroundStyle(foreground)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(button.accessibilityLabel)
    }

    private var background: Color {
        switch button.kind {
        case .operation, .equals: .mint
        case .clear, .sign, .percent: .white.opacity(0.22)
        default: .white.opacity(0.12)
        }
    }

    private var foreground: Color {
        switch button.kind {
        case .operation, .equals: .black
        default: .white
        }
    }
}

private struct CalculatorButton: Identifiable {
    enum Kind { case number, decimal, clear, sign, percent, equals, operation(CalculatorOperation) }
    let title: String
    let kind: Kind
    var id: String { title }
    var accessibilityLabel: String {
        switch kind {
        case .operation(let operation): operation.rawValue == "×" ? "Multiply" : operation.rawValue == "÷" ? "Divide" : operation.rawValue == "−" ? "Subtract" : "Add"
        case .decimal: "Decimal point"
        case .clear: "Clear calculator"
        case .sign: "Toggle positive or negative"
        case .percent: "Percent"
        case .equals: "Equals"
        case .number: title
        }
    }
    static func number(_ title: String) -> CalculatorButton { .init(title: title, kind: .number) }
    static func command(_ title: String, _ kind: Kind) -> CalculatorButton { .init(title: title, kind: kind) }
    static func operation(_ title: String, _ operation: CalculatorOperation) -> CalculatorButton { .init(title: title, kind: .operation(operation)) }
    static let decimal = CalculatorButton(title: ".", kind: .decimal)
}

#Preview {
    CalculatorView()
}
