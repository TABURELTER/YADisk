//
//  YandexLoginView.swift
//  idk yadisk
//
//  Created by Дмитрий Богданов on 28.02.2025.
//

import SwiftUI
import YandexLoginSDK

struct YandexLoginView: View {
//    @StateObject private var viewModel = YandexLoginViewModel()

    var body: some View {
        VStack(spacing: 20) {
            if let token = YandexLoginViewModel.shared.token {
                Text("Успешно авторизован!")
                    .font(.headline)
                Text("OAuth-токен: \(token)")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding()
                
                if let jwt = YandexLoginViewModel.shared.jwt {
                    Text("JWT: \(jwt)")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if let errorMessage = YandexLoginViewModel.shared.errorMessage {
                Text("Ошибка авторизации:")
                    .font(.headline)
                    .foregroundColor(.red)
                Text(errorMessage)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Авторизуйтесь через Яндекс")
                    .font(.headline)
            }

            Button(action: {
               YandexLoginViewModel.shared.startAuthorization(strategy: .default)
            }) {
                HStack {
                    Image(systemName: "person.fill")
                    Text("Войти с Яндекс (Default)")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(YandexLoginViewModel.shared.isLoading)

            Button(action: {
               YandexLoginViewModel.shared.startAuthorization(strategy: .webOnly)
            }) {
                HStack {
                    Image(systemName: "person.fill")
                    Text("Войти с Яндекс (WebOnly)")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(YandexLoginViewModel.shared.isLoading)
            
            Button(action: {
                do {
                    try YandexLoginSDK.shared.logout() // Выполняем выход
                    print("Logout successful")
                    // Дополнительные действия после выхода, например, навигация
                } catch {
                    print("Logout failed: \(error.localizedDescription)") // Обработка ошибок
                }
            }) {
                HStack {
                    Image(systemName: "person.fill")
                    Text("Logout")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

        }
        .padding()
        .onAppear {
           YandexLoginViewModel.shared.setupSDK()
        }
        .onDisappear {
           YandexLoginViewModel.shared.cleanupSDK()
        }
    }
}



#Preview {
    YandexLoginView()
}
