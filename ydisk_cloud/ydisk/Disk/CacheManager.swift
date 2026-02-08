//
//  CacheManager.swift
//  idk yadisk
//
//  Created by Дмитрий Богданов on 20.03.2025.
//


import SQLite3
import Foundation


class CacheManager {
    private var db: OpaquePointer?
    private let dbName: String
    private let dbPath: String
    
    // Единственный экземпляр класса
    static let shared: CacheManager = {
        let instance = CacheManager(dbName: "database.sqlite")
        return instance
    }()
    
    // Приватный инициализатор
    private init(dbName: String) {
        self.dbName = dbName
        
        // Получаем путь к каталогу документов
        let fileManager = FileManager.default
        let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        // Генерируем путь к базе данных с названием dbName
        self.dbPath = documentsDirectory.appendingPathComponent(dbName).path
        
        print(dbPath)
        
      
    }
    
    // Открытие базы данных
    private func openDatabase() -> Bool {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Не удалось открыть базу данных по пути \(dbPath).")
            return false
        }
        return true
    }
    
    // Закрытие базы данных
    private func closeDatabase() {
        sqlite3_close(db)
        print("База данных закрыта.")
    }
    
    // Создание таблицы
    private func createTable(tableName:String) -> Bool{
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS \(tableName) (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT UNIQUE,
            responseData TEXT,
            timestamp DOUBLE
        );
        """
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &statement, nil) != SQLITE_OK {
            print("\n!!! Ошибка при подготовке запроса создания таблицы (\(tableName)): \(String(cString: sqlite3_errmsg(db))) !!!\n")
            return false
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Ошибка при создании таблицы (\(tableName)): \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        sqlite3_finalize(statement)
        print("Таблица \(tableName) успешно создана.")
        return true
    }
    
    
    func saveToCache(url: String, responseData: String, name: String = "CacheDB") -> Bool {
        // Формируем запрос с использованием интерполяции строк
        let insertQuery = "INSERT OR REPLACE INTO \(name) (url, responseData, timestamp) VALUES (?, ?, ?);"
        
        var statement: OpaquePointer?
        
        // Подготавливаем запрос
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка при подготовке запроса для сохранения данных в кэш (\(name)): \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        
        // Привязываем параметры к запросу
        // Преобразуем url и responseData в строки в формате UTF-8
        let utf8Url = url.cString(using: .utf8)
        let utf8ResponseData = responseData.cString(using: .utf8)
        
        if let utf8Url = utf8Url, let utf8ResponseData = utf8ResponseData {
            sqlite3_bind_text(statement, 1, utf8Url, -1, nil)
            sqlite3_bind_text(statement, 2, utf8ResponseData, -1, nil)
        } else {
            print("Ошибка при кодировании текста в UTF-8.")
            return false
        }
        
        // Привязываем timestamp
        sqlite3_bind_double(statement, 3, Date().timeIntervalSince1970)
        
        // Выполняем запрос
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Ошибка при сохранении данных в кэш (\(name)): \(String(cString: sqlite3_errmsg(db)))")
            return false
        } else {
            print("Данные для URL \(url) успешно сохранены в кэш (\(name)).")
        }
        
        // Освобождаем ресурсы
        sqlite3_finalize(statement)
        
        return true
    }


    
//    func saveToCache(url: String, responseData: String, name: String = "CacheDB") -> Bool {
//        // Формируем запрос с использованием интерполяции строк
//        let insertQuery = "INSERT OR REPLACE INTO \(name) (url, responseData, timestamp) VALUES (?, ?, ?);"
//        
//        var statement: OpaquePointer?
//        
//        // Подготавливаем запрос
//        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) != SQLITE_OK {
//            print("Ошибка при подготовке запроса для сохранения данных в кэш (\(name)): $String(cString: sqlite3_errmsg(db)))")
//            return false
//        }
//        
//        // Привязываем параметры к запросу
//        sqlite3_bind_text(statement, 1, url, -1, nil)
//        sqlite3_bind_text(statement, 2, responseData, -1, nil)
//        sqlite3_bind_double(statement, 3, Date().timeIntervalSince1970)
//        
//        // Выполняем запрос
//        if sqlite3_step(statement) != SQLITE_DONE {
//            print("Ошибка при сохранении данных в кэш (\(name)): $String(cString: sqlite3_errmsg(db)))")
//        } else {
//            print("Данные для URL \(url) успешно сохранены в кэш (\(name)).")
//        }
//        
//        // Освобождаем ресурсы
//        sqlite3_finalize(statement)
//        
//        return true
//    }
    
    // Чтение данных из кэша
    func loadFromCache(url: String, name: String = "CacheDB") -> String? {
        // Экранируем URL для безопасного использования в SQL
        let escapedURL = url.replacingOccurrences(of: "'", with: "''") // SQL экранирование одинарных кавычек
        
        let selectQuery = "SELECT responseData FROM \(name) WHERE url = '\(escapedURL)';"
        
        // Печатаем запрос перед выполнением
        print("SQL запрос: \(selectQuery)")
        
        var statement: OpaquePointer?
        
        // Подготовка запроса
        if sqlite3_prepare_v2(db, selectQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка при подготовке запроса для чтения данных из кэша (\(name)): \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }
        
        // Выполнение запроса
        if sqlite3_step(statement) == SQLITE_ROW {
            if let responseData = sqlite3_column_text(statement, 0) {
                let response = String(cString: responseData)
                sqlite3_finalize(statement)
                print("Данные для URL \(url): \(response)")
                return response
            }
        }
        
        // Если данных нет
        sqlite3_finalize(statement)
        print("\n!!! Нет данных для URL \(url) в кэше (\(name)). !!!\n")
        return nil
    }

    
    // Удаление данных из кэша
    func deleteFromCache(url: String, name: String = "CacheDB") {
        let deleteQuery = "DELETE FROM \(name) WHERE url = ?;"
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, deleteQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка при подготовке запроса для удаления данных из кэша (\(name)): \(String(cString: sqlite3_errmsg(db)))")
            return
        }
        
        sqlite3_bind_text(statement, 1, url, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Ошибка при удалении данных для URL \(url) (\(name)): \(String(cString: sqlite3_errmsg(db)))")
        } else {
            print("Данные для URL \(url) успешно удалены из кэша (\(name)).")
        }
        
        sqlite3_finalize(statement)
    }
    
    // Проверка на пустоту таблицы
    private func checkIfTableEmpty(name: String) -> Bool{
        let selectQuery = "SELECT COUNT(*) FROM \(name);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, selectQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка при подготовке запроса для проверки таблицы (\(name)): \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        
        if sqlite3_step(statement) == SQLITE_ROW {
            let count = sqlite3_column_int(statement, 0)
            if count == 0 {
                print("Таблица (\(name)) пуста .")
            } else {
                print("Таблица (\(name)) не пуста. Количество записей: \(count)")
            }
        }
        sqlite3_finalize(statement)
        return true
    }
    
    // Удаление таблицы
    func dropTable(name: String) -> Bool {
        let dropTableQuery = "DROP TABLE IF EXISTS \(name);"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, dropTableQuery, -1, &statement, nil) != SQLITE_OK {
            print("Ошибка при подготовке запроса для удаления таблицы (\(name)): \(String(cString: sqlite3_errmsg(db)))")
            return false
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Ошибка при удалении таблицы (\(name)): \(String(cString: sqlite3_errmsg(db)))")
        } else {
            print("Таблица (\(name)) успешно удалена.")
        }
        
        sqlite3_finalize(statement)
        return true
    }
    
    // Функция для тестирования всех операций с базой данных
    func testDatabaseOperations() {
        // Открываем базу данных
        if !openDatabase() {
            return
        }
        
        // 1. Создаём таблицу
        createTable(tableName: "testDB")
        
        // 2. Вставляем тестовые данные
        saveToCache(url: "http://example.com", responseData: "Example Response Data 1", name:"testDB")
        saveToCache(url: "http://anotherexample.com", responseData: "Another Response Data 2", name:"testDB")
        saveToCache(url: "http://3.com", responseData: "Another Response Data 3", name:"testDB")
        
        // 3. Читаем данные
        if let data = loadFromCache(url: "http://example.com", name: "testDB") {
            print("Чтение данных из кэша: \(data)")
        }
        
        // 3.4 Повторное открытие бд
//        closeDatabase()
        
//        if !openDatabase() {
//            return
//        }
        // 3.5. Читаем данные
        if let data = loadFromCache(url: "http://example.com", name: "testDB") {
            print("Чтение данных из кэша: \(data)")
        }
        
        // 4. Удаляем данные
        deleteFromCache(url: "http://example.com", name: "testDB")
        
        // 5. Проверяем, что данные были удалены
        if let data = loadFromCache(url: "http://example.com") {
            print("Чтение данных из кэша после удаления: \(data)")
        } else {
            print("Данные для URL http://example.com успешно удалены из кэша.")
        }
        
        // 6. Проверяем, что таблица пуста
        checkIfTableEmpty(name: "testDB")
        
        // 7. Удаляем таблицу
        dropTable(name: "testDB")
        
        // 8. Закрываем базу данных
//        closeDatabase()
        
        print("Создаём CacheDB")
        createTable(tableName: "CacheDB")
    }
}
