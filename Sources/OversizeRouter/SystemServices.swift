//
// Copyright © 2023 Alexander Romanov
// SystemServices.swift
//

import Factory
import OversizeServices
import OversizeStoreService
import OversizeUI
import SwiftUI

public struct SystemServicesModifier: ViewModifier {
    @Injected(\.appStateService) private var appState: AppStateService
    @Injected(\.settingsService) private var settingsService: SettingsServiceProtocol
    @Injected(\.appStoreReviewService) private var appStoreReviewService: AppStoreReviewServiceProtocol

    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    @Environment(\.theme) private var theme: ThemeSettings
    @AppStorage("AppState.PremiumState") private var isPremium: Bool = false

    @State private var blurRadius: CGFloat = 0
    @State private var oppacity: CGFloat = 1
    @State private var screnSize: ScreenSize = .init(width: 375, height: 667)

    enum FullScreenSheet: Identifiable, Equatable {
        case onboarding
        case payWall
        case lockscreen
        public var id: Int {
            hashValue
        }
    }

    public init() {}

    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .onChange(of: scenePhase) { _, value in
                    switch value {
                    case .active:
                        if settingsService.blurMinimizeEnabend {
                            withAnimation {
                                blurRadius = 0
                            }
                        }
                    case .background:
                        if settingsService.blurMinimizeEnabend {
                            withAnimation {
                                blurRadius = 10
                            }
                        }
                    case .inactive:
                        if settingsService.blurMinimizeEnabend {
                            withAnimation {
                                blurRadius = 10
                            }
                        }
                    @unknown default:
                        break
                    }
                }
                .onAppear {
                    let updatedScreenSize = ScreenSize(geometry: geometry)
                    screnSize = updatedScreenSize
                }
                .blur(radius: blurRadius)
                .preferredColorScheme(theme.appearance.colorScheme)
                .premiumStatus(isPremium)
                .theme(ThemeSettings())
                .screenSize(screnSize)
            #if os(iOS)
                .accentColor(theme.accentColor)
            #endif
        }
    }
}

public extension View {
    func systemServices() -> some View {
        modifier(SystemServicesModifier())
    }
}
