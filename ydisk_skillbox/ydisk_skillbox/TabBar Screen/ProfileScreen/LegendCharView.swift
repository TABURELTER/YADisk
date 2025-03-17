//
//  LegendCharView.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 20.02.2025.
//

import SwiftUI

struct LegendCharView: View {
    var IncomeDataSorted: [IncomeData]
    var body: some View {
        VStack(spacing: 10){
            ForEach(IncomeDataSorted) { i in
                HStack{
                    Circle().frame(width: 21, height: 21)
                        .foregroundColor((i.forceColor != nil) ? i.forceColor! : .blue)
                    
                    Text(i.category).font(.custom("Capital",size: 17))
                    Spacer()
                    
                }
            }
        }
    }
}

#Preview {
    LegendCharView(IncomeDataSorted: donationsIncomeData)
}
