//
// Copyright © 2024 Alexander Romanov
// RoutingSidebarView.swift, created on 17.08.2024
//

import OversizeServices
import OversizeUI
import SwiftUI

public struct RoutingSidebarView<Tab>: View where Tab: TabableView {
    @State private var router: TabRouter<Tab>
    @State private var hudRouter: HUDRouter = .init()

    public init(router: TabRouter<Tab>) {
        self.router = router
    }

    public init(selection: Tab, tabs: [Tab]) {
        router = .init(selection: selection, tabs: tabs)
    }

    public var body: some View {
        if #available(macOS 15.0, iOS 18.0, *) {
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
            .tabViewStyle(.sidebarAdaptable)
            .hud(hudRouter.hudText, isPresented: $hudRouter.isShowHud)
        } else {
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
}
