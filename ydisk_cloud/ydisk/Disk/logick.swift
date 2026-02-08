//
//  logick.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 04.03.2025.
//

import Foundation
import Alamofire
import SwiftUI

// Вынесем donationsIncomeData наружу, чтобы обновлять ее напрямую
class YandexDiskService: ObservableObject{
    private let url = "https://cloud-api.yandex.net/v1/disk"
    private let headers: HTTPHeaders = [
        "Authorization": DataManager.shared.getToken()
    ]
    
    func fetchData(completion: @escaping ([IncomeData]) -> Void) {
        AF.request(url, headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any] {
                        let newData = self.handleDynamicData(json)
                        print("Запрос успешен, получены данные: \(newData)")
                        completion(newData)
                    } else {
                        print("Ошибка: Неверный формат данных")
                        completion([])
                    }
                case .failure(let error):
                    print("Ошибка при запросе: \(error)")
                    completion([])
                }
            }
    }
    
    private func handleDynamicData(_ data: [String: Any]) -> [IncomeData] {
        var newData: [IncomeData] = []
        
        if let totalSpace = data["total_space"] as? Int {
//            newData.append(IncomeData(amount: Double(totalSpace), category: "Общее пространство", forceColor: .uIgray))
            total = formatBytes(totalSpace)
        }
        if let usedSpace = data["used_space"] as? Int {
            newData.append(IncomeData(amount: Double(usedSpace), category: "Использованное пространство", forceColor: .uIblue))
        }
        if let photounlimSize = data["photounlim_size"] as? Int {
            newData.append(IncomeData(amount: Double(photounlimSize), category: "Размер фотоальбома", forceColor: .yellow))
        }
        if let trashSize = data["trash_size"] as? Int {
            newData.append(IncomeData(amount: Double(trashSize), category: "Размер корзины", forceColor: .red))
        }
        
        return newData
    }
}

var total: String = ""

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



struct IncomeData: Identifiable, Equatable{
    var amount: Double
    var category: String
    var forceColor: Color? = nil
    var id = UUID()
    
    static func ==(lhs: IncomeData, rhs: IncomeData) -> Bool {
        return lhs.category == rhs.category && lhs.amount == rhs.amount
    }
}
