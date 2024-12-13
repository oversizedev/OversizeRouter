import SwiftUI

@Observable
public final class Router<Destination: Routable>: ObservableObject {
    // Path
    public var path = NavigationPath()
    public var fullScreenCoverPath = NavigationPath()
    public var sheetStack: [Sheet<Destination>] = []

    // Sheets
    public var menu: Destination?
    public var fullScreenCover: Destination?

    public var sheetDetents: Set<PresentationDetent> {
        sheetStack.last?.sheetDetents ?? []
    }

    public var dragIndicator: Visibility {
        sheetStack.last?.dragIndicator ?? .hidden
    }

    public var dismissDisabled: Bool {
        sheetStack.last?.dismissDisabled ?? false
    }

    #if os(macOS)
    public var sheetHeight: CGFloat {
        sheetStack.last?.sheetHeight ?? 500
    }

    public var sheetWidth: CGFloat? {
        sheetStack.last?.sheetWidth
    }
    #endif

    var deeplinkHandler: DeeplinkHandler<Destination>?

    public init(deeplinkHandler: DeeplinkHandler<Destination>? = nil) {
        self.deeplinkHandler = deeplinkHandler
    }

    public init() {}
}

public extension Router {
    func changeMenu(_ screen: Destination) {
        menu = screen
    }
}

public extension Router {
    func move(_ screen: Destination) {
        if sheetStack.isEmpty {
            path.append(screen)
        } else if let lastIndex = sheetStack.indices.last {
            sheetStack[lastIndex].sheetPath.append(screen)
        }
    }

    func backToRoot() {
        if sheetStack.isEmpty {
            path.removeLast(path.count)
        } else if var lastSheet = sheetStack.last {
            lastSheet.sheetPath.removeLast(lastSheet.sheetPath.count)
            sheetStack[sheetStack.count - 1] = lastSheet
        }
    }

    func back(_ count: Int = 1) {
        if sheetStack.isEmpty {
            let pathCount = path.count - count
            if pathCount > -1 {
                path.removeLast(count)
            }
        } else if var lastSheet = sheetStack.last {
            let pathCount = lastSheet.sheetPath.count - count
            if pathCount > -1 {
                lastSheet.sheetPath.removeLast(count)
            }
        }
    }

    // MARK: - Deep Link Handling

    #if os(macOS)
    func handleDeeplink(url: URL) {
        if let (destination, navigationType) = deeplinkHandler?.handleDeeplink(url: url) {
            switch navigationType {
            case .move:
                move(destination)
            case let .present(sheetHeight: sheetHeight, sheetWidth: sheetWidth):
                present(destination, sheetHeight: sheetHeight, sheetWidth: sheetWidth)
            }
        }
    }
    #else
    func handleDeeplink(url: URL) {
        if let (destination, navigationType) = deeplinkHandler?.handleDeeplink(url: url) {
            switch navigationType {
            case .move:
                move(destination)

            case let .present(detents: detents, indicator: indicator, dismissDisabled: dismissDisabled):
                present(
                    destination,
                    detents: detents,
                    indicator: indicator,
                    dismissDisabled: dismissDisabled
                )

            case .presentFullScreen:
                present(destination, fullScreen: true)
            }
        }
    }
    #endif
}

public extension Router {
    // MARK: - Sheet Management

    #if os(macOS)
    func present(_ sheet: Destination, sheetHeight: CGFloat = 500, sheetWidth: CGFloat? = nil) {
        let newSheet = Sheet(
            sheet: sheet,
            sheetHeight: sheetHeight,
            sheetWidth: sheetWidth
        )
        sheetStack.append(newSheet)
    }
    #else

    func present(_ sheet: Destination, fullScreen: Bool) {
        if fullScreen {
            fullScreenCover = sheet
        } else {
            let newSheet = Sheet(sheet: sheet)
            sheetStack.append(newSheet)
        }
    }

    func present(_ sheet: Destination, detents: Set<PresentationDetent> = [.large], indicator: Visibility = .hidden, dismissDisabled: Bool = false) {
        let newSheet = Sheet(
            sheet: sheet,
            sheetDetents: detents,
            dragIndicator: indicator,
            dismissDisabled: dismissDisabled
        )
        sheetStack.append(newSheet)
    }
    #endif

    func backOrDismiss() {
        if !sheetStack.isEmpty {
            sheetStack.removeLast()
        } else if !path.isEmpty {
            path.removeLast()
        }
    }

    func dismiss() {
        if !sheetStack.isEmpty {
            sheetStack.removeLast()
        } else {
            fullScreenCover = nil
        }
    }

    func dismissSheet() {
        if !sheetStack.isEmpty {
            sheetStack.removeLast()
        }
    }

    func dismissDisabled(_ isDismissDisabled: Bool = true) {
        if let lastSheetIndex = sheetStack.indices.last {
            sheetStack[lastSheetIndex].dismissDisabled = isDismissDisabled
        }
    }

    func dismissAllSheets() {
        sheetStack.removeAll()
    }
}
