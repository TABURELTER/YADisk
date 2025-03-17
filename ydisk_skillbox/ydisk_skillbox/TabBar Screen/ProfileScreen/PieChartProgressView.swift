//
//  PieChartProgressView.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 19.02.2025.
//


import SwiftUI
import Charts

struct PieChartProgressView: View {
    // 1
    let portions = [
        ProgressPortion(day: 1, portion: 0.01, rolloutPercentage: 1),
        ProgressPortion(day: 2, portion: 0.01, rolloutPercentage: 2),
        ProgressPortion(day: 3, portion: 0.03, rolloutPercentage: 5),
        ProgressPortion(day: 4, portion: 0.05, rolloutPercentage: 10),
        ProgressPortion(day: 5, portion: 0.1, rolloutPercentage: 20),
        ProgressPortion(day: 6, portion: 0.3, rolloutPercentage: 50),
        ProgressPortion(day: 7, portion: 0.5, rolloutPercentage: 100)
    ]
    
    // 2
    let day: Int
    
    var body: some View {
        // 3
        if let rollout = portions.first(where: { $0.day == day })?.rolloutPercentage {
            // 4
            ZStack(alignment: .center) {
                // 5
                VStack {
                    Text("\(Int(rollout))%")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundStyle(.primary)
                    Text("Day \(day) out of 7")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal)
                }
                
                // 6
                Chart(portions, id: \.day) { element in
                    // 7
                    if #available(iOS 17.0, *) {
                        SectorMark(
                            angle: .value("Phased Release Progress", element.portion),
                            innerRadius: .ratio(0.55),
                            angularInset: 2
                        )
                        .cornerRadius(10)
                        // 8
                        .foregroundStyle(day >= element.day ? .purple : .gray.opacity(0.3))
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            .frame(width: 250, height: 250)
        }
    }
}

import Foundation

struct ProgressPortion {
    let day: Int
    let portion: Double
    let rolloutPercentage: Int
}

#Preview {
    PieChartProgressView(day: 6)
}
