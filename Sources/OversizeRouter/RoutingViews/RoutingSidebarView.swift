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
        #if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
            if #available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *) {
                tabView
                    .tabViewStyle(.sidebarAdaptable)
                    .hud(hudRouter.hudText, isPresented: $hudRouter.isShowHud)
            } else {
                tabView
                    .hud(hudRouter.hudText, isPresented: $hudRouter.isShowHud)
            }
        #else

            tabView
        #endif
    }

    var tabView: some View {
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
    }
}
