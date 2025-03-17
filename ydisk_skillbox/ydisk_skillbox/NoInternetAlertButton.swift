//
//  NoInternetAlertButton.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 13.03.2025.
//

import SwiftUI
import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    var status = false
    
    @Published var isConnected: Bool = false
    private var previousStatus: NWPath.Status = .requiresConnection
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.handlePathUpdate(path)
            }
        }
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        status = true
        print("Начало мониторинга интернета")
    }
    
    func stopMonitoring() {
        monitor.cancel()
        status = false
        print("Мониторинг интернета остановлен")
    }
    
    private func handlePathUpdate(_ path: NWPath) {
        let newStatus = path.status
        if newStatus != previousStatus {
            isConnected = newStatus == .satisfied
            previousStatus = newStatus
            
            print("Состояние интернета обновлено: \(isConnected ? "Есть соединение" : "Соединение отсутствует")")
        }
    }
}


struct NoInternetToolbarModifier: ViewModifier {
    @Binding var opacity: Double // Binding для управления прозрачностью
    @ObservedObject var networkMonitor = NetworkMonitor.shared
    @State private var showAlert: Bool = false
    
    init(opacity: Binding<Double>? = nil) {
        _opacity = opacity ?? .constant(1.0) // Значение по умолчанию — 1.0
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAlert = true
                    } label: {
                        Image(systemName: networkMonitor.isConnected ? "wifi" : "wifi.slash")
                    }
                    .opacity(opacity)
                    .disabled(opacity == 0)
                    .foregroundStyle(networkMonitor.isConnected ? .green : .red)
                    .animation(.easeInOut(duration: 0.5), value: opacity)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(networkMonitor.isConnected ? "Интернет подключен" : "Отсутствует интернет подключение"),
                    message: Text(networkMonitor.isConnected ? "Интернет подключен, можете продолжить работу." : "Пожалуйста, проверьте ваше соединение с интернетом."),
                    dismissButton: .default(Text("Ок"))
                )
            }
            .onAppear {
                if !networkMonitor.status {
                    networkMonitor.startMonitoring()
                }
            }
    }
}





#Preview{
    NavigationView{
        Image(systemName: "wifi.router.fill")
            .scaleEffect(5)
            .foregroundStyle(.blue)
            .modifier(NoInternetToolbarModifier())
    }
}





