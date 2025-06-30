//
// Copyright © 2024 Alexander Romanov
// RoutingSplitView.swift, created on 06.08.2024
//

import OversizeUI
import SwiftUI

public struct RoutingSplitView<TopSidebar, BottomSidebar, Tab, Destination, Toolbar>: View
    where Tab: TabableView,
    Destination: RoutableView,
    TopSidebar: View,
    BottomSidebar: View,
    Toolbar: ToolbarContent
{
    @State private var splitRouter: SplitRouter<Tab, Destination>
    @State private var hudRouter: HUDRouter = .init()
    #if os(macOS)
    @State private var alertRouter: AlertRouter = .init()
    #endif
    @State var navigationSplitViewVisibility: NavigationSplitViewVisibility = .all

    private let topSidebar: TopSidebar?
    private let bottomSidebar: BottomSidebar?
    private let toolbar: Toolbar?

    public init(
        router: SplitRouter<Tab, Destination>,
        @ViewBuilder topSidebar: () -> TopSidebar,
        @ViewBuilder bottomSidebar: () -> BottomSidebar,
        @ToolbarContentBuilder toolbar: () -> Toolbar
    ) {
        splitRouter = router
        self.topSidebar = topSidebar()
        self.bottomSidebar = bottomSidebar()
        self.toolbar = toolbar()
    }

    public init(
        selection: Tab,
        tabs: [Tab],
        @ViewBuilder topSidebar: () -> TopSidebar,
        @ViewBuilder bottomSidebar: () -> BottomSidebar,
        @ToolbarContentBuilder toolbar: () -> Toolbar
    ) {
        splitRouter = .init(selection: selection, tabs: tabs)
        self.topSidebar = topSidebar()
        self.bottomSidebar = bottomSidebar()
        self.toolbar = toolbar()
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $navigationSplitViewVisibility) {
            sidebar.navigationSplitViewColumnWidth(min: 200, ideal: 280, max: 350)
                .environment(hudRouter)
                .environment(splitRouter)
            #if os(macOS)
                .environment(alertRouter)
            #endif
        } detail: {
            splitRouter.selection
                .view()
                .environment(hudRouter)
                .environment(splitRouter)
            #if os(macOS)
                .environment(alertRouter)
            #endif
        }
        .hud(hudRouter.hudText, autoHide: hudRouter.isAutoHide, isPresented: $hudRouter.isShowHud)
        #if os(macOS)
            .alert(item: $alertRouter.alert) { $0.alert }
            .sheet(item: $splitRouter.sheet, onDismiss: splitRouter.onDismiss) { sheet in
                NavigationStack(path: $splitRouter.sheetPath) {
                    sheet.view()
                        .navigationDestination(for: Destination.self) { destination in
                            destination.view()
                        }
                }

                .frame(
                    width: splitRouter.sheetWidth,
                    height: splitRouter.sheetHeight,
                )

                .presentationDetents(splitRouter.sheetDetents)
                .presentationDragIndicator(splitRouter.dragIndicator)
                .interactiveDismissDisabled(splitRouter.dismissDisabled)
                .alert(item: $alertRouter.alert) { $0.alert }
                .environment(splitRouter)
                .environment(alertRouter)
                .sheet(item: $splitRouter.overlaySheet, onDismiss: splitRouter.overlayOnDismiss) { sheet in
                    NavigationStack(path: $splitRouter.overlaySheetPath) {
                        sheet.view()
                            .navigationDestination(for: Destination.self) { destination in
                                destination.view()
                            }
                    }

                    .frame(
                        width: splitRouter.overlaySheetWidth,
                        height: splitRouter.overlaySheetHeight,
                    )

                    .alert(item: $alertRouter.alert) { $0.alert }
                    .presentationDetents(splitRouter.overlaySheetDetents)
                    .presentationDragIndicator(splitRouter.overlayDragIndicator)
                    .interactiveDismissDisabled(splitRouter.overlayDismissDisabled)
                    .environment(splitRouter)
                    .environment(alertRouter)
                }
            }
        #endif
            .environment(splitRouter)
            .environment(hudRouter)
    }

    private var sidebar: some View {
        #if os(iOS) || os(watchOS) || os(tvOS)
        List {
            ForEach(splitRouter.tabs) { menu in
                NavigationLink(value: menu) {
                    Text(menu.title)
                }
            }
        }
        #if os(iOS)
        .listStyle(.sidebar)
        #endif
        #else
        List(selection: $splitRouter.selection) {
            topSidebar

            ForEach(splitRouter.tabs) { menu in
                NavigationLink(value: menu) {
                    HStack(spacing: 10) {
                        menu.icon
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)

                        Text(menu.title)
                            .headline(.medium)
                    }
                }
                .listRowInsets(
                    .init(top: 8, leading: 6, bottom: 8, trailing: 8),
                )
            }

            bottomSidebar
        }
        .listRowSeparator(.hidden)
        .listRowSeparator(.hidden, edges: .all)
        .listRowSeparatorTint(nil)
        .toolbar { toolbar }
        #endif
    }
}

// public extension RoutingSplitView where TopSidebar == Never, BottomSidebar == Never, Toolbar == Never {
//    init(
//        selection: Tab,
//        tabs: [Tab]
//    ) {
//        router = .init(selection: selection, tabs: tabs)
//        topSidebar = nil
//        bottomSidebar = nil
//        toolbar = nil
//    }
// }
//
// public extension RoutingSplitView where TopSidebar == Never, Toolbar == Never {
//    init(
//        selection: Tab,
//        tabs: [Tab],
//        @ViewBuilder bottomSidebar: () -> BottomSidebar
//    ) {
//        router = .init(selection: selection, tabs: tabs)
//        topSidebar = nil
//        self.bottomSidebar = bottomSidebar()
//        toolbar = nil
//    }
// }
//
// public extension RoutingSplitView where BottomSidebar == Never, Toolbar == Never {
//    init(
//        selection: Tab,
//        tabs: [Tab],
//        @ViewBuilder topSidebar: () -> TopSidebar
//    ) {
//        router = .init(selection: selection, tabs: tabs)
//        self.topSidebar = topSidebar()
//        bottomSidebar = nil
//        toolbar = nil
//    }
// }
//
// public extension RoutingSplitView where TopSidebar == Never, BottomSidebar == Never {
//    init(
//        selection: Tab,
//        tabs: [Tab],
//        @ToolbarContentBuilder toolbar: () -> Toolbar
//    ) {
//        router = .init(selection: selection, tabs: tabs)
//        topSidebar = nil
//        bottomSidebar = nil
//        self.toolbar = toolbar()
//    }
// }
//
// public extension RoutingSplitView where TopSidebar == Never {
//    init(
//        selection: Tab,
//        tabs: [Tab],
//        @ViewBuilder bottomSidebar: () -> BottomSidebar,
//        @ToolbarContentBuilder toolbar: () -> Toolbar
//    ) {
//        router = .init(selection: selection, tabs: tabs)
//        topSidebar = nil
//        self.bottomSidebar = bottomSidebar()
//        self.toolbar = toolbar()
//    }
// }
//
// public extension RoutingSplitView where BottomSidebar == Never {
//    init(
//        selection: Tab,
//        tabs: [Tab],
//        @ViewBuilder topSidebar: () -> TopSidebar,
//        @ToolbarContentBuilder toolbar: () -> Toolbar
//    ) {
//        router = .init(selection: selection, tabs: tabs)
//        self.topSidebar = topSidebar()
//        bottomSidebar = nil
//        self.toolbar = toolbar()
//    }
// }
//
// public extension RoutingSplitView where TopSidebar == Never, BottomSidebar == Never, Toolbar == Never {
//    init(
//        router: TabRouter<Tab>
//    ) {
//        self.router = router
//        topSidebar = nil
//        bottomSidebar = nil
//        toolbar = nil
//    }
// }
//
// public extension RoutingSplitView where TopSidebar == Never, Toolbar == Never {
//    init(
//        router: TabRouter<Tab>,
//        @ViewBuilder bottomSidebar: () -> BottomSidebar
//    ) {
//        self.router = router
//        topSidebar = nil
//        self.bottomSidebar = bottomSidebar()
//        toolbar = nil
//    }
// }
//
// public extension RoutingSplitView where BottomSidebar == Never, Toolbar == Never {
//    init(
//        router: TabRouter<Tab>,
//        @ViewBuilder topSidebar: () -> TopSidebar
//    ) {
//        self.router = router
//        self.topSidebar = topSidebar()
//        bottomSidebar = nil
//        toolbar = nil
//    }
// }
//
// public extension RoutingSplitView where TopSidebar == Never, BottomSidebar == Never {
//    init(
//        router: TabRouter<Tab>,
//        @ToolbarContentBuilder toolbar: () -> Toolbar
//    ) {
//        self.router = router
//        topSidebar = nil
//        bottomSidebar = nil
//        self.toolbar = toolbar()
//    }
// }
//
// public extension RoutingSplitView where TopSidebar == Never {
//    init(
//        router: TabRouter<Tab>,
//        @ViewBuilder bottomSidebar: () -> BottomSidebar,
//        @ToolbarContentBuilder toolbar: () -> Toolbar
//    ) {
//        self.router = router
//        topSidebar = nil
//        self.bottomSidebar = bottomSidebar()
//        self.toolbar = toolbar()
//    }
// }
//
// public extension RoutingSplitView where BottomSidebar == Never {
//    init(
//        router: TabRouter<Tab>,
//        @ViewBuilder topSidebar: () -> TopSidebar,
//        @ToolbarContentBuilder toolbar: () -> Toolbar
//    ) {
//        self.router = router
//        self.topSidebar = topSidebar()
//        bottomSidebar = nil
//        self.toolbar = toolbar()
//    }
// }
