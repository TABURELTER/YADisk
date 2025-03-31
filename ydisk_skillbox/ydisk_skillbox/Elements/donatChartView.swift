//
//  donatChartView.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 20.02.2025.
//

import SwiftUI
import Charts

let chartColors: [Color] = [
    .uIpinl,
    .uIgray,
    .uIblue,
    Color(red: 1.00, green: 0.93 , blue: 0.44)
]


struct DonutChartView: View {
    @State private var donationsIncomeDataSorted: [IncomeData] = [IncomeData(amount: 0, category: "Загрузка...")]
    @State private var selectedAmount: Double? = nil
    private let yandexService = YandexDiskService()
    
    private let chartColors: [Color] = [
        .uIpinl,.uIgray,.uIblue,Color(red: 1.00, green: 0.93 , blue: 0.44),.blue, .red, .green, .yellow // Список цветов для диаграммы и легенды
    ]
    
    var body: some View {
        VStack {
            Chart(donationsIncomeDataSorted) { income in
                let amountStr = "\(formatBytes(Int(income.amount)))"
                
                // Ограничиваем максимальный угол, чтобы сектора не перекрывались
                let adjustedAmount = max(7, 10.0) // Минимальный размер сектора - 10 единиц
                
                SectorMark(
                    angle: .value("Amount", adjustedAmount),
                    innerRadius: .ratio(0.6),
                    outerRadius: .ratio(0.9),
                    angularInset: 3.0
                )
                .cornerRadius(6.0)
                .foregroundStyle(by: .value("category", income.category))
                .opacity(0.8)
                .annotation(position: .overlay) {
                    Text(amountStr)
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.9), lineWidth: 2)
                        }
                }
            }
            .chartLegend(Visibility.hidden)
            .chartForegroundStyleScale(
                domain: donationsIncomeDataSorted.map { $0.category },
                range: chartColors
            )
            .chartAngleSelection(value: $selectedAmount)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack(spacing: 0) {
                        Text(total)
                            .font(.title.bold())
                            .foregroundColor(.primary)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            
            LegendCharView(IncomeDataSorted: donationsIncomeDataSorted, chartColors: chartColors)
                .padding(.top, 10)
        }
        .onAppear {
            fetchData()
        }
    }

    private func fetchData() {
        yandexService.fetchData { newData in
            DispatchQueue.main.async {
                donationsIncomeDataSorted = newData.sorted { $0.amount > $1.amount }
                print("Данные обновлены в диаграмме:")
                for item in donationsIncomeDataSorted {
                    print("Категория: \(item.category), raw: \(item.amount) -> formatted: \(formatBytes(Int(item.amount)))")
                }
            }
        }
    }
}








#Preview {
    DonutChartView()
}
