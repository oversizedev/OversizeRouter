//
// Copyright © 2024 Alexander Romanov
// RoutingSplitView.swift, created on 06.08.2024
//

import OversizeUI
import SwiftUI

public struct RoutingSplitView<TopSidebar, BottomSidebar, Tab, Destination>: View
    where Tab: TabableView,
    Destination: RoutableView,
    TopSidebar: View,
    BottomSidebar: View
{
    @State private var router: SplitRouter<Tab, Destination>
    @State private var hudRouter: HUDRouter = .init()
    @State private var alertRouter: AlertRouter = .init()
    @State var navigationSplitViewVisibility: NavigationSplitViewVisibility = .all

    private let topSidebar: TopSidebar?
    private let bottomSidebar: BottomSidebar?

    public init(
        router: SplitRouter<Tab, Destination>,
        @ViewBuilder topSidebar: () -> TopSidebar,
        @ViewBuilder bottomSidebar: () -> BottomSidebar
    ) {
        self.router = router
        self.topSidebar = topSidebar()
        self.bottomSidebar = bottomSidebar()
    }

    public init(
        selection: Tab,
        tabs: [Tab],
        @ViewBuilder topSidebar: () -> TopSidebar,
        @ViewBuilder bottomSidebar: () -> BottomSidebar
    ) {
        router = .init(selection: selection, tabs: tabs)
        self.topSidebar = topSidebar()
        self.bottomSidebar = bottomSidebar()
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $navigationSplitViewVisibility) {
            sidebar.navigationSplitViewColumnWidth(min: 200, ideal: 280, max: 350)
                .environment(hudRouter)
                .environment(router)
            /// .environment(alertRouter)
        } detail: {
            router.selection
                .view()
                .environment(hudRouter)
                .environment(router)
            // .environment(alertRouter)
        }
        .hud(hudRouter.hudText, autoHide: hudRouter.isAutoHide, isPresented: $hudRouter.isShowHud)
        // .alert(item: $alertRouter.alert) { $0.alert }
        .sheet(item: $router.sheet, onDismiss: router.onDismiss) { sheet in
            NavigationStack(path: $router.sheetPath) {
                sheet.view()
                    .navigationDestination(for: Destination.self) { destination in
                        destination.view()
                    }
            }

            #if os(macOS)
            .frame(
                width: router.sheetWidth,
                height: router.sheetHeight
            )
            #endif
            .presentationDetents(router.sheetDetents)
            .presentationDragIndicator(router.dragIndicator)
            .interactiveDismissDisabled(router.dismissDisabled)
            .alert(item: $alertRouter.alert) { $0.alert }
            .environment(router)
            .sheet(item: $router.overlaySheet, onDismiss: router.overlayOnDismiss) { sheet in
                NavigationStack(path: $router.overlaySheetPath) {
                    sheet.view()
                        .navigationDestination(for: Destination.self) { destination in
                            destination.view()
                        }
                }

                #if os(macOS)
                .frame(
                    width: router.overlaySheetWidth,
                    height: router.overlaySheetHeight
                )
                #endif
                .alert(item: $alertRouter.alert) { $0.alert }
                .presentationDetents(router.overlaySheetDetents)
                .presentationDragIndicator(router.overlayDragIndicator)
                .interactiveDismissDisabled(router.overlayDismissDisabled)
                .environment(router)
            }
        }
        #if os(iOS)
        .fullScreenCover(item: $router.fullScreenCover, onDismiss: router.onDismiss) { fullScreenCover in
            NavigationStack(path: $router.sheetPath) {
                fullScreenCover
                    .view()
                    .navigationDestination(for: Destination.self) { destination in
                        destination.view()
                    }
            }
            .alert(item: $alertRouter.alert) { $0.alert }
            .sheet(item: $router.overlaySheet, onDismiss: router.overlayOnDismiss) { sheet in
                NavigationStack(path: $router.overlaySheetPath) {
                    sheet.view()
                        .navigationDestination(for: Destination.self) { destination in
                            destination.view()
                        }
                }

                #if os(macOS)
                .frame(
                    width: router.overlaySheetWidth,
                    height: router.overlaySheetHeight
                )
                #endif
                .alert(item: $alertRouter.alert) { $0.alert }
                .presentationDetents(router.overlaySheetDetents)
                .presentationDragIndicator(router.overlayDragIndicator)
                .interactiveDismissDisabled(router.overlayDismissDisabled)
                .environment(router)
            }
        }
        #endif
        .environment(router)
        .environment(alertRouter)
        .environment(hudRouter)
    }

    private var sidebar: some View {
        #if os(iOS)
        List {
            ForEach(router.tabs) { menu in
                NavigationLink(value: menu) {
                    Text(menu.title)
                }
            }
        }
        .listStyle(.sidebar)
        #elseif os(watchOS) || os(tvOS)
        List {
            ForEach(router.tabs) { menu in
                NavigationLink(value: menu) {
                    Text(menu.title)
                }
            }
        }
        #else
        List(selection: $router.selection) {
            topSidebar

            ForEach(router.tabs) { menu in
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
                    .init(top: 8, leading: 6, bottom: 8, trailing: 8)
                )
            }

            bottomSidebar
        }
        .listRowSeparator(.hidden)
        .listRowSeparator(.hidden, edges: .all)
        .listRowSeparatorTint(nil)

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
