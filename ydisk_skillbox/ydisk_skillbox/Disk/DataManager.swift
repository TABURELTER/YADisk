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
import SQLite3

class DataManager {
    static let shared = DataManager()
    private let baseURL = "https://cloud-api.yandex.net/v1/disk/resources"
    private let cacheFileName = "DiskResponseCache.json"
    
    

    
    // MARK: - Rename file
    func rename(item: cell, newName: String, completion: @escaping (Bool) -> Void) {
//        print(item.name)
//        print(formatePath(item.path.replacingOccurrences(of: item.name, with: newName)))
        let url = "\(baseURL)/move?from=\(formatePath(item.path))&path=\(formatePath(item.path.replacingOccurrences(of: item.name, with: newName)))"
        
        // Проверяем наличие интернета
        guard NetworkReachabilityManager()?.isReachable == true else {
            print("Нет подключения к интернету, загружаем из кэша")
            return
        }
        
        // Выполняем запрос через Alamofire
        AF.request(url,method: .post ,headers: HTTPHeaders(getHeaders())).validate().responseDecodable(of: DiskResponse.self) { response in
            switch response.response?.statusCode {
            case 201,202:
                completion(true)
                
            default:
                print("Ошибка \(response.response?.statusCode ?? 0) при запросе: \(response.error ?? .sessionDeinitialized)")
                print("rename error response: \(String(describing: response.debugDescription))")
                completion(false)
            }
        }
    }


    
    
    // MARK: - Fetch Custom Cells

    func getCustomCells(path: String = "/", offset: Int = 0, lastUpdatedSort: Bool = false, completion: @escaping ([CustomCell]) -> Void) {
        let url: String = lastUpdatedSort
            ? "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded"
            : "\(baseURL)?path=\(formatePath(path))&offset=\(offset)"
        

        print("\n--- Вызов функции getCustomCells ---")
        print("Параметры: path=\(path), offset=\(offset), lastUpdatedSort=\(lastUpdatedSort)")
        print("URL запроса: \(url)")

        // Проверяем наличие интернета
        guard NetworkReachabilityManager()?.isReachable == true else {
            print("[LOG] Нет подключения к интернету. Попытка загрузить из кэша...")
            if let cachedData = CacheManager.shared.loadFromCache(url: url) {
                print("[LOG] Данные найдены в кэше для URL: \(url)")
                if lastUpdatedSort {
                    if let response = try? JSONDecoder().decode(LastUploadedResponse.self, from: Data(cachedData.utf8)) {
                        print("[LOG] Успешно декодированы данные из кэша для lastUpdatedSort.")
                        completion(parseResponseLast(response).map { CustomCell(item: $0) })
                        return
                    } else {
                        print("[ERROR] Ошибка декодирования данных из кэша для lastUpdatedSort.")
                    }
                } else {
                    if let response = try? JSONDecoder().decode(DiskResponse.self, from: Data(cachedData.utf8)) {
                        print("[LOG] Успешно декодированы данные из кэша для обычного запроса.")
                        completion(parseResponse(response).map { CustomCell(item: $0) })
                        return
                    } else {
                        print("[ERROR] Ошибка декодирования данных из кэша для обычного запроса.")
                    }
                }
            } else {
                print("[LOG] Кэш для URL: \(url) отсутствует.")
            }
            completion([])
            return
        }

        print("[LOG] Интернет соединение доступно. Выполняем запрос...")

        // Выполняем запрос через Alamofire
        if lastUpdatedSort {
            AF.request(url, headers: HTTPHeaders(getHeaders())).validate().responseDecodable(of: LastUploadedResponse.self) { response in
                print("[LOG] Получен ответ для lastUpdatedSort. Статус: \(response.response?.statusCode ?? -1)")
                switch response.result {
                case .success(let data):
                    print("[LOG] Успешно получены данные от сервера для lastUpdatedSort.")
                    let parsedResponse = self.parseResponseLast(data)

                    if let jsonData = try? JSONEncoder().encode(data) {
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            do {
                                try CacheManager.shared.saveToCache(url: url, responseData: jsonString)
                                print("[LOG] Данные успешно сохранены в кэш для URL: \(url)")
                            } catch {
                                print("[ERROR] Ошибка сохранения данных в кэш: \(error.localizedDescription)")
                            }
                        } else {
                            print("[ERROR] Ошибка при конвертации данных в строку JSON.")
                        }
                    } else {
                        print("[ERROR] Ошибка при сериализации JSON.")
                    }
                    completion(parsedResponse.map { CustomCell(item: $0) })

                case .failure(let error):
                    print("[ERROR] Ошибка при запросе: \(error.localizedDescription)")

                    if response.response?.statusCode == 404 {
                        print("[LOG] Сервер вернул 404. Возвращаем пустой результат.")
                        completion([])
                        return
                    }

                    if let cachedData = CacheManager.shared.loadFromCache(url: url) {
                        print("[LOG] Используем данные из кэша из-за ошибки запроса.")
                        if let response = try? JSONDecoder().decode(LastUploadedResponse.self, from: Data(cachedData.utf8)) {
                            completion(self.parseResponseLast(response).map { CustomCell(item: $0) })
                        } else {
                            print("[ERROR] Ошибка декодирования данных из кэша для lastUpdatedSort.")
                            completion([])
                        }
                    } else {
                        print("[LOG] Кэш отсутствует, возвращаем пустой результат.")
                        completion([])
                    }
                }
            }
        } else {
            AF.request(url, headers: HTTPHeaders(getHeaders())).validate().responseDecodable(of: DiskResponse.self) { response in
                print("[LOG] Получен ответ для обычного запроса. Статус: \(response.response?.statusCode ?? -1)")
                switch response.result {
                case .success(let data):
                    print("[LOG] Успешно получены данные от сервера для обычного запроса.")
                    let parsedResponse = self.parseResponse(data)

                    if let jsonData = try? JSONEncoder().encode(data) {
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            do {
                                try CacheManager.shared.saveToCache(url: url, responseData: jsonString)
                                print("[LOG] Данные успешно сохранены в кэш для URL: \(url)")
                            } catch {
                                print("[ERROR] Ошибка сохранения данных в кэш: \(error.localizedDescription)")
                            }
                        } else {
                            print("[ERROR] Ошибка при конвертации данных в строку JSON.")
                        }
                    } else {
                        print("[ERROR] Ошибка при сериализации JSON.")
                    }
                    completion(parsedResponse.map { CustomCell(item: $0) })

                case .failure(let error):
                    print("[ERROR] Ошибка при запросе: \(error.localizedDescription)")

                    if response.response?.statusCode == 404 {
                        print("[LOG] Сервер вернул 404. Возвращаем пустой результат.")
                        completion([])
                        return
                    }

                    if let cachedData = CacheManager.shared.loadFromCache(url: url) {
                        print("[LOG] Используем данные из кэша из-за ошибки запроса.")
                        if let response = try? JSONDecoder().decode(DiskResponse.self, from: Data(cachedData.utf8)) {
                            completion(self.parseResponse(response).map { CustomCell(item: $0) })
                        } else {
                            print("[ERROR] Ошибка декодирования данных из кэша для обычного запроса.")
                            completion([])
                        }
                    } else {
                        print("[LOG] Кэш отсутствует, возвращаем пустой результат.")
                        completion([])
                    }
                }
            }
        }
    }
    

    
    // MARK: - publish and get URL
    func getPublishCell(path: String, completion: @escaping (String) -> Void) {
        let publishURL = "\(baseURL)/publish?path=\(formatePath(path))"
        print("Запрос на публикацию: \(baseURL)/publish?path=\(path)")
        
        struct PublishResponse: Codable {
            let href: String
        }
        
        // Запрос на публикацию
        AF.request(publishURL, method: .put, headers: HTTPHeaders(getHeaders()))
            .validate()
            .responseDecodable(of: PublishResponse.self) { [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                case .success:
                    print("Результат 1 запроса - \(response.response?.statusCode ?? 0)")
                    self.fetchPublicURL(path: path, offset: 0, completion: completion)
                    
                case .failure(let error):
                    print("\nОшибка при запросе на публикацию: \(error.localizedDescription)")
                    completion("Ошибка: \(String(describing: response.response?.statusCode))")
                }
            }
    }

    // MARK: - Fetch Public URL with Pagination
    func fetchPublicURL(path: String, offset: Int, completion: @escaping (String) -> Void) {
        let publicURL = "\(baseURL)/public?fields=items.public_url%2Citems.name&offset=\(offset)"
        print("Запрос на получение публичного URL offset: \(offset)")
        
        AF.request(publicURL, method: .get, headers: HTTPHeaders(getHeaders()))
            .validate()
            .responseDecodable(of: DiskPublic.self) { response in
                switch response.result {
                case .success(let diskResponse):
                    if let item = diskResponse.items.first(where: { path.contains($0.name) }) {
                        completion(item.publicURL)
                    } else if diskResponse.items.count == 20 {
                        // Если элемент не найден и список полный, продолжаем с увеличенным offset
                        self.fetchPublicURL(path: path, offset: offset + 20, completion: completion)
                    } else {
                        // Если элемент не найден и список неполный, завершаем с сообщением
                        completion("Элемент не найден")
                    }
                    
                case .failure(let error):
                    print("\nОшибка при запросе публичного URL: \(error.localizedDescription)")
                    completion("Ошибка: \(error.localizedDescription)")
                }
            }
    }
    
    func GetPublicCells(path: String, offset: Int, completion: @escaping (DiskPublic) -> Void) {
        let publicURL = "\(baseURL)/public?offset=\(offset)"
        print("Запрос на получение публичного URL offset: \(offset)")
        
        AF.request(publicURL, method: .get, headers: HTTPHeaders(getHeaders()))
            .validate()
            .responseDecodable(of: DiskPublic.self) { response in
                switch response.result {
                case .success(let diskResponse):
                    completion(diskResponse)
                    
                case .failure(let error):
                    print("\nОшибка при запросе публичного URL: \(error.localizedDescription)")
//                    completion("Ошибка: \(error.localizedDescription)")
                }
            }
    }
    
    // MARK: - Delete item
    func DELETE(cell: cell, completion: @escaping (Bool) -> Void) {
        let url = "\(baseURL)?path=\(cell.path)&md5=\(cell.MD5 ?? "")"
        print("Request URL: \(url)")
        
        AF.request(url, method: .delete, headers: HTTPHeaders(getHeaders())).response { response in
            print(response.response?.statusCode ?? 400)
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
    
    // MARK: - formate path
    func formatePath(_ path: String) -> String {
        
        var allowedCharacterSet = CharacterSet.alphanumerics
        allowedCharacterSet.insert(charactersIn: "-._~") // безопасные символы для URL

        return path.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
    }

    
    // MARK: - Token and Headers
    func getToken() -> String {
        @AppStorage("token") var token: String = ""
        return token
    }
    
    func deleteToken() {
        UserDefaults.standard.removeObject(forKey: "token")
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
                file: item.file,
                MD5: item.md5
            )
        }
    }
    
    private func parseResponseLast(_ response: LastUploadedResponse) -> [cell] {
        print("[LOG] Обнаружено \(response.items.count) элементов в ответе.")

        return response.items.compactMap { item in
            guard let name = item.name,
                  let path = item.path,
                  let created = item.created,
                  let dateCreated = ISO8601DateFormatter().date(from: created) else {
                print("[WARNING] Пропущен элемент из-за отсутствия обязательных данных: \(item)")
                return nil
            }

            return cell(
                isFolder: item.type == "dir",
                name: name,
                path: path,
                dateCreate: dateCreated,
                size: item.size != nil ? ByteCountFormatter.string(fromByteCount: Int64(item.size!), countStyle: .file) : "",
                sizes: item.sizes?.map { Size(url: $0.url ?? "", name: $0.name ?? "") },
                file: item.file,
                MD5: item.md5
            )
        }
    }



    // MARK: - Cache Management
    private func cacheFileURL(for path: String) throws -> URL {
        guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw URLError(.fileDoesNotExist)
        }
        // Используем path для создания уникального имени файла
        let fileName = "DiskResponseCache_\(formatePath(path)).json"
        return directory.appendingPathComponent(fileName)
    }

}


