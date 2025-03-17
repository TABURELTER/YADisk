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
                    if cell == cells.last {
                        loadMoreCells()
                    }
                }
            }

            if isLoading {
                loadingIndicator
            }
        }
        .modifier(NoInternetToolbarModifier())
        .navigationTitle("\(title) - \(cells.count)")
        .navigationBarTitleDisplayMode(.automatic)
        .refreshable {
            refreshData()
        }
        .onAppear {
            loadInitialData()
        }
        .onDisappear {
            onDismiss?(shouldProceedOnDismiss)
        }
    }

    private func destinationView(for cell: CustomCell) -> some View {
        if let fileExtension = cell.item.fileExtension {
            return AnyView(Img(PATH: cell.item.path, title: cell.item.name, item: cell.item, onDismiss: handleDismiss))
        } else {
            return AnyView(Folder(PATH: cell.item.path, title: cell.item.name, onDismiss: nil))
        }
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

    private func loadInitialData() {
        guard cells.isEmpty else { return }
        isLoading = true
        DataManager.shared.getCustomCells(path: PATH) { result in
            cells = result
            isLoading = false
        }
    }

    private func loadMoreCells() {
        guard !isLoading else { return }
        isLoading = true
        DataManager.shared.getCustomCells(path: PATH, offset: cells.count) { result in
            cells += result
            isLoading = false
        }
    }

    private func refreshData() {
        isLoading = true
        cells = []
        loadInitialData()
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
