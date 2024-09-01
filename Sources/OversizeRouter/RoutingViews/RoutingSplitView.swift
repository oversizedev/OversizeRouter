//
// Copyright © 2024 Alexander Romanov
// RoutingSplitView.swift, created on 06.08.2024
//

import OversizeServices
import SwiftUI

public struct RoutingSplitView<Tab>: View where Tab: TabableView {
    @State private var router: TabRouter<Tab>
    @State private var hudRouter: HUDRouter = .init()
    @State var navigationSplitViewVisibility: NavigationSplitViewVisibility = .all

    public init(router: TabRouter<Tab>) {
        self.router = router
    }

    public init(selection: Tab, tabs: [Tab]) {
        router = .init(selection: selection, tabs: tabs)
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
        #else
            List(selection: $router.selection) {
                ForEach(router.tabs) { menu in
                    NavigationLink(value: menu) {
                        Label(title: { Text(menu.title) }, icon: { menu.icon })
                    }
                }
            }
            .listStyle(.sidebar)
        #endif
    }
}
