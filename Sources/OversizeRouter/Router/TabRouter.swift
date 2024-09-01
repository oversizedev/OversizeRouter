//
// Copyright © 2024 Alexander Romanov
// TabRouter.swift, created on 13.04.2024
//

import Foundation

@Observable
public class TabRouter<Tab: Tabable> {
    public var selection: Tab
    public var tabs: [Tab]

    public init(selection: Tab, tabs: [Tab]) {
        self.selection = selection
        self.tabs = tabs
    }

    public func changeTab(_ selection: Tab) {
        self.selection = selection
    }
}
