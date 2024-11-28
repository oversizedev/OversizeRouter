//
// Copyright © 2024 Alexander Romanov
// RoutingSplitView.swift, created on 06.08.2024
//

import OversizeUI
import SwiftUI

public struct RoutingSplitView<TopSidebar, BottomSidebar, Tab, Toolbar>: View where Tab: TabableView, TopSidebar: View, BottomSidebar: View, Toolbar: ToolbarContent {
    @State private var router: TabRouter<Tab>
    @State private var hudRouter: HUDRouter = .init()
    @State var navigationSplitViewVisibility: NavigationSplitViewVisibility = .all

    private let topSidebar: TopSidebar?
    private let bottomSidebar: BottomSidebar?
    private let toolbar: Toolbar?

    public init(
        router: TabRouter<Tab>,
        @ViewBuilder topSidebar: () -> TopSidebar,
        @ViewBuilder bottomSidebar: () -> BottomSidebar,
        @ToolbarContentBuilder toolbar: () -> Toolbar
    ) {
        self.router = router
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
        router = .init(selection: selection, tabs: tabs)
        self.topSidebar = topSidebar()
        self.bottomSidebar = bottomSidebar()
        self.toolbar = toolbar()
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $navigationSplitViewVisibility) {
            sidebar.navigationSplitViewColumnWidth(min: 200, ideal: 280, max: 350)
                .environment(hudRouter)
                .environment(router)
        } detail: {
            router.selection
                .view()
                .environment(hudRouter)
                .environment(router)
        }
        .hud(hudRouter.hudText, autoHide: hudRouter.isAutoHide, isPresented: $hudRouter.isShowHud)
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
        .toolbar { toolbar }
        #endif
    }
}

public extension RoutingSplitView where TopSidebar == Never, BottomSidebar == Never, Toolbar == Never {
    init(
        selection: Tab,
        tabs: [Tab]
    ) {
        router = .init(selection: selection, tabs: tabs)
        topSidebar = nil
        bottomSidebar = nil
        toolbar = nil
    }
}

public extension RoutingSplitView where TopSidebar == Never, Toolbar == Never {
    init(
        selection: Tab,
        tabs: [Tab],
        @ViewBuilder bottomSidebar: () -> BottomSidebar
    ) {
        router = .init(selection: selection, tabs: tabs)
        topSidebar = nil
        self.bottomSidebar = bottomSidebar()
        toolbar = nil
    }
}

public extension RoutingSplitView where BottomSidebar == Never, Toolbar == Never {
    init(
        selection: Tab,
        tabs: [Tab],
        @ViewBuilder topSidebar: () -> TopSidebar
    ) {
        router = .init(selection: selection, tabs: tabs)
        self.topSidebar = topSidebar()
        bottomSidebar = nil
        toolbar = nil
    }
}

public extension RoutingSplitView where TopSidebar == Never, BottomSidebar == Never {
    init(
        selection: Tab,
        tabs: [Tab],
        @ToolbarContentBuilder toolbar: () -> Toolbar
    ) {
        router = .init(selection: selection, tabs: tabs)
        topSidebar = nil
        bottomSidebar = nil
        self.toolbar = toolbar()
    }
}

public extension RoutingSplitView where TopSidebar == Never {
    init(
        selection: Tab,
        tabs: [Tab],
        @ViewBuilder bottomSidebar: () -> BottomSidebar,
        @ToolbarContentBuilder toolbar: () -> Toolbar
    ) {
        router = .init(selection: selection, tabs: tabs)
        topSidebar = nil
        self.bottomSidebar = bottomSidebar()
        self.toolbar = toolbar()
    }
}

public extension RoutingSplitView where BottomSidebar == Never {
    init(
        selection: Tab,
        tabs: [Tab],
        @ViewBuilder topSidebar: () -> TopSidebar,
        @ToolbarContentBuilder toolbar: () -> Toolbar
    ) {
        router = .init(selection: selection, tabs: tabs)
        self.topSidebar = topSidebar()
        bottomSidebar = nil
        self.toolbar = toolbar()
    }
}

public extension RoutingSplitView where TopSidebar == Never, BottomSidebar == Never, Toolbar == Never {
    init(
        router: TabRouter<Tab>
    ) {
        self.router = router
        topSidebar = nil
        bottomSidebar = nil
        toolbar = nil
    }
}

public extension RoutingSplitView where TopSidebar == Never, Toolbar == Never {
    init(
        router: TabRouter<Tab>,
        @ViewBuilder bottomSidebar: () -> BottomSidebar
    ) {
        self.router = router
        topSidebar = nil
        self.bottomSidebar = bottomSidebar()
        toolbar = nil
    }
}

public extension RoutingSplitView where BottomSidebar == Never, Toolbar == Never {
    init(
        router: TabRouter<Tab>,
        @ViewBuilder topSidebar: () -> TopSidebar
    ) {
        self.router = router
        self.topSidebar = topSidebar()
        bottomSidebar = nil
        toolbar = nil
    }
}

public extension RoutingSplitView where TopSidebar == Never, BottomSidebar == Never {
    init(
        router: TabRouter<Tab>,
        @ToolbarContentBuilder toolbar: () -> Toolbar
    ) {
        self.router = router
        topSidebar = nil
        bottomSidebar = nil
        self.toolbar = toolbar()
    }
}

public extension RoutingSplitView where TopSidebar == Never {
    init(
        router: TabRouter<Tab>,
        @ViewBuilder bottomSidebar: () -> BottomSidebar,
        @ToolbarContentBuilder toolbar: () -> Toolbar
    ) {
        self.router = router
        topSidebar = nil
        self.bottomSidebar = bottomSidebar()
        self.toolbar = toolbar()
    }
}

public extension RoutingSplitView where BottomSidebar == Never {
    init(
        router: TabRouter<Tab>,
        @ViewBuilder topSidebar: () -> TopSidebar,
        @ToolbarContentBuilder toolbar: () -> Toolbar
    ) {
        self.router = router
        self.topSidebar = topSidebar()
        bottomSidebar = nil
        self.toolbar = toolbar()
    }
}
