//
//  CustomCell.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 02.03.2025.
//

import SwiftUI
import CachedAsyncImage


struct CustomCell: View, Equatable {
    let item: cell

    var body: some View {
        HStack(spacing: 12) {
            iconView

            VStack(alignment: .leading, spacing: 4) {
                // Название элемента
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                // Дополнительная информация
                HStack(spacing: 8) {
                    if !item.isFolder {
                        Text(item.size)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    Text(item.dateCreate, style: .date)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
//        .padding(.vertical, 8)
//        .padding(.horizontal, 12)

        .contentShape(Rectangle())
    }

    // Отображение иконки или превью файла
    @ViewBuilder
    private var iconView: some View {

        
            if item.isFolder {
                Image("Folder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding(.trailing,5)
                    .padding(.leading,5)
            } else if let extensionPart = item.fileExtension, isImage(extensionPart) {
                CachedAsyncImage(url: URL(string: item.sizes?.first?.url ?? ""),urlCache: .myCache) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } placeholder: {
                    ProgressView()
                        .tint(.uIblue)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Image("Default-\(item.fileExtension?.uppercased() ?? "UNKNOWN")")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 40)
                    .padding(.trailing,5)
                    .padding(.leading,5)
            }
        
    }

    // Реализация Equatable для сравнения
    static func == (lhs: CustomCell, rhs: CustomCell) -> Bool {
        lhs.item.id == rhs.item.id
    }
}

func isImage(_ fileExtension: String) -> Bool {
    // Список поддерживаемых расширений
    let supportedExtensions: Set<String> = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "heic", "heif","dng"]
    
    // Проверяем, содержится ли расширение в списке поддерживаемых
    return supportedExtensions.contains(fileExtension.lowercased())
}


#Preview ("фото"){
    NavigationView{
        Folder(
            PATH: "disk:/фото",
            title: "Debug images",
            onDismiss: nil,
            token: "y0__xCHp4HcARiBsjUg3_WXtBIdcAJl-Q-Kq15AFkuCOvZV4pQJdg"
        )
    }
}

#Preview ("Главная"){
    NavigationView{
        Folder(
            PATH: "disk:/",
            title: "Debug images",
            onDismiss: nil,
            token: "y0__xCHp4HcARiBsjUg3_WXtBIdcAJl-Q-Kq15AFkuCOvZV4pQJdg"
        )
    }
}
#Preview ("папки"){
    List{
        let ico = cell(name: "Изображение",path: "/", icon: Image("YandexLogo1"), dateCreate: Date(), size: "5 КБ" )
        CustomCell(item: ico)
        
        
        let folder = cell(isFolder: true, name: "Анапа фото 2025", path: "/", dateCreate: Date(), size: "3321 КБ")
        CustomCell(item: folder)
    }
}


class cell {
    let id:UUID = UUID()
    let isFolder:Bool
    let icon:Image?
    
    let path:String
    
    let name:String
    let dateCreate:Date
    let size:String
    
    let sizes: [Size]?
    
    let MD5:String?
    
    init(isFolder:Bool = false,name:String, path:String,icon:Image? = nil,dateCreate:Date, size:String, sizes: [Size]? = nil,MD5:String? = nil) {
        self.path = path
        self.isFolder = isFolder
        self.icon = icon
        self.name = name
        self.dateCreate = dateCreate
        self.size = size
        self.sizes = sizes
        self.MD5 = MD5
    }
    
    var fileExtension: String? {
           guard let dotIndex = name.lastIndex(of: ".") else { return nil }
           return String(name[name.index(after: dotIndex)...])
       }
}
