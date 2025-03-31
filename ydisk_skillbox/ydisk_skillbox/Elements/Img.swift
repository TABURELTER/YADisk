//
//  Img.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 12.03.2025.
//

import SwiftUI
import CachedAsyncImage
import UIKit


struct Img: View {
    let PATH: String
    let item: cell
    let onDismiss: ((Bool) -> Void)?
    
    @State var title: String = ""
    
    @State var needReload: (Bool) -> Void
    
    @AppStorage("token") var token: String = ""
    @State var isLoading: Bool = true
    
    @State var photo: Image?
    @State private var shareableURL: String? = nil
    @State private var isGeneratingLink = false
    
    
    @State private var wrapper: Wrapper?
    
    
    @State var showAlert : Bool = false
    @State var showShareOptions: Bool = false
    @State var showRename: Bool = false
    @State var newName: String = ""
    
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
            Group{
                // Опциональный черный фон с изменением opacity
                if zoom > 1 {
                    backgroudColors
                }
                
                // Картинка с масштабированием
                asyncImage
                
                // Кнопка с иконкой
                action_buttons
                .confirmationDialog("Данное изображение будет удалено", isPresented: $showAlert, titleVisibility: .visible){
                Button("Удалить изображение",role:.destructive){
                    DataManager.shared.DELETE(cell: item){print($0)}}
                Button(role:.cancel){}label:{Text("Отмена")}}
                
                .confirmationDialog("Поделиться", isPresented: $showShareOptions, titleVisibility: .visible) {
                    if photo != nil {
                        Button("Поделиться изображением") {
                            self.wrapper = Wrapper(image: photo ?? Image(systemName:""))
                        }
                    }
                    
                    Button("Поделиться ссылкой") {
                        DataManager.shared.getPublishCell(path: item.path) { url in
                                print("получили \(url)")
                            self.wrapper = Wrapper(url: url)
                        }
                    }
                    Button(role:.cancel){}label:{Text("Отмена")}
                }
            }
            
            // Добавляем панель инструментов
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("\(title)")
                            .foregroundColor(isBlackBackgroundVisible ? .white : .black)
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
        .onAppear{
            title = item.name
            print(item.path)
            
        }
        .modifier(NoInternetToolbarModifier(opacity: $buttonsOpacity))
    }
    
    
    
    private var backgroudColors: some View{
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
    
    private var asyncImage: some View {
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
                        .onAppear{
                            photo = image
                            print("добавили изображение")
                        }
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
        .alert("Переименовать", isPresented: $showRename , actions: {            
            TextField(item.name, text: $newName)
              
            Button("Готово", action: {
                DataManager.shared.rename(item: item, newName: newName+"."+(item.fileExtension ?? ""), completion: {v in
                    print(v)
                    title = newName+"."+(item.fileExtension ?? "")
                    item.path = item.path.replacingOccurrences(of: item.name, with: newName+"."+(item.fileExtension ?? "") )
                    needReload(true)
                })
            }).disabled(newName.isEmpty)
            Button("Отмена", role: .cancel, action: {})
        }, message: {
            Text("Укажите новое имя файла")
        })
    }
    
    private var action_buttons: some View {
        VStack {
            Spacer()
            HStack() {
                
                Button {
                    showRename = true
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
                }.padding(.leading, 25)
                
                Spacer()
  
                Button {
                    showShareOptions = true
                } label: {
                    Image(systemName: "square.and.arrow.up.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 43, height: 43)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(zoom > 1 ? .white : .blue, Color(zoom > 1 ? .darkGray : .systemGray5))
                        .opacity(buttonsOpacity)
                }
                .sheet(item: $wrapper, onDismiss: {}, content: { value in
                    ActivityViewController(wrapper: value)})
                .padding(.leading, 25)
                
                Spacer()
                
                Button {
                    showAlert = true
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
                }.padding(.trailing, 25)
                
            }
        }
    }
}


struct Wrapper: Identifiable {
    let id = UUID()
    let url: String?
    let image: UIImage?
    // Инициализатор с только текстом
    init(url: String) {
        self.url = url
        self.image = nil
    }

    // Инициализатор с только изображением
    init(image: Image) {
        self.url = nil
        self.image = image.asUIImage()
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let wrapper: Wrapper
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        if let image = wrapper.image {
            return UIActivityViewController(activityItems: [image], applicationActivities: nil)
        }
        if let url = wrapper.url {
            return UIActivityViewController(activityItems: [url], applicationActivities: nil)
        }
        return UIActivityViewController(activityItems: ["ПРОИЗОШЛА ОШИБКА"], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
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
            }
        )
    }
}

#Preview("test item") {
    let s = Size.init(url: "https://downloader.disk.yandex.ru/disk/dff0b48539d32e67c5dcf4fb3dd5e1a5550097abdf10c2b8ebf7bb7ec67f100b/67ea005b/k8PMdKNl2Zs3VMJ5vxuslAf6IAJVfju3kDszrxsyK_yW1U0CIpreSZiX9aJ67MKVfYDeRS-swTRj8WbzU950Vg%3D%3D?uid=461394823&filename=B2.jpg&disposition=attachment&hash=&limit=0&content_type=image%2Fjpeg&owner_uid=461394823&fsize=368692&hid=92e15a879ac59ffd9043ca91068716f9&media_type=image&tknv=v2&etag=ee98d6c8ca7b4b1a43b76eb98859dfc9", name: "test")
    NavigationView{
        Img(
            PATH: "/",
            item: cell.init(name: "test", path: "/", dateCreate: Date(), size: "1024", sizes: [s,s,s]),
            onDismiss: { shouldProceed in
                if shouldProceed {
                    print("Folder closed, proceeding with action")
                    // Выполнить действие
                } else {
                    print("Folder closed, action cancelled")
                }
            }, needReload: { value in
                print("получили needReload: \(value)")  
            }
        )
    }
}
