//
//  Folder.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 10.03.2025.
//

import SwiftUI

struct Folder: View {
    let PATH: String
    let title: String
    let onDismiss: ((Bool) -> Void)?
    var lastUpdatedSort: Bool = false
    var publicLink: Bool = false

    @AppStorage("token") var token: String = ""
    @State private var cells: [CustomCell] = []
    @State private var isLoading: Bool = true

    var body: some View {
        List {
            ForEach(cells, id: \.item.id) { cell in
                NavigationLink(destination: destinationView(for: cell)) {
                    cell
                }
                .onAppear {
                    if cell == cells.last && !lastUpdatedSort{
                        loadMoreCells()
                    }
                }
                .contextMenu{
                    Button(role: .destructive) {
                          print("Удалить")
                      } label: {
                          Label("Удалить", systemImage: "trash")
                      }
                }
            }

            if isLoading {
                loadingIndicator
            }
        }
       
        .navigationTitle("\(title) - \(cells.count)")
        .navigationBarTitleDisplayMode(.automatic)
        .refreshable {
            refreshData()
        }
        .onAppear {
            if !publicLink{
                loadInitialData(lastUpdatedSort:lastUpdatedSort)
            }else{
                
            }
        }
    }

    private func destinationView(for cell: CustomCell) -> some View {
        let fileViewMapping: [Set<String>: (view: (CustomCell) -> AnyView, logMessage: (CustomCell) -> Void)] = [
            ["pdf"]: (
                view: { cell in
                    AnyView(Pdf(item: cell.item))  // Убедитесь, что Pdf - это View
                },
                logMessage: {i in
//                    print("Opening file with extension \($0.item.fileExtension ?? "unknown") at formatted path: \(DataManager.shared.formatePath($0.item.path))")
//                    print("File description: \(String(describing: $0.item.file?.description))")
                    print("")
                }
            ),
            ["doc","docx"]: (
                view: { cell in
                    AnyView(OfficeView(item: cell.item))
                },
                logMessage: {i in
//                    print("Opening file with extension \($0.item.fileExtension ?? "unknown") at formatted path: \(DataManager.shared.formatePath($0.item.path))")
//                    print("File description: \(String(describing: $0.item.file?.description))")
                    print("")
                }
            ),
            ["jpg","jpeg","png","gif","bmp","tiff","webp","heif","heic"]: (
                view: { cell in
                    AnyView(Img(PATH: cell.item.path, item: cell.item, onDismiss: handleDismiss, needReload: {value in
                        print("в Folder пришло \(value) от Img")
                        DispatchQueue.main.async(execute: refreshData)
                    }))
                },
                logMessage: {i in
                    print("Opening file with extension \(i.item.fileExtension ?? "unknown") at formatted path: \(DataManager.shared.formatePath(i.item.path))")
                    print("File description: \(String(describing: i.item.file?.description))")
                    print("")
                }
            ),
        ]

        if let fileExtension = cell.item.fileExtension?.lowercased() {
            for (extensions, action) in fileViewMapping {
                if extensions.contains(fileExtension) {
                    action.logMessage(cell)  // Вызываем logMessage с cell
                    return action.view(cell)  // Возвращаем view как AnyView
                }
            }
        }

        return AnyView(Text("Unsupported file type"))
    }


    private var loadingIndicator: some View {
        HStack {
            ProgressView()
                .tint(.uIblue)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Text("Загрузка...")
        }
    }

    private func loadInitialData(lastUpdatedSort: Bool) {
        guard cells.isEmpty else { return }
        isLoading = true
        DataManager.shared.getCustomCells(path: PATH,lastUpdatedSort:lastUpdatedSort) { result in
            cells = result
            isLoading = false
        }
    }

    private func loadMoreCells() {
        guard !isLoading else { return }
        isLoading = true
        DataManager.shared.getCustomCells(path: PATH, offset: cells.count,lastUpdatedSort:lastUpdatedSort) { result in
            cells += result
            isLoading = false
        }
    }

    private func refreshData() {
        isLoading = true
        cells = []
        loadInitialData(lastUpdatedSort:lastUpdatedSort)
    }

    private func handleDismiss(shouldProceed: Bool) {
        if shouldProceed {
            print("Folder closed, proceeding with action")
        } else {
            print("Folder closed, action cancelled")
        }
    }

    private var shouldProceedOnDismiss: Bool {
        Bool.random()
    }
}

#Preview {
    NavigationView {
        Folder(
            PATH: "/",
            title: "Debug",
            onDismiss: { shouldProceed in
                if shouldProceed {
                    print("Folder, proceeding with action")
                } else {
                    print("Folder, action cancelled")
                }
            }
        )
    }
}
