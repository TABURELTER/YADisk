//
//  YandexIDButton.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 01.03.2025.
//

import SwiftUI
import YandexLoginSDK
import Combine

struct YandexIDButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image("YandexID")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52,height: 25)
                    .offset(y:1)


                Text("Войти через Яндекс ID")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.93, green: 0.11, blue: 0.14)) // Яндекс-красный цвет
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

//static var shared: YandexLoginSDK { get }


class YandexLoginViewModel: NSObject, ObservableObject, YandexLoginSDKObserver {
    
    // Статическая переменная для хранения единственного экземпляра
    static var shared: YandexLoginViewModel = {
        let instance = YandexLoginViewModel()
        instance.setupSDK()  // Инициализация SDK
        return instance
    }()

    @AppStorage("token") private var apptoken: String = ""
    @AppStorage("jwt") private var appjwt: String = ""
    @AppStorage("isAuthed") private var isAuthed: Bool = false
    @Published var token: String? = nil
    @Published var jwt: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    // Закрытый инициализатор для предотвращения создания других экземпляров
    private override init() {
        super.init()
        YandexLoginSDK.shared.add(observer: self)
    }

    func checkSavedToken() -> Bool {
        if !apptoken.isEmpty {
            self.token = apptoken
            self.isAuthed = true
            print("Найден сохранённый токен: \(apptoken)")
            return true
        } else {
            print("Токен не найден")
            return false
        }
    }

    func setupSDK() {
        do {
            try YandexLoginSDK.shared.activate(
                with: "867bd70c6e0b4d87b677da7e7d7ac01a",
                authorizationStrategy: .default
            )
        } catch {
            errorMessage = "setupSDK Ошибка активации SDK: \(error)"
            print("setupSDK Ошибка активации SDK: \(error)")
        }
    }

    func logout(){
        do{
            try YandexLoginSDK.shared.logout()
            apptoken = ""
            token = ""
            appjwt = ""
            jwt = ""
            isAuthed = false
            print("Выход выполнен")
        }
        catch {
            print("Выход не удался")
        }
    }

    func startAuthorization(strategy: YandexLoginSDK.AuthorizationStrategy) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            errorMessage = "Не удалось получить rootViewController"
            print("Не удалось получить rootViewController")
            return
        }

        do {
            isLoading = true
            try YandexLoginSDK.shared.authorize(
                with: rootViewController,
                customValues: nil,
                authorizationStrategy: strategy
            )
        } catch {
            isLoading = false
            errorMessage = "startAuthorization Ошибка запуска авторизации: \(error)"
            print("startAuthorization Ошибка запуска авторизации: \(error)")
        }
    }

    func cleanupSDK() {
        YandexLoginSDK.shared.remove(observer:self)
    }

    // MARK: - LoginSDKObserver Methods
    func didFinishLogin(with result: Result<LoginResult, Error>) {
        DispatchQueue.main.async {
            self.isLoading = false
            switch result {
            case .success(let loginResult):
                self.token = loginResult.token
                self.apptoken = loginResult.token
                self.jwt = loginResult.jwt
                self.appjwt = loginResult.jwt
                self.errorMessage = nil
                print("token \(String(describing: self.token))")
                print("jwt \(String(describing: self.jwt))")
                self.isAuthed = true
            case .failure(let error):
                self.token = nil
                self.jwt = nil
                self.errorMessage = error.localizedDescription
                print(error.localizedDescription)
            }
        }
    }
}
