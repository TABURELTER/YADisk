//
//  TabBarView.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 18.02.2025.
//

import SwiftUI

struct TabBarView: View {
    @AppStorage("isAuthed") private var isAuthed: Bool = false
    @State var selection = 1
    var body: some View {
        NavigationView{
            TabView(selection: $selection){
                
                Folder(PATH: "/",title: "Главная",onDismiss: nil)
                    .tabItem {
                        Image(systemName: "archivebox")
                        Text("Все файлы")
                    }.tag(1)
                    
                
                Folder(PATH: "/",title: "Главная",onDismiss: nil)
                    .tabItem {
                        Image(systemName: "document")
                        Text("Последние")
                    }.tag(2)
                
                
                ProfileScreenView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("Профиль")
                    }.tag(3)
                
            }
            .navigationTitle(TabBarName(tag: selection))
            .navigationBarTitleDisplayMode(.automatic)
            .contextMenu{
                Menu{
                    Button {
                        isAuthed = false
                        print("logout")
                    } label: {
                        Label("Logout", systemImage: "iphone.and.arrow.right.outward")
                    }
                } label: {
                    Label("Debug Menu", systemImage: "desktopcomputer.trianglebadge.exclamationmark")
                }
            }
            .tint(.uIblue)
        }
    }
}

func TabBarName(tag: Int) -> String {
    switch (tag) {
    case 1:
        return "Все файлы"
    case 2:
        return "Последние"
    case 3:
        return "Профиль"
    default:
        return "???"
    }
}

#Preview {
    TabBarView()
}
