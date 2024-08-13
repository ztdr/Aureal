import Cocoa
import Combine

class DeviceViewModel {
    private let device: AuraUSBDevice

    let connectionState: AnyPublisher<AuraDeviceConnectionState, Never>

    init(device: AuraUSBDevice) {
        self.device = device

        connectionState = device.$connectionState.eraseToAnyPublisher()
    }
}

class DeviceViewController: NSViewController {
    @IBOutlet private var connectedStatusLabel: NSTextField!
    @IBOutlet private var effectsPopUpButton: NSPopUpButton!
    @IBOutlet private var colorWellsStackView: NSStackView!
    @IBOutlet private var gradientView: GradientView!
    @IBOutlet private var gradientControlsStackView: NSStackView!
    @IBOutlet private var speedPopUpButton: NSPopUpButton!
    @IBOutlet private var speedLabel: NSTextField!
    
    private var cancellableSet: Set<AnyCancellable> = []

    var viewModel: DeviceViewModel!
    var selectedDevice: AuraUSBDevice?

    let defaultPalette = [NSColor]([
//        NSColor(red: 0 / 255, green: 255 / 255, blue: 0 / 255, alpha: 1),
//        NSColor(red: 0 / 255, green: 255 / 255, blue: 0 / 255, alpha: 1),
        NSColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1),
        NSColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1),
//        NSColor(red: 255 / 255, green: 218 / 255, blue: 255 / 255, alpha: 1),
    ])

    private var currentEffect: Effect!
    private var currentColors = [NSColor]()
    private var currentColorsVisibleCount: Int = 1

    private var effects = [Effect]()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.connectionState
            .receive(on: DispatchQueue.main)
            .map { $0.description }
            .assign(to: \.stringValue, on: connectedStatusLabel)
            .store(in: &cancellableSet)

        // set up effects list
        effects = [
            DirectEffect(name: "Rolling Gradient", builder: { colors -> DirectCommand in
                RollingGradientDirectCommand(colors: colors)
            }, colorMode: .dynamic),
            DirectEffect(name: "Gradient", builder: { colors -> DirectCommand in
                GradientDirectCommand(colors: colors)
            }, colorMode: .dynamic),
            DirectEffect(name: "Spaced", builder: { colors -> DirectCommand in
                SpacedDirectCommand(color: colors.first ?? .red)
            }, colorMode: .count(1))
        ] + AuraEffect.effects.map { BuiltInEffect(mode: $0) }

        effectsPopUpButton.removeAllItems()
        for effect in effects {
            effectsPopUpButton.addItem(withTitle: effect.name)
        }

        // set defaults
        currentColors = (0..<defaultPalette.count).map { idx in
            defaultPalette[idx % defaultPalette.count]
        }
        currentEffect = effects.first!
        effectsPopUpButton.selectItem(at: 0)
        currentColorsVisibleCount = currentEffect.colorMode.count
        updateColorsStackView()
        updateGradient()
    }

    @objc
    func handleColor(sender: Any) {
        guard let colorWell = sender as? NSColorWell else {
            return
        }

        currentColors[colorWell.tag] = colorWell.color

        update()
        updateGradient()
    }

    @IBAction func handleEffect(sender: Any) {
        let idx = effectsPopUpButton.indexOfSelectedItem

        guard
            idx >= 0,
            idx < effects.count
            else {
                return
        }

        currentEffect = effects[idx]
        currentColorsVisibleCount = currentEffect.colorMode.count

        update()
        updateColorsStackView()
    }
    
    @IBAction func handleSpeed(sender: Any) {
        update()
    }
    
    @IBAction func handleAddColor(sender: Any) {
        currentColorsVisibleCount += 1
        updateColorsStackView()
    }

    @IBAction func handleRemoveColor(sender: Any) {
        currentColorsVisibleCount -= 1
        if currentColorsVisibleCount < 0 {
            currentColorsVisibleCount = 0
        }

        updateColorsStackView()
    }
    
    private func run(effect: Command, speed: Int) {
        // TODO: should this come from an arg?
        guard let sd = selectedDevice else {
            return
        }

        try? DeviceManager.shared
            .effectRunner
            .run(
                command: effect,
                on: sd,
                speed: speed
            )
    }

    private func update() {
        let commandColors = currentColors
            .map { CommandColor(color: $0) }
            .prefix(currentColorsVisibleCount)
        let command: Command

        command = currentEffect.command(for: Array(commandColors))
        
        speedPopUpButton!.isHidden = !command.isAnimated
        speedLabel!.isHidden  = !command.isAnimated
        
        let speed: Int
        switch (speedPopUpButton!.selectedItem!.title) {
        case "Fast":
            speed = 7
        case "Medium":
            speed = 4
        default:
            speed = 1
        }

        run(effect: command, speed: speed)
    }

    private func updateGradient() {
        gradientView.update(
            with: Array(currentColors.prefix(currentColorsVisibleCount))
        )
    }

    private func updateColorsStackView() {
        let count = currentColorsVisibleCount

        if count > currentColors.count {
            for idx in currentColors.count..<count {
                currentColors.append(defaultPalette[idx % defaultPalette.count])
            }
        }

        if count > colorWellsStackView.arrangedSubviews.count {
            for idx in colorWellsStackView.arrangedSubviews.count..<count {
                let colorWell = NSColorWell(frame: .init(x: 0, y: 0, width: 44, height: 44))
                colorWell.tag = idx
                colorWell.color = currentColors[idx]
                colorWell.target = self
                colorWell.action = #selector(handleColor(sender:))
                colorWell.isBordered = true

                colorWellsStackView.addArrangedSubview(colorWell)

                handleColor(sender: colorWell)
            }
        } else {
            for _ in count..<colorWellsStackView.arrangedSubviews.count {
                if  colorWellsStackView.arrangedSubviews.count > 0 {
                    colorWellsStackView.removeView(
                        colorWellsStackView.arrangedSubviews[colorWellsStackView.arrangedSubviews.count - 1]
                    )
                }
            }
        }

        gradientControlsStackView.isHidden = currentEffect.colorMode != .dynamic

        updateGradient()
    }
}

fileprivate extension NSColor {
    static var goodRed: NSColor {
        self.init(calibratedRed: 255 / 255, green: 0 / 255, blue: 25 / 255, alpha: 1)
    }
}

fileprivate extension AuraDeviceConnectionState {
    var description: String {
        switch self {
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        }
    }
}
