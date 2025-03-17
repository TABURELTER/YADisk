//
//  Img.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 12.03.2025.
//

import SwiftUI
import CachedAsyncImage

struct Img: View {
    let PATH: String
    let title: String
    let item: cell
    let onDismiss: ((Bool) -> Void)?
    
    @AppStorage("token") var token: String = ""
    @State var isLoading: Bool = true
    
    @State var zoom: CGFloat = 1
    @State private var lastZoom: Double = 1
    @State var offset: CGSize = .zero
    @State private var initialOffset: CGSize = .zero // Хранит смещение до начала жеста
    @State private var opacity: Double = 0
    
    @State private var buttonsOpacity: Double = 1
    @State private var isBlackBackgroundVisible: Bool = false // Флаг для контроля видимости черного фона
    @Environment(\.colorScheme) var colorScheme: ColorScheme // Для учета светлой/темной темы
    
    var body: some View {
        ZStack {
            // Опциональный черный фон с изменением opacity
            if zoom > 1 {
                Color.black
                    .opacity(opacity)
                    .ignoresSafeArea(edges: .all)
                    .onChange(of: zoom) { v,_ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            opacity = v >= 1 ? 1 : 0
                            buttonsOpacity = v > 1 ? 0 : 1
                            isBlackBackgroundVisible = v > 1 // Обновляем флаг видимости черного фона
                        }
                    }
                    .onChange(of: offset){
                        withAnimation(.linear(duration: 0.15)) {
                            buttonsOpacity = 0
                        }
                    }
            }
            
            // Картинка с масштабированием
            CachedAsyncImage(url: URL(string: item.sizes?.first?.url ?? ""), urlCache: .myCache) { image in
                VStack {
                    Spacer()
                    GeometryReader { geometry in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                            .offset(zoom <= 1 ? .zero : offset)
                            .scaleEffect(zoom)
                    }
                    Spacer()
                }
                
                
            } placeholder: {
                ProgressView()
                    .tint(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Кнопка с иконкой
            VStack {
                Spacer()
                HStack() {
                    
                    Button {
                        // Действие кнопки
                    } label: {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 43, height: 43)
                            .foregroundStyle(Color(zoom > 1 ? .darkGray : .systemGray5))
                            .opacity(buttonsOpacity)
                            .overlay{
                                Image(systemName: "pencil.line")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundStyle(zoom > 1 ? .white: .blue)
                                    .frame(width: 23, height: 23)
                                    .opacity(buttonsOpacity)
                            }
                    }
                    
                    Button {
                        // Действие кнопки
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 43, height: 43)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(zoom > 1 ? .white: .blue, Color(zoom > 1 ? .darkGray : .systemGray5))
                            .opacity(buttonsOpacity)
                    }
                    
                    Button {
                        DataManager.shared.DELETE(cell: item){
                            print($0)
                        }
                    } label: {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 43, height: 43)
                            .foregroundStyle(Color(zoom > 1 ? .darkGray : .systemGray5))
                            .opacity(buttonsOpacity)
                            .overlay{
                                Image(systemName: "trash")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundStyle(zoom > 1 ? .white: .blue)
                                    .frame(width: 23, height: 23)
                                    .opacity(buttonsOpacity)
                            }
                    }
                    
                }
            }
            
            // Добавляем панель инструментов
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("\(item.name)")
                            .foregroundColor(isBlackBackgroundVisible ? .white : .primary)
                            .font(.headline)
                        Text("\(item.dateCreate)")
                            .foregroundStyle(.uIgray)
                            .font(.subheadline)
                    }
                    .opacity(buttonsOpacity)
                }
                
            }
            .toolbarBackground(
                isBlackBackgroundVisible ?
                Color.black.opacity(0.8) :
                    Color(colorScheme == .dark ? .systemGray6 : .systemGray5)
                    .opacity(buttonsOpacity), for: .navigationBar
            )
            .toolbarBackground(buttonsOpacity == 1 ? .visible : .hidden , for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .modifier(NoInternetToolbarModifier(opacity: $buttonsOpacity))
            .navigationBarBackButtonHidden(buttonsOpacity > 0 ? false : true)
        }
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        var v = value
                        if v < lastZoom {
                            v = lastZoom + v
                        }
                        if zoom > 0.05 && zoom < 10 {
                            self.zoom = v
                        }
                    }
                    .onEnded { value in
                        lastZoom = value
                        if zoom < 1 {
                            lastZoom = 1
                            withAnimation(.linear(duration: 0.2)) {
                                self.zoom = 1
                            }
                        }
                    },
                DragGesture()
                    .onChanged { value in
                        self.offset = CGSize(
                            width: initialOffset.width + value.translation.width / zoom,
                            height: initialOffset.height + value.translation.height / zoom
                        )
                    }
                    .onEnded { _ in
                        self.initialOffset = offset
                    }
                
            )
        )
        .onTapGesture{
            withAnimation(.linear(duration: 0.2)){
                buttonsOpacity = 1
            }
        }
    }
}








#Preview("Folder"){
    NavigationView{
        Folder(
            PATH: "/",
            title: "Img",
            onDismiss: {
                if $0 {
                    print("Folder closed, proceeding with action")
                    // Выполнить действие
                } else {
                    print("Folder closed, action cancelled")
                }
            },
            token: "y0__xCHp4HcARiBsjUg3_WXtBIdcAJl-Q-Kq15AFkuCOvZV4pQJdg"
        )
    }
}

#Preview("test item") {
    let s = Size.init(url: "https://downloader.disk.yandex.ru/disk/21248da6cd99ca044d53a245a3465bdddf5b496343de849d2fc523866daf1061/67d017d7/k8PMdKNl2Zs3VMJ5vxuslAf6IAJVfju3kDszrxsyK_yW1U0CIpreSZiX9aJ67MKVfYDeRS-swTRj8WbzU950Vg%3D%3D?uid=461394823&filename=1648325994_20-kartinkof-club-p-mem-the-weekend-20.jpg&disposition=inline&hash=&limit=0&content_type=image%2Fjpeg&owner_uid=461394823&fsize=368692&hid=92e15a879ac59ffd9043ca91068716f9&media_type=image&tknv=v2&etag=ee98d6c8ca7b4b1a43b76eb98859dfc9", name: "test")
    NavigationView{
        Img(
            PATH: "/",
            title: "Img",
            item: cell.init(name: "test", path: "/", dateCreate: Date(), size: "1024", sizes: [s,s,s]),
            onDismiss: { shouldProceed in
                if shouldProceed {
                    print("Folder closed, proceeding with action")
                    // Выполнить действие
                } else {
                    print("Folder closed, action cancelled")
                }
            },
            token: "y0__xCHp4HcARiBsjUg3_WXtBIdcAJl-Q-Kq15AFkuCOvZV4pQJdg"
        )
    }
}
