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

    // Path
    public var sheetPath = NavigationPath()
    public var fullScreenCoverPath = NavigationPath()

    // Sheets
    public var sheet: Destination?
    public var fullScreenCover: Destination?

    public var sheetDetents: Set<PresentationDetent> = []
    public var dragIndicator: Visibility = .hidden
    public var dismissDisabled: Bool = false
    #if os(macOS)
    public var sheetHeight: CGFloat = 500
    public var sheetWidth: CGFloat?
    #endif

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

    func backOrDismiss() {
        dismiss()
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
