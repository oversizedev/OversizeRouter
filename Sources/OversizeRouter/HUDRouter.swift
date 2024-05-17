//
// Copyright © 2024 Alexander Romanov
// HUDRouter.swift, created on 14.04.2024
//

import Foundation

public enum HUDMessageType {
    case `default`
    case success
    case destructive
    case deleted
    case archived
}

public class HUDRouter: ObservableObject {
    @Published public var isShowHud: Bool = false
    @Published public var hudText: String = ""
    @Published public var type: HUDMessageType = .default

    public init() {}
}

public extension HUDRouter {
    func present(_ text: String, type: HUDMessageType = .default) {
        hudText = text
        self.type = type
        isShowHud = true
    }
}
