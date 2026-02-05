//
//  ContentView.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 17.02.2025.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager
    
    var body: some View {
        ZStack{
            Color.yellow.ignoresSafeArea(.all)
            VStack {
                Image(systemName: "applescript")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accentColor)
                    .frame(width: 150, height: 150)
                Text("Hello, Apple Script!").font(.largeTitle)
            }
            .padding()
            .task {
//                try? await getDataFromApi()
                try? await Task.sleep(for: Duration.seconds(0.7))
                self.launchScreenState.dismiss()
            }
        }
    }
    
    fileprivate func getDataFromApi() async throws {
        let googleURL = URL(string: "https://www.google.com")!
        let (_,response) = try await URLSession.shared.data(from: googleURL)
//        print(response as? HTTPURLResponse)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LaunchScreenStateManager())
    }
}
