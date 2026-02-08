//
//  Pdf.swift
//  idk yadisk
//
//  Created by Дмитрий Богданов on 12.03.2025.
//

import SwiftUI
import CachedAsyncImage
import UIKit
import QuickLook


struct Pdf: View {
    
    let item: cell
    @State var shareURL: String?
    @State var showShareOptions = false
    @State var showAlert = false
    
    @State private var wrapper: Wrapper?
    
    var body: some View {
        
        PDFViewWrapper(fileURL: URL(string:item.file ?? "")!)
            .toolbar {
                Button {
                    showAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button{
                    DataManager.shared.getPublishCell(path: item.path){ url in
                        self.wrapper = Wrapper(url: url)
                    }
                    
                } label: {
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                }
            }
            .sheet(item: $wrapper, onDismiss: {}, content: { value in
                ActivityViewController(wrapper: value)})
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Данный файл будет удалён", isPresented: $showAlert, titleVisibility: .visible){
            Button("Удалить",role:.destructive){
                DataManager.shared.DELETE(cell: item){print($0)}}
            Button(role:.cancel){}label:{Text("Отмена")}}

    }
    
}


#Preview {
    NavigationView {
        Folder(
            PATH: "/",
            title: "Debug",
            onDismiss: nil
        )
    }
}
