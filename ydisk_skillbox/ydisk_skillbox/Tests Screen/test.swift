import SwiftUI
import Charts
import YandexLoginSDK

struct test: View {
    var body: some View {
        TabView {
            OnboardingPageView(imageName: "Image 0",
                               title: "",
                               description: "Теперь все ваши документы в одном месте")
            OnboardingPageView(imageName: "Image 1",
                               title: "",
                               description: "Доступ к файлам без интернета")
            OnboardingPageView(imageName: "Image 2",
                               title: "",
                               description: "Делитесь вашими файлами с другими")
        }
        .tint(.red)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        
    }
}

struct test2: View {
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
        donatChartView(
            donationsIncomeDataSorted: donationsIncomeDataSorted,
            selectedCategory: selectedCategory,
            selectedAmount: $selectedAmount
            )
//        .padding()
    }
}







//#Preview("test - 1") {
//    test()
//}

#Preview("test - 2") {
    test2()
}

