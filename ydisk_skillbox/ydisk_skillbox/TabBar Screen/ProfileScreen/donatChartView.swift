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


struct donatChartView: View {
    /*@Binding*/ var donationsIncomeDataSorted: [IncomeData]
    var selectedCategory: IncomeData?
    @Binding var selectedAmount: Double?
    
    var body: some View{
        VStack {
            Chart(donationsIncomeDataSorted) { income in
                let amountStr = "\(income.amount)"
                
                SectorMark(
                    angle: .value("Amount", income.amount),
                    innerRadius: .ratio(selectedCategory == income ? 0.5 : 0.6),
                    outerRadius: .ratio(selectedCategory == income ? 1.0 : 0.9),
                    angularInset: 3.0
                )
                .cornerRadius(6.0)
                .foregroundStyle(by: .value("category", income.category))
                .opacity(selectedCategory == income ? 1.0 : 0.8)
                .annotation(position: .overlay) {
                    Text(amountStr)
                        .font(selectedCategory == income ? .title : .headline)
                        .fontWeight(.bold)
                        .padding(5)
                    //                            .background(Color.white.opacity(0.4))
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.9), lineWidth: 2)
                            
                        }
                    
                }
                
            }
            .chartLegend(Visibility.hidden)
           
            .chartForegroundStyleScale(
                domain: donationsIncomeDataSorted.map  { $0.category },
                range: chartColors
            )
            .chartAngleSelection(value: $selectedAmount)
            
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack(spacing: 0) {
                        Text("20 гб")
                            .font(.title.bold())
                            .foregroundColor(.primary)
//                        Text("\(selectedCategory?.amount ?? 0, specifier: "%.1f")")
//                            .font(.title.bold())
//                            .foregroundColor((selectedCategory != nil) ? .primary : .clear)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
        }
    }
}





struct IncomeData: Identifiable, Equatable {
    var category: String
    var amount: Int
    var forceColor: Color? = nil
    var id = UUID()
    
    static func ==(lhs: IncomeData, rhs: IncomeData) -> Bool {
        return lhs.category == rhs.category && lhs.amount == rhs.amount
    }
}

