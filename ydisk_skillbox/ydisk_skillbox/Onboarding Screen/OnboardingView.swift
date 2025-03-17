//
//  OnboardingView.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 18.02.2025.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme
    let texts = ["Теперь все ваши документы в одном месте",
                 "Доступ к файлам без интернета",
                 "Делитесь вашими файлами с другими"]
    
    @State private var page: CGFloat = 0
    @State private var currentPage: Int = 0
    @Environment(\.dismiss) var dismiss // Для закрытия окна
    @Binding var isFirstLaunch: Bool
    
    // Добавим ScrollViewReader для прокрутки
    var body: some View {
        ZStack{
            Color(colorScheme == .light ? .white : .black).ignoresSafeArea()
            VStack {
                ScrollViewReader { proxy in
                    TrackableScrollView(.horizontal, showIndicators: false, contentOffset: $page) {
                        LazyHStack {
                            ForEach(0..<texts.count, id: \.self) { index in
                                VStack {
                                    Image("Image \(index)")  // Убедитесь, что изображения существуют в вашем проекте
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 149, height: 147)
                                        .containerRelativeFrame(.horizontal)
                                    
                                    Text(texts[index])
                                        .frame(width: 245)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 35)
                                }
                            }
                        }
                    }
                    .scrollTargetBehavior(.paging)
                    
                    PageControl(numberOfPages: texts.count, currentPage: $currentPage)
                        .frame(width: CGFloat(texts.count * 18))
                        .padding(.top, 30)
                    
                    
                    // Кнопка для прокрутки к следующему элементу
                    Button(action: {
                        if currentPage == texts.count - 1 {
                            isFirstLaunch = false
                            print("установили флаг isFirstLaunch на false")
                            dismiss()
                        }else{
                            withAnimation {
                                // Прокрутка к следующему элементу
                                let nextPage = min(currentPage + 1, texts.count - 1)
                                proxy.scrollTo(nextPage, anchor: .center)
                                currentPage = nextPage
                            }
                        }
                    }) {
                        Text("Далее")
                            .font(.headline)
                            .frame(width: UIScreen.main.bounds.width - 80, height: 40)
                    }
                    .padding(.top, 30)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)
                    .tint(.uIblue)
                }
            }
            .onChange(of: page) {
                // Обновляем текущую страницу в зависимости от прокрутки
                let pageIndex = Int((page / UIScreen.main.bounds.width).rounded())
                if pageIndex != currentPage {
                    currentPage = pageIndex
                }
            }
        }
    }
}

struct PageControl: View {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.uIblue : Color.uIgray)
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
}

#Preview {
    @State var isf = true
    OnboardingView(isFirstLaunch: $isf)
}

