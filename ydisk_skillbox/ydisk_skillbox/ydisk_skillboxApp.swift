//
//  ydisk_skillboxApp.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 17.02.2025.
//

import SwiftUI

@main
struct ydisk_skillboxApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var launchScreenState = LaunchScreenStateManager()
    @StateObject private var appState = AppState()
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("isAuthed") private var isAuthed: Bool = false
    
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                
                if isAuthed {
                   
                    TabBarView()
                    
                }else{
                    
                    LaunchScreenView()
                        .environmentObject(appState)
                        .id(appState.isRestarted)
                    
                    if isFirstLaunch {
                        OnboardingView(isFirstLaunch: $isFirstLaunch)
                    }
                    
                }
                
//                test()
                
//                ContentView()
                
//                if launchScreenState.state != .finished {
//                LaunchScreenView()
//                    .environmentObject(appState)
//                    .id(appState.isRestarted)
//                }
            }
            .onAppear{
                NetworkMonitor.shared.startMonitoring()
            }
            .environmentObject(launchScreenState)
            .sheet(isPresented:  $isFirstLaunch, content: {
                OnboardingView(isFirstLaunch: $isFirstLaunch)
            })
        }
    }
}


class AppState: ObservableObject {
    @Published var isRestarted: Bool = false
}
