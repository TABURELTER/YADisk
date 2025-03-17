//
//  ProfileScreenView.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 19.02.2025.
//

import SwiftUI
 

struct ProfileScreenView: View {
    let yandexService = YandexDiskService()
    
    @AppStorage("isAuthed") private var isAuthed: Bool = false
    @AppStorage("username") private var username: String = ""
    
    @State var isPresentedDialog: Bool = false
    @State var isPresentedAlert: Bool = false
    @State private var selectedAmount: Double? = nil
    
    
    let cumulativeIncomes: [(category: String, range: Range<Double>)]
    
    var donationsIncomeDataSorted = donationsIncomeData
    
    init() {
        donationsIncomeDataSorted.sort {
            $0.amount < $1.amount
        }
        
        var cumulative = 0.0
        self.cumulativeIncomes = donationsIncomeDataSorted.map {
            let newCumulative = cumulative + Double($0.amount)
            let result = (category: $0.category, range: cumulative ..< newCumulative)
            cumulative = newCumulative
            return result
        }
    }
    
    var selectedCategory: IncomeData? {
        if let selectedAmount,
           let selectedIndex = cumulativeIncomes
            .firstIndex(where: { $0.range.contains(selectedAmount) }) {
            return donationsIncomeDataSorted[selectedIndex]
        }
        return nil
    }
    
    
    var body: some View {
        NavigationStack {
            
            VStack{
                VStack{
                    donatChartView(
                        donationsIncomeDataSorted: donationsIncomeDataSorted,
                        selectedCategory: selectedCategory,
                        selectedAmount: $selectedAmount)
                    .padding()
                    .frame(height:370)
                    
                    LegendCharView(
                        IncomeDataSorted: donationsIncomeDataSorted)
                    .padding(.leading, 30)
                }
                VStack {
                    NavigationLink(destination: Text("Содержимое страницы")) {
                        HStack {
                            Text("Опубликованные файлы")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle()) // Убирает эффект выделения
//                    .padding()
                    
//                    Spacer()
                }
                .padding()
                Spacer()
            }
            .onAppear{
                yandexService.startFetchingData()
            }
            .onDisappear {
                yandexService.stopFetchingData()
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button(action: {
                    isPresentedDialog = true
                }) {
                    Image(systemName: "ellipsis")
                }
            }
        }
        

        .confirmationDialog("Профиль", isPresented: $isPresentedDialog) {
            Button("Выйти",role: .destructive){isPresentedAlert = true}
            Button("Отмена",role: .cancel){}
        }
        .alert(isPresented: $isPresentedAlert) {
            Alert(title: Text("Выход"),
                  message: Text("Вы уверены, что хотите выйти?"),
                  primaryButton: .destructive(Text("Нет")){},
                  secondaryButton: .cancel(Text("Да!")){
                YandexLoginViewModel.shared.logout()
                username = ""
            }
            )
        }
    }
}

#Preview {
    ProfileScreenView()
}


