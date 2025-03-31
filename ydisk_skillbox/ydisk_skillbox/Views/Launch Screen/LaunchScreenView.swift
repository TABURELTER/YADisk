//
//  LaunchScreenView.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 17.02.2025.
//

import SwiftUI

struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager // Mark 1
    @EnvironmentObject var appState: AppState
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var firstAnimation = false  // Mark 2
    @State var secondAnimation = false // Mark 2
    @State var startFadeoutAnimation = false // Mark 2
    
    @State private var showAuthView: Bool = false
    
//    @StateObject private var viewModel = YandexLoginViewModel()
    
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    @AppStorage("token") private var token: String = ""
    
    var body: some View {
        ZStack {
            backgroundColor  // Mark 3
            VStack{
                logo.padding(.top,50)
                nameLogo
                Spacer()
            }
           
            VStack{
                Spacer()
                
                YandexIDButton(action: {
                    YandexLoginViewModel.shared.startAuthorization(strategy: .default)
                })
                .disabled(YandexLoginViewModel.shared.isLoading)
                .disabled(!token.isEmpty)
//                .contextMenu{
//                    Menu{
//                        Button {
//                            YandexLoginViewModel.shared.logout()
//                        } label: {
//                            Label("Logout", systemImage: "iphone.and.arrow.right.outward")
//                        }
//                    } label: {
//                        Label("Debug Menu", systemImage: "desktopcomputer.trianglebadge.exclamationmark")
//                    }
//                }
                .padding()
                .frame(width: 350)
                
            }

        }
        .onReceive(animationTimer) { timerValue in
            updateAnimation()  // Mark 5
        }
        .opacity(startFadeoutAnimation ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: startFadeoutAnimation)
        .onAppear {
//            print(viewModel.token)
            if !YandexLoginViewModel.shared.checkSavedToken(){
                YandexLoginViewModel.shared.setupSDK()
            }
                
            }
            .onDisappear {
                YandexLoginViewModel.shared.cleanupSDK()
            }
    }
    
    
    
    @ViewBuilder
    var logo: some View {  // Mark 3
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(width: 115, height: 115)
            .rotationEffect(firstAnimation ? Angle(degrees: 900) : Angle(degrees: 1800)) // Mark 4
            .scaleEffect(secondAnimation ? 0 : 1) // Mark 4
//            .offset(y: secondAnimation ? 400 : 0) // Mark 4
    }
    
    @ViewBuilder
    private var nameLogo: some View {
        Image("Name")
           .resizable()
           .scaledToFit()
           .frame(width: 200, height: 50)
           .colorMultiply(colorScheme == .dark ? .white : .black) // Инверсия цвета
    }
    
    @ViewBuilder
    private var backgroundColor: some View {  // Mark 3
        Color(colorScheme == .light ? .white : .black).ignoresSafeArea()
    }
    
    private let animationTimer = Timer // Mark 5
        .publish(every: 0.5, on: .current, in: .common)
        .autoconnect()
    

    
    private func updateAnimation() { // Mark 5
        switch launchScreenState.state {
        case .firstStep:
            withAnimation(.easeInOut(duration: 1.25)) {
                firstAnimation.toggle()
            }
        case .secondStep:
            if secondAnimation == false {
                
            }
        case .finished:
            // use this case to finish any work needed
            break
        }
    }
}





#Preview("Second Animation") {
    var launchScreenState = LaunchScreenStateManager()
    LaunchScreenView()
        .environmentObject(launchScreenState)
        .task {
            try? await Task.sleep(for: Duration.seconds(1))
            launchScreenState.dismiss()
            
        }
    
}


#Preview("Default") {
   LaunchScreenView()
        .environmentObject(LaunchScreenStateManager())
}
