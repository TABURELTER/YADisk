//
//  LatestScreenView.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 20.02.2025.
//

import SwiftUI

struct LatestScreenView: View {
    var body: some View {
        List{
            let ico = cell(name: "Изображение",path: "/", icon: Image("YandexLogo1"), dateCreate: Date(), size: "5 КБ" )
            CustomCell(item: ico)
            
            
            let folder = cell(isFolder: true, name: "Анапа фото 2025", path: "/", dateCreate: Date(), size: "3321 КБ")
            CustomCell(item: folder)
        }.refreshable {
            print("refresh")
        }
    }
}

#Preview {
    LatestScreenView()
}

