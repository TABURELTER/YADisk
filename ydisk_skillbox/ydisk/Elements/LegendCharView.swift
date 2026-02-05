//
//  LegendCharView.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 20.02.2025.
//

import SwiftUI

struct LegendCharView: View {
    var IncomeDataSorted: [IncomeData]
    var chartColors: [Color] // Цвета диаграммы, которые мы будем передавать сюда
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(IncomeDataSorted.indices, id: \.self) { index in
                let item = IncomeDataSorted[index]
                let color = chartColors[safe: index] ?? .blue // Подключаем цвет по индексу
                
                HStack {
                    Circle()
                        .frame(width: 21, height: 21)
                        .foregroundColor(color) // Используем тот же цвет из chartColors для легенды
                    
                    Text(item.category)
                        .font(.custom("Capital", size: 17))
                    Spacer()
                }
            }
        }
    }
}

// Extension для безопасного получения значения по индексу
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


//#Preview {
//    LegendCharView(IncomeDataSorted: [])
//}
