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
    public var overlaySheetPath = NavigationPath()
    public var fullScreenCoverPath = NavigationPath()

    // Sheets
    public var sheet: Destination?
    public var overlaySheet: Destination?
    public var fullScreenCover: Destination?
    public var menu: Destination?
    public var sheetDetents: Set<PresentationDetent> = []
    public var dragIndicator: Visibility = .hidden
    public var dismissDisabled: Bool = false
    public var overlaySheetDetents: Set<PresentationDetent> = []
    public var overlayDragIndicator: Visibility = .hidden
    public var overlayDismissDisabled: Bool = false
    #if os(macOS)
    public var sheetHeight: CGFloat = 500
    public var sheetWidth: CGFloat?
    public var overlaySheetHeight: CGFloat = 500
    public var overlaySheetWidth: CGFloat?
    #endif

    var onDismiss: (() -> Void)?
    var overlayOnDismiss: (() -> Void)?
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
                present(destination, height: sheetHeight, width: sheetWidth)
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
                    dismissDisabled: dismissDisabled,
                )

            case .presentFullScreen:
                present(destination, fullScreen: true)
            }
        }
    }
    #endif
}

// MARK: - Sheets

public extension Router {
    #if os(macOS)
    func present(_ sheet: Destination, height: CGFloat = 500, width: CGFloat? = nil, onDismiss: (() -> Void)? = nil) {
        if overlaySheet != nil {
            restOverlaySheet()
            overlaySheetHeight = height
            overlaySheetWidth = width
            overlaySheet = sheet
            overlayOnDismiss = onDismiss
        } else {
            if self.sheet == nil {
                restSheet()
                sheetHeight = height
                sheetWidth = width
                self.sheet = sheet
                self.onDismiss = onDismiss
            } else {
                overlaySheetHeight = height
                overlaySheetWidth = width
                overlaySheet = sheet
                overlayOnDismiss = onDismiss
            }
        }
    }
    #else
    func present(_ sheet: Destination, fullScreen: Bool = false, onDismiss: (() -> Void)? = nil) {
        if fullScreen {
            if fullScreenCover != nil {
                fullScreenCover = nil
            }
            fullScreenCover = sheet
        } else {
            restSheet()
            self.sheet = sheet
        }
        self.onDismiss = onDismiss
    }

    func present(_ sheet: Destination, detents: Set<PresentationDetent> = [.large], indicator: Visibility = .hidden, dismissDisabled: Bool = false, onDismiss: (() -> Void)? = nil) {
        restSheet()
        sheetDetents = detents
        dragIndicator = indicator
        self.dismissDisabled = dismissDisabled
        self.sheet = sheet
        self.onDismiss = onDismiss
    }
    #endif

    func backOrDismiss() {
        if overlaySheet != nil {
            overlaySheet = nil

        } else {
            if sheet != nil || fullScreenCover != nil {
                sheet = nil
                fullScreenCover = nil
            } else {
                back()
            }
        }
    }

    func dismiss() {
        if overlaySheet != nil {
            overlaySheet = nil
        } else {
            sheet = nil
            fullScreenCover = nil
        }
    }

    func dismissSheet() {
        if overlaySheet != nil {
            overlaySheet = nil
        } else {
            sheet = nil
        }
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

    private func restOverlaySheet() {
        if overlaySheet != nil {
            overlaySheet = nil
        }
        if overlayDragIndicator != .hidden {
            overlayDragIndicator = .hidden
        }
        if overlayDismissDisabled {
            overlayDismissDisabled = false
        }
        if overlaySheetDetents.isEmpty == false {
            overlaySheetDetents = []
        }
        #if os(macOS)
        overlaySheetHeight = 500
        overlaySheetWidth = nil
        #endif
    }
}
