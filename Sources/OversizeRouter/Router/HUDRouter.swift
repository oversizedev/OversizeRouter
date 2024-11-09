//
// Copyright © 2024 Alexander Romanov
// HUDRouter.swift, created on 14.04.2024
//

import Foundation

public enum HUDMessageType: Sendable {
    case `default`
    case success
    case destructive
    case delete
    case archive
    case unarchive
    case favorite
    case unfavorite
}

public enum HUDLoaderStatus: Sendable {
    case progress(Double? = nil)
    case success
    case failure
}

@Observable
public class HUDRouter {
    public var isShowHud: Bool = false
    public var isAutoHide: Bool = true
    public var hudText: String = ""
    public var style: HUDMessageType = .default
    public var loaderStatus: HUDLoaderStatus = .progress(nil)

    public init() {}
}

public extension HUDRouter {
    func present(_ text: String, style: HUDMessageType = .default) {
        hudText = text
        self.style = style
        isAutoHide = true
        isShowHud = true
    }

    func presentLoader(_ text: String = "Loading...", style: HUDMessageType = .default) {
        hudText = text
        self.style = style
        isAutoHide = false
        isShowHud = true
        loaderStatus = .progress(nil)
    }

    func hideLoader(style: HUDMessageType = .default, status: HUDLoaderStatus) {
        hudText = ""
        self.style = style
        isAutoHide = true
        isShowHud = false
        loaderStatus = status
    }
}
