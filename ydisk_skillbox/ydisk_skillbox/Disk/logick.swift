//
//  logick.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 04.03.2025.
//

import Foundation
import Alamofire

// Вынесем donationsIncomeData наружу, чтобы обновлять ее напрямую
var donationsIncomeData: [IncomeData] = [
    .init(category: "16 гб - свободно ", amount: 16, forceColor: .uIgray),
    .init(category: "4 гб - занято", amount: 4, forceColor: .uIpinl)
]

class YandexDiskService {
    private let url = "https://cloud-api.yandex.net/v1/disk"
    private let headers: HTTPHeaders = [
        "Authorization": "OAuth y0__xCHp4HcARiBsjUg3_WXtBIdcAJl-Q-Kq15AFkuCOvZV4pQJdg"
    ]
    private var timer: Timer?

    func startFetchingData() {
        // Запускаем таймер, который будет вызывать запрос каждые 15 секунд
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
            self?.fetchData()
        }
    }

    func stopFetchingData() {
        // Останавливаем таймер
        timer?.invalidate()
        timer = nil
    }

    private func fetchData() {
        AF.request(url, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        self.handleDynamicData(json)
                    } else {
                        print("Ошибка: Неверный формат данных")
                    }
                case .failure(let error):
                    print("Ошибка при запросе: \(error)")
                }
            }
    }

    private func handleDynamicData(_ data: [String: Any]) {
        // Пример обработки данных
        var newData: [IncomeData] = []
        
        if let totalSpace = data["total_space"] as? Int {
            newData.append(IncomeData(category: "Общее пространство", amount: totalSpace, forceColor: .uIgray))
        }
        if let usedSpace = data["used_space"] as? Int {
            newData.append(IncomeData(category: "Использованное пространство", amount: usedSpace, forceColor: .uIblue))
        }
        if let photounlimSize = data["photounlim_size"] as? Int {
            newData.append(IncomeData(category: "Размер фотоальбома", amount: photounlimSize, forceColor: .yellow))
        }
        if let trashSize = data["trash_size"] as? Int {
            newData.append(IncomeData(category: "Размер корзины", amount: trashSize, forceColor: .red))
        }

        // Обновляем donationsIncomeData, если данные изменились
        if newData != donationsIncomeData {
            donationsIncomeData = newData
            print("Данные обновлены: \(donationsIncomeData)")
        }
    }
}

// Форматирование данных (если нужно)
func formatBytes(_ bytes: Int) -> String {
    let units = ["B", "KB", "MB", "GB", "TB"]
    var value = Double(bytes)
    var index = 0
    
    while value >= 1024 && index < units.count - 1 {
        value /= 1024
        index += 1
    }
    
    return String(format: "%.2f %@", value, units[index])
}

