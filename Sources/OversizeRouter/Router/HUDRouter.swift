//
// Copyright © 2024 Alexander Romanov
// HUDRouter.swift, created on 14.04.2024
//

import Foundation

public enum HUDMessageType {
    case `default`
    case success
    case destructive
    case delete
    case archive
    case unarchive
    case favorite
    case unfavorite
}

@Observable
public class HUDRouter {
    public var isShowHud: Bool = false
    public var hudText: String = ""
    public var style: HUDMessageType = .default

    public init() {}
}

public extension HUDRouter {
    func present(_ text: String, style: HUDMessageType = .default) {
        hudText = text
        self.style = style
        isShowHud = true
    }
}
