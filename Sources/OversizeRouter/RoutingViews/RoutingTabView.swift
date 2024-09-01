//
// Copyright © 2024 Alexander Romanov
// TabRoutingView.swift, created on 06.08.2024
//

import OversizeServices
import OversizeUI
import SwiftUI

public struct RoutingTabView<Tab>: View where Tab: TabableView {
    @State private var router: TabRouter<Tab>
    @State private var hudRouter: HUDRouter = .init()

    public init(router: TabRouter<Tab>) {
        self.router = router
    }

    public init(selection: Tab, tabs: [Tab]) {
        router = .init(selection: selection, tabs: tabs)
    }

    public var body: some View {
        TabView(selection: $router.selection) {
            ForEach(router.tabs) { tab in
                tab.view()
                    .tag(tab)
                    .tabItem {
                        tab.icon
                        Text(tab.title)
                    }
                    .environment(router)
                    .environment(hudRouter)
            }
        }
        .hud(hudRouter.hudText, isPresented: $hudRouter.isShowHud)
    }
}
