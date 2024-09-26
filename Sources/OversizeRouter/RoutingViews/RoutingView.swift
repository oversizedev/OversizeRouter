//
// Copyright © 2024 Alexander Romanov
// RoutingView.swift, created on 28.07.2024
//

import OversizeServices
import SwiftUI

public struct RoutingView<Content, Destination>: View where Content: View, Destination: RoutableView {
    @State private var router: Router<Destination> = .init()
    @State private var alertRouter: AlertRouter = .init()
    @State private var hudRouter: HUDRouter = .init()

    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .navigationDestination(for: Destination.self) { destination in
                    destination.view()
                }
        }
        .sheet(
            item: $router.sheet,
            content: { sheet in
                NavigationStack(path: $router.sheetPath) {
                    sheet
                        .view()
                        .navigationDestination(for: Destination.self) { destination in
                            destination.view()
                        }
                }

                .presentationDetents(router.sheetDetents)
                .presentationDragIndicator(router.dragIndicator)
                .interactiveDismissDisabled(router.dismissDisabled)
                .systemServices()
                .environment(router)
                .environment(alertRouter)
                .environment(hudRouter)
                #if os(macOS)
                    .frame(
                        width: router.sheetWidth,
                        height: router.sheetHeight
                    )
                #endif
            }
        )
        .systemServices()
        .environment(router)
        .environment(alertRouter)
        .environment(hudRouter)
        #if os(iOS)
            .fullScreenCover(item: $router.fullScreenCover) { fullScreenCover in
                NavigationStack(path: $router.sheetPath) {
                    fullScreenCover
                        .view()
                        .navigationDestination(for: Destination.self) { destination in
                            destination.view()
                        }
                }
                .systemServices()
                .environment(router)
                .environment(alertRouter)
                .environment(hudRouter)
            }
        #endif
    }
}
