//
// Copyright © 2024 Alexander Romanov
// AlertRouter.swift, created on 11.04.2024
//

import OversizeLocalizable
import OversizeModels
import SwiftUI

public enum AppAlert: Alertable {
    case dismiss(_ action: () -> Void)
    case delete(_ action: () -> Void)
    case appError(error: AppError)
    case text(_ title: String)
}

public extension AppAlert {
    var id: String {
        switch self {
        case .dismiss:
            "dismiss"
        case .delete:
            "delete"
        case .appError:
            "appError"
        case .text:
            "textTitle"
        }
    }
}

public extension AppAlert {
    var alert: Alert {
        switch self {
        case let .dismiss(action):
            Alert(
                title: Text("Are you sure you want to dismiss?"),
                primaryButton: .destructive(Text("Dismiss"), action: action),
                secondaryButton: .cancel()
            )
        case let .delete(action):
            Alert(
                title: Text("Are you sure you want to delete?"),
                primaryButton: .destructive(Text("\(L10n.Button.delete)"), action: action),
                secondaryButton: .cancel()
            )
        case let .appError(error: error):
            Alert(
                title: Text(error.title),
                message: Text(error.subtitle.valueOrEmpty),
                dismissButton: .cancel()
            )
        case let .text(title):
            Alert(
                title: Text(title),
                dismissButton: .default(Text("Ok"))
            )
        }
    }
}
