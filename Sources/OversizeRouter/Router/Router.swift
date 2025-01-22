//
// Copyright © 2024 Alexander Romanov
// Router.swift, created on 13.04.2024
//

import SwiftUI

@MainActor
@Observable
public final class Router<Destination: Routable> {
    // Path
    public var path = NavigationPath()
    public var sheetPath = NavigationPath()
    public var fullScreenCoverPath = NavigationPath()

    // Sheets
    public var sheet: Destination?
    public var fullScreenCover: Destination?
    public var menu: Destination?
    public var sheetDetents: Set<PresentationDetent> = []
    public var dragIndicator: Visibility = .hidden
    public var dismissDisabled: Bool = false
    #if os(macOS)
    public var sheetHeight: CGFloat = 500
    public var sheetWidth: CGFloat?
    #endif

    var deeplinkHandler: DeeplinkHandler<Destination>?

    public init(deeplinkHandler: DeeplinkHandler<Destination>? = nil) {
        self.deeplinkHandler = deeplinkHandler
    }
}

public extension Router {
    func changeMenu(_ screen: Destination) {
        menu = screen
    }
}

public extension Router {
    func move(_ screen: Destination) {
        path.append(screen)
    }

    func backToRoot() {
        path.removeLast(path.count)
    }

    func back(_ count: Int = 1) {
        let pathCount = path.count - count
        if pathCount > -1 {
            path.removeLast(count)
        }
    }

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

            case let .presentFullScreen:
                present(destination, fullScreen: true)
            }
        }
    }
    #endif
}

// MARK: - Sheets

public extension Router {
    #if os(macOS)
    func present(_ sheet: Destination, sheetHeight: CGFloat = 500, sheetWidth: CGFloat? = nil) {
        restSheet()
        self.sheetHeight = sheetHeight
        self.sheetWidth = sheetWidth
        self.sheet = sheet
    }
    #else
    func present(_ sheet: Destination, fullScreen: Bool = false) {
        if fullScreen {
            if fullScreenCover != nil {
                fullScreenCover = nil
            }
            fullScreenCover = sheet
        } else {
            restSheet()
            self.sheet = sheet
        }
    }

    func present(_ sheet: Destination, detents: Set<PresentationDetent> = [.large], indicator: Visibility = .hidden, dismissDisabled: Bool = false) {
        restSheet()
        sheetDetents = detents
        dragIndicator = indicator
        self.dismissDisabled = dismissDisabled
        self.sheet = sheet
    }
    #endif

    func backOrDismiss() {
        if sheet != nil || fullScreenCover != nil {
            sheet = nil
            fullScreenCover = nil
        } else {
            back()
        }
    }

    func dismiss() {
        sheet = nil
        fullScreenCover = nil
    }

    func dismissSheet() {
        sheet = nil
    }

    func dismissFullScreenCover() {
        fullScreenCover = nil
    }

    func dismissDisabled(_ isDismissDisabled: Bool = true) {
        dismissDisabled = isDismissDisabled
    }

    private func restSheet() {
        if sheet != nil {
            sheet = nil
        }
        if fullScreenCover != nil {
            fullScreenCover = nil
        }
        if dragIndicator != .hidden {
            dragIndicator = .hidden
        }
        if dismissDisabled {
            dismissDisabled = false
        }
        if sheetDetents.isEmpty == false {
            sheetDetents = []
        }
        #if os(macOS)
        sheetHeight = 500
        sheetWidth = nil
        #endif
    }
}
