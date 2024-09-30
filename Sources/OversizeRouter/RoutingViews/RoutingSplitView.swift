//
// Copyright © 2024 Alexander Romanov
// RoutingSplitView.swift, created on 06.08.2024
//

import OversizeServices
import SwiftUI

public struct RoutingSplitView<TopSidebar, BottomSidebar, Tab>: View where Tab: TabableView, TopSidebar: View, BottomSidebar: View {
    @State private var router: TabRouter<Tab>
    @State private var hudRouter: HUDRouter = .init()
    @State var navigationSplitViewVisibility: NavigationSplitViewVisibility = .all

    private let topSidebar: TopSidebar?
    private let bottomSidebar: BottomSidebar?

    public init(
        router: TabRouter<Tab>,
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
            sidebar
                .navigationSplitViewColumnWidth(200)
        } detail: {
            router.selection.view()
                .environment(router)
                .environment(hudRouter)
        }
        .hud(hudRouter.hudText, isPresented: $hudRouter.isShowHud)
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
                        Label(
                            title: { Text(menu.title) },
                            icon: { menu.icon }
                        )
                    }
                }

                bottomSidebar
            }
            .listStyle(.sidebar)
        #endif
    }
}

public extension RoutingSplitView where TopSidebar == EmptyView, BottomSidebar == EmptyView {
    init(
        selection: Tab,
        tabs: [Tab]
    ) {
        router = .init(selection: selection, tabs: tabs)
        topSidebar = nil
        bottomSidebar = nil
    }
}

public extension RoutingSplitView where TopSidebar == EmptyView {
    init(
        selection: Tab,
        tabs: [Tab],
        @ViewBuilder bottomSidebar: () -> BottomSidebar
    ) {
        router = .init(selection: selection, tabs: tabs)
        topSidebar = nil
        self.bottomSidebar = bottomSidebar()
    }
}

public extension RoutingSplitView where BottomSidebar == EmptyView {
    init(
        selection: Tab,
        tabs: [Tab],
        @ViewBuilder topSidebar: () -> TopSidebar
    ) {
        router = .init(selection: selection, tabs: tabs)
        self.topSidebar = topSidebar()
        bottomSidebar = nil
    }
}
