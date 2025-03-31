//
//  ProfileScreenView.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 19.02.2025.
//

import SwiftUI
import CachedAsyncImage

struct ProfileScreenView: View {
    @StateObject private var yandexService = YandexDiskService()
    
    @State private var selectedAmount: Double? = nil

    var body: some View {
        VStack {
            DonutChartView()
            .padding()
            .frame(height: 370)

            .padding()
//            VStack {
//                NavigationLink(destination: PublicList()) {
//                    HStack {
//                        Text("Опубликованные файлы")
//                            .font(.system(size: 16))
//                            .foregroundColor(.black)
//                        
//                        Spacer()
//                        
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color.white)
//                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
//                    )
//                }
//                .buttonStyle(PlainButtonStyle()) // Убирает эффект выделения
//            }
            .padding()
            Spacer()
        }
        .onAppear {

        }
    }
}



#Preview {
    TabBarView(selection: 3)
}


