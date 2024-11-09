//
// Copyright © 2024 Alexander Romanov
// RoutingView.swift, created on 28.07.2024
//

import SwiftUI

public struct RoutingView<Content, Destination>: View where Content: View, Destination: RoutableView {
    @State private var router: Router<Destination> = .init()
    @State private var alertRouter: AlertRouter = .init()

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
        .alert(item: $alertRouter.alert) { $0.alert }
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
            }
        )
        #if os(iOS)
        .fullScreenCover(item: $router.fullScreenCover) { fullScreenCover in
            NavigationStack(path: $router.sheetPath) {
                fullScreenCover
                    .view()
                    .navigationDestination(for: Destination.self) { destination in
                        destination.view()
                    }
            }
            .alert(item: $alertRouter.alert) { $0.alert }
        }
        #endif
        .environment(router)
        .environment(alertRouter)
    }
}
