//
// Copyright © 2024 Alexander Romanov
// Sheet.swift, created on 08.12.2024
//

import Foundation
import SwiftUI

public struct Sheet<Destination: Routable>: Identifiable {
    public let id = UUID()
    public var sheet: Destination
    public var sheetPath = NavigationPath()
    public var sheetDetents: Set<PresentationDetent> = []
    public var dragIndicator: Visibility = .hidden
    public var dismissDisabled: Bool = false

    #if os(macOS)
    public var sheetHeight: CGFloat = 500
    public var sheetWidth: CGFloat?
    #endif
}
