//
//  OnboardingPageView.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 19.02.2025.
//
import SwiftUI

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
//    let showDoneButton: Bool
//    var nextAction: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .frame(width: 149, height: 147)
                .foregroundColor(.mint)
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
//                .foregroundColor(.gray)
//            if showDoneButton {
//                Button("Lets get started") {
//                    nextAction()
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.top)
//            } else {
//                Button("Next") {
//                    nextAction()
//                }
//                .buttonStyle(.bordered)
//                .padding()
//            }
        }
        .padding()
    }
}
