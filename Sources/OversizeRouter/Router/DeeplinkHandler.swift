//
// Copyright © 2024 Alexander Romanov
// DeeplinkHandler.swift, created on 13.11.2024
//

import SwiftUI

public enum NavigationType {
    case move
    #if os(macOS)
    case present(sheetHeight: CGFloat = 500, sheetWidth: CGFloat? = nil)
    #else
    case present(detents: Set<PresentationDetent> = [.large], indicator: Visibility = .hidden, dismissDisabled: Bool = false)
    case presentFullScreen
    #endif
}

open class DeeplinkHandler<Destination: Routable> {
    public init() {}

    open func handleDeeplink(url _: URL) -> (Destination, NavigationType)? {
        fatalError("Handle the deeplink")
    }
}
