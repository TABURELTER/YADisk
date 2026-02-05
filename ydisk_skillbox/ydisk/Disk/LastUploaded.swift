//
//  LastUploaded.swift
//  idk yadisk
//
//  Created by Дмитрий Богданов on 23.03.2025.
//


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let lastUploaded = try? JSONDecoder().decode(LastUploaded.self, from: jsonData)

import Foundation

// MARK: - Root Structure
struct LastUploadedResponse: Codable {
    let items: [UploadedItem]
}

// MARK: - Uploaded Item
struct UploadedItem: Codable {
    let antivirusStatus: String?
    let size: Int?
    let commentIds: CommentIDs?
    let name: String?
    let exif: [String: String]?
    let created: String?
    let resourceID: String?
    let modified: String?
    let mimeType: String?
    let sizes: [ItemSize]?
    let file: String?
    let mediaType: String?
    let preview: String?
    let path: String?
    let sha256: String?
    let type: String?
    let md5: String?
    let revision: Int?
    let publicKey: String?
    let publicURL: String?

    enum CodingKeys: String, CodingKey {
        case antivirusStatus = "antivirus_status"
        case size
        case commentIds = "comment_ids"
        case name
        case exif
        case created
        case resourceID = "resource_id"
        case modified
        case mimeType = "mime_type"
        case sizes
        case file
        case mediaType = "media_type"
        case preview
        case path
        case sha256
        case type
        case md5
        case revision
        case publicKey = "public_key"
        case publicURL = "public_url"
    }
}

// MARK: - Comment IDs
struct CommentIDs: Codable {
    let privateResource: String?
    let publicResource: String?

    enum CodingKeys: String, CodingKey {
        case privateResource = "private_resource"
        case publicResource = "public_resource"
    }
}

// MARK: - Item Size
struct ItemSize: Codable {
    let url: String?
    let name: String?
}
