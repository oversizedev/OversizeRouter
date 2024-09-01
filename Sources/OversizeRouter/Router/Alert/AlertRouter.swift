//
// Copyright © 2024 Alexander Romanov
// AlertRouter.swift, created on 11.04.2024
//

import Foundation

public typealias AlertRouter = AppAlertRouter<AppAlert>

@Observable
public final class AppAlertRouter<RootAlert: Alertable> {
    // Alert
    public var alert: RootAlert?

    public init() {}

    public convenience init(alert: RootAlert? = nil) where RootAlert == AppAlert {
        self.init()
        self.alert = alert
    }
}

public extension AppAlertRouter {
    func present(_ alert: RootAlert) {
        self.alert = alert
    }

    func dismiss() {
        alert = nil
    }
}
