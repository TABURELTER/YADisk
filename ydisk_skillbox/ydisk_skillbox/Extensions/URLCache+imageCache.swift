//
//  URLCache+imageCache.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 11.03.2025.
//

import Foundation

// Расширение для URLCache
extension URLCache {
    static let myCache: URLCache = {
        // Размеры кэша: 1 ГБ в памяти и 10 GB на диске
        let memoryCapacity = 1024 * 1024 * 1024 // 1024 MB
        let diskCapacity = 10 * 1024 * 1024 * 1024 // 10 GB
        let diskPath = "myCache" // Путь к кэшу на диске

        let customCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: diskPath)
        
        return customCache
    }()
}
