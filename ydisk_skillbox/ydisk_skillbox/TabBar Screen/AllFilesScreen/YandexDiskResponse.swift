//
//  YandexDiskResponse.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 10.03.2025.
//

import Foundation

struct DiskResponse: Codable, Equatable {
    let embedded: Embedded?
    let name: String
    let exif: [String: String]
    let resourceID: String
    let created: String
    let modified: String
    let path: String
    let commentIDs: [String: String]
    let type: String
    let revision: Int

    enum CodingKeys: String, CodingKey, Equatable {
        case embedded = "_embedded"
        case name, exif
        case resourceID = "resource_id"
        case created, modified, path
        case commentIDs = "comment_ids"
        case type, revision
    }
}

struct Embedded: Codable, Equatable {
    let sort: String?
    let items: [Item]
    let limit: Int
    let offset: Int
    let path: String
    let total: Int
}

struct Item: Codable, Equatable {
    let antivirusStatus: String?
    let photosliceTime: String?
    let commentIDs: [String: String]
    let name: String
    let exif: [String: ExifValue]
    let created: String
    let size: Int?
    let resourceID: String
    let modified: String
    let mimeType: String?
    let sizes: [Size]?
    let file: String?
    let mediaType: String?
    let preview: String?
    let path: String
    let sha256: String?
    let type: String
    let md5: String?
    let revision: Int

    enum CodingKeys: String, CodingKey, Equatable {
        case antivirusStatus = "antivirus_status"
        case photosliceTime = "photoslice_time"
        case commentIDs = "comment_ids"
        case name, exif, created, size
        case resourceID = "resource_id"
        case modified
        case mimeType = "mime_type"
        case sizes, file
        case mediaType = "media_type"
        case preview, path, sha256, type, md5, revision
    }
}

struct ExifValue: Codable, Equatable {
    let stringValue: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self.stringValue = stringValue
        } else if let numberValue = try? container.decode(Double.self) {
            self.stringValue = String(numberValue)
        } else if let intValue = try? container.decode(Int.self) {
            self.stringValue = String(intValue)
        } else {
            self.stringValue = nil
        }
    }
}

struct Size: Codable, Equatable {
    let url: String
    let name: String
}
