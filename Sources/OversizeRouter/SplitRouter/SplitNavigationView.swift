//
// Copyright © 2024 Alexander Romanov
// SplitNavigationView.swift, created on 17.02.2025
//

import SwiftUI

#if os(macOS)
public struct SplitNavigationView<Content, Destination>: View where Content: View, Destination: RoutableView {
    @State public var router: Router<Destination>
    @Environment(AlertRouter.self) private var alertRouter
    @Environment(HUDRouter.self) private var hudRouter

    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        router = .init()
        self.content = content
    }

    public init(router: Router<Destination>, @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .navigationDestination(for: Destination.self) { destination in
                    destination.view()
                        .environment(router)
                        .environment(alertRouter)
                        .environment(hudRouter)
                }
        }

        .sheet(item: $router.sheet, onDismiss: router.onDismiss) { sheet in
            NavigationStack(path: $router.sheetPath) {
                sheet.view()
                    .navigationDestination(for: Destination.self) { destination in
                        destination.view()
                    }
            }

            .frame(
                width: router.sheetWidth,
                height: router.sheetHeight
            )
            .presentationDetents(router.sheetDetents)
            .presentationDragIndicator(router.dragIndicator)
            .interactiveDismissDisabled(router.dismissDisabled)
            .environment(router)
            .sheet(item: $router.overlaySheet, onDismiss: router.overlayOnDismiss) { sheet in
                NavigationStack(path: $router.overlaySheetPath) {
                    sheet.view()
                        .navigationDestination(for: Destination.self) { destination in
                            destination.view()
                        }
                }

                .frame(
                    width: router.overlaySheetWidth,
                    height: router.overlaySheetHeight
                )

                .presentationDetents(router.overlaySheetDetents)
                .presentationDragIndicator(router.overlayDragIndicator)
                .interactiveDismissDisabled(router.overlayDismissDisabled)
                .environment(router)
            }
        }

        .environment(router)
        .environment(hudRouter)
        .environment(alertRouter)
        .onOpenURL { url in
            router.handleDeeplink(url: url)
        }
    }
}
#endif
