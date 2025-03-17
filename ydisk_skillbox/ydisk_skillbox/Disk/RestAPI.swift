//
//  RestAPI.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 10.03.2025.
//

import Foundation
import SwiftUI
import Alamofire
import SwiftData

class DataManager {
    static let shared = DataManager()
    private let baseURL = "https://cloud-api.yandex.net/v1/disk/resources"
    private let cacheFileName = "DiskResponseCache.json"
    
    // MARK: - Fetch Custom Cells
    func getCustomCells(path: String = "/", offset: Int = 0, completion: @escaping ([CustomCell]) -> Void) {
        var result: [CustomCell] = []
        let url = "\(baseURL)?path=\(path.replacingOccurrences(of: "+", with: "%20").replacingOccurrences(of: "#", with: "%23").replacingOccurrences(of: "?", with: "%3F").replacingOccurrences(of: "&", with: "%26").replacingOccurrences(of: "=", with: "%3D").replacingOccurrences(of: " ", with: "%20"))&offset=\(offset)"
        print(url)
        
        // Проверяем наличие интернета
        guard NetworkReachabilityManager()?.isReachable == true else {
            print("Нет подключения к интернету, загружаем из кэша")
            loadCachedData { cachedCells in
                for item in cachedCells {
                    result.append(CustomCell(item: item))
                }
                completion(result)
            }
            return
        }
        
        // Выполняем запрос через Alamofire
        AF.request(url, headers: HTTPHeaders(getHeaders())).validate().responseDecodable(of: DiskResponse.self) { response in
            
            switch response.result {
            case .success(let diskResponse):
                // Обработка успешного ответа
                let customCells = self.parseResponse(diskResponse)
                self.saveToCache(diskResponse)
             
                for item in customCells {
                    result.append(CustomCell(item: item))
                }
                
                // Сохраняем данные в кэш
            
                completion(result)
                
            case .failure(let error):
                print("Ошибка при запросе: \(error.localizedDescription)")
                print(url)
                
                if response.response?.statusCode == 404{
                    print("404 -> вернули []")
                    completion([])
                }
                
                // В случае ошибки загружаем из кэша
                self.loadCachedData { cachedCells in
                    
                    for item in cachedCells {
                        result.append(CustomCell(item: item))
                    }
                    
                    completion(result)
                }
            }
        }
    }

    
    func DELETE(cell: cell, completion: @escaping (Bool) -> Void) {
        let url = "\(baseURL)?path=\(cell.path)&md5=\(cell.MD5 ?? "")"
        print("Request URL: \(url)")
        
        AF.request(url, method: .delete, headers: HTTPHeaders(getHeaders())).response { response in
            print(response.response?.statusCode)
            switch response.result {
            case .success:
                print("Request succeeded: \(response)")
                completion(true)
            case .failure(let error):
                print("Request failed: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    
    // MARK: - Token and Headers
    private func getToken() -> String {
        @AppStorage("token") var token: String = ""
        #if DEBUG
//        token = ""
        #endif
        if token.isEmpty {
            print("ТОКЕН ПУСТОЙ")
            return ""
        }
        return token
    }

    private func getHeaders() -> [String: String] {
        [
            "Authorization": "OAuth \(getToken())"
        ]
    }

    // MARK: - Parse Response
    private func parseResponse(_ response: DiskResponse) -> [cell] {
        guard let items = response.embedded?.items else { return [] }
        return items.map { item in
            cell(
                isFolder: item.type == "dir",
                name: item.name,
                path: item.path,
                dateCreate: ISO8601DateFormatter().date(from: item.created) ?? Date(),
                size: item.size != nil ? ByteCountFormatter.string(fromByteCount: Int64(item.size!), countStyle: .file) : "",
                sizes: item.sizes,
                MD5: item.md5
            )
        }
    }

    // MARK: - Cache Management
    private func saveToCache(_ response: DiskResponse) {
        do {
            let data = try JSONEncoder().encode(response)
            let url = try cacheFileURL()
            try data.write(to: url)
        } catch {
            print("Ошибка сохранения данных в кэш: \(error.localizedDescription)")
        }
    }

    private func loadCachedData(completion: @escaping ([cell]) -> Void) {
        do {
            let url = try cacheFileURL()
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(DiskResponse.self, from: data)
            completion(parseResponse(response))
        } catch {
            print("Ошибка загрузки данных из кэша: \(error.localizedDescription)")
            completion([])
        }
    }

    private func cacheFileURL() throws -> URL {
        guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw URLError(.fileDoesNotExist)
        }
        return directory.appendingPathComponent(cacheFileName)
    }
}


//
//
//let url = URL(string: "https://cloud-api.yandex.net/v1/disk/resources")!
//
//private func getToken() -> String {
//    @AppStorage("token") var token: String = ""
//    #if DEBUG
//    token = "y0__xCHp4HcARiBsjUg3_WXtBIdcAJl-Q-Kq15AFkuCOvZV4pQJdg"
//    #endif
//    if token.isEmpty {
//        print("ТОКЕН ПУСТОЙ")
//        return ""
//    }
//    return token
//}
//
//private func getHeaders() -> [String: String] {
//    let headers = [
//        "Authorization": "OAuth \(getToken())"
//    ]
//    
//    return headers
//}
//
//func get_CustomCells(path: String = "/", offset: Int = 0, completion: @escaping ([CustomCell]) -> Void) {
//    @AppStorage("token") var token: String = ""
//    var cells: [CustomCell] = []
//    var urlRequest = URLRequest(url: url)
//    urlRequest.httpMethod = "GET"
//    urlRequest.allHTTPHeaderFields = getHeaders()
//    let params = [
//        "path": path,
//        "offset": offset
//    ] as [String : Any]
//
//    // Преобразуем параметры в query
//    var queryItems = [URLQueryItem]()
//    for (key, value) in params {
//        queryItems.append(URLQueryItem(name: key, value: "\(value)"))
//    }
//    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
//    components.queryItems = queryItems
//    urlRequest.url = components.url
//
//    // Настройка сессии с использованием кэша
//    let sessionConfig = URLSessionConfiguration.default
//    sessionConfig.requestCachePolicy = .returnCacheDataElseLoad
//    sessionConfig.urlCache = .myCache
//
//    let session = URLSession(configuration: sessionConfig)
//
//    // Проверка наличия данных в кэше
//    if let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest) {
//        let cachedData = cachedResponse.data
//        
//        // Декодируем кэшированные данные
//        do {
//            do {
//                let decoder = JSONDecoder()
//                let cachedDataResponse = try decoder.decode(DiskResponse.self, from: cachedData)
//                
//                print("Данные из кэша")
////                print(cachedDataResponse.embedded?.items.count)
//                
//                // Обновляем массив cells
//                let dateFormatter = ISO8601DateFormatter()
//                cells = cachedDataResponse.embedded?.items.map {
//                    let date = dateFormatter.date(from: $0.created)!
//                    let q = cell(
//                        isFolder: $0.type == "dir",
//                        name: $0.name,
//                        path: $0.path,
//                        dateCreate: date,
//                        size: formatBytes($0.size ?? 0),
//                        sizes: $0.sizes
//                    )
//                    return CustomCell(item: q)
//                } ?? []
//
//                completion(cells)  // Возвращаем данные из кэша
//            } catch {
//                print("Ошибка декодирования кэшированных данных: \(error)")
//                completion([])  // Возвращаем данные из кэша
//            }
//
//
//            // Параллельный запрос на сервер
//            let task = session.dataTask(with: urlRequest) { data, response, error in
//                if let error = error {
//                    print("Ошибка запроса: \(error)")
//                    return
//                }
//                
//                guard let data = data else {
//                    print("Нет данных")
//                    return
//                }
//                
//                // Обработка ответа
//                do {
//                    let decoder = JSONDecoder()
//                    let dataResponse = try decoder.decode(DiskResponse.self, from: data)
//
//                    // Обновляем массив cells
//                    let dateFormatter = ISO8601DateFormatter()
//                    cells = dataResponse.embedded?.items.map {
//                        let date = dateFormatter.date(from: $0.created)!
//                        let q = cell(
//                            isFolder: $0.type == "dir",
//                            name: $0.name,
//                            path: $0.path,
//                            dateCreate: date,
//                            size: formatBytes($0.size ?? 0),
//                            sizes: $0.sizes
//                        )
//                        return CustomCell(item: q)
//                    } ?? []
//
//                    completion(cells)  // Возвращаем новые данные
//
//                    // Сохраняем в кэш
//                    let cachedResponse = CachedURLResponse(response: response!, data: data)
//                    URLCache.shared.storeCachedResponse(cachedResponse, for: urlRequest)
//                } catch {
//                    print("Ошибка декодирования новых данных: \(error)")
//                    completion([])  // Возвращаем пустой массив в случае ошибки
//                }
//
//            }
//            task.resume()
//
//        } catch {
//            print("Ошибка декодирования кэшированных данных: \(error)")
//        }
//    } else {
//        print("Нет данных в кэше")
////        print(URLCache.shared.cachedResponse(for: urlRequest))
//        // Если данных в кэше нет, выполняем запрос
//        let task = session.dataTask(with: urlRequest) { data, response, error in
//            if let error = error {
//                print("Ошибка запроса: \(error)")
//                completion([])  // Возвращаем пустой массив при ошибке
//                return
//            }
//
//            guard let data = data else {
//                print("Нет данных")
//                completion([])  // Возвращаем пустой массив
//                return
//            }
//
//            // Обработка ответа
//            do {
//                let decoder = JSONDecoder()
//                let dataResponse = try decoder.decode(DiskResponse.self, from: data)
//
//                var newCells: [CustomCell] = []
//                let dateFormatter = ISO8601DateFormatter()
//                for i in dataResponse.embedded?.items ?? [] {
//                    let date = dateFormatter.date(from: i.created)!
//                    let q = cell(isFolder: i.type == "dir", name: i.name, path: i.path, dateCreate: date, size: formatBytes(i.size ?? 0), sizes: i.sizes)
//                    newCells.append(CustomCell(item: q))
//                }
//                completion(newCells)  // Возвращаем новые данные
//
//                // Сохраняем в кэш
//                let cachedResponse = CachedURLResponse(response: response!, data: data)
//                URLCache.shared.storeCachedResponse(cachedResponse, for: urlRequest)
//
//            } catch {
//                print("Ошибка декодирования новых данных: \(error)")
//                completion([])  // Возвращаем пустой массив в случае ошибки
//            }
//        }
//        task.resume()
//    }
//}
//
//
