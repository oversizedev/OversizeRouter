//
// Copyright © 2024 Alexander Romanov
// RoutingView.swift, created on 28.07.2024
//

import SwiftUI

public struct RoutingView<Content, Destination>: View where Content: View, Destination: RoutableView {
    @State public var router: Router<Destination> = .init()
    @State private var alertRouter: AlertRouter = .init()
    @Environment(HUDRouter.self) var hudRouter

    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
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
        .alert(item: $alertRouter.alert) { $0.alert }
        .sheet(
            item: Binding(
                get: { router.sheetStack.first },
                set: { _ in
                    if !router.sheetStack.isEmpty {
                        router.sheetStack.removeFirst()
                    }
                }
            )
        ) { sheet in
            NavigationStack(path: Binding(
                get: { sheet.sheetPath },
                set: { newPath in
                    if let index = router.sheetStack.firstIndex(where: { $0.id == sheet.id }) {
                        router.sheetStack[index].sheetPath = newPath
                    }
                }
            )) {
                sheet.sheet.view()
                    .navigationDestination(for: Destination.self) { destination in
                        destination.view()
                    }
            }
            .presentationDetents(sheet.sheetDetents)
            .presentationDragIndicator(sheet.dragIndicator)
            .interactiveDismissDisabled(sheet.dismissDisabled)
            .alert(item: $alertRouter.alert) { $0.alert }
            #if os(macOS)
                .frame(width: sheet.sheetWidth, height: sheet.sheetHeight)
            #endif
                .sheets(router: Binding(
                    get: { Array(router.sheetStack.dropFirst()) },
                    set: { newStack in
                        router.sheetStack = newStack
                    }
                )) { sheet in
                    NavigationStack(path: Binding(
                        get: { sheet.sheetPath },
                        set: { newPath in
                            if let index = router.sheetStack.firstIndex(where: { $0.id == sheet.id }) {
                                router.sheetStack[index].sheetPath = newPath
                            }
                        }
                    )) {
                        sheet.sheet.view()
                            .navigationDestination(for: Destination.self) { destination in
                                destination.view()
                            }
                    }
                    .presentationDetents(sheet.sheetDetents)
                    .presentationDragIndicator(sheet.dragIndicator)
                    .interactiveDismissDisabled(sheet.dismissDisabled)
                    .alert(item: $alertRouter.alert) { $0.alert }
                    #if os(macOS)
                        .frame(width: sheet.sheetWidth, height: sheet.sheetHeight)
                    #endif
                }
        }

        .environment(router)
        .environment(alertRouter)
        .environment(hudRouter)
        .onOpenURL { url in
            router.handleDeeplink(url: url)
        }
        #if os(iOS)
        .fullScreenCover(item: $router.fullScreenCover) { fullScreenCover in
            NavigationStack(path: $router.fullScreenCoverPath) {
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
        .environment(hudRouter)
        .onOpenURL { url in
            router.handleDeeplink(url: url)
        }
    }
}

extension View {
    func sheets<Destination: Routable>(
        router: Binding<[Sheet<Destination>]>,
        content: @escaping (Sheet<Destination>) -> some View
    ) -> some View {
        sheet(
            item: Binding(
                get: { router.wrappedValue.last },
                set: { _ in
                    router.wrappedValue.removeLast()
                }
            ),
            content: content
        )
    }
}
