//
// Copyright © 2024 Alexander Romanov
// TabRouter.swift, created on 13.04.2024
//

import SwiftUI

@MainActor
@Observable
public class SplitRouter<Tab: Tabable, Destination: Routable> {
    public var selection: Tab
    public var tabs: [Tab]

    // Paths
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

    public init(selection: Tab, tabs: [Tab]) {
        self.selection = selection
        self.tabs = tabs
    }

    public func changeTab(_ selection: Tab) {
        self.selection = selection
    }
}

public extension SplitRouter {
    #if os(macOS)
    func present(_ sheet: Destination, sheetHeight: CGFloat = 500, sheetWidth: CGFloat? = nil, onDismiss: (() -> Void)? = nil) {
        if overlaySheet != nil {
            restOverlaySheet()
            overlaySheetHeight = sheetHeight
            overlaySheetWidth = sheetWidth
            overlaySheet = sheet
            overlayOnDismiss = onDismiss
        } else {
            if self.sheet == nil {
                restSheet()
                self.sheetHeight = sheetHeight
                self.sheetWidth = sheetWidth
                self.sheet = sheet
                self.onDismiss = onDismiss
            } else {
                overlaySheetHeight = sheetHeight
                overlaySheetWidth = sheetWidth
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
        dismiss()
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
