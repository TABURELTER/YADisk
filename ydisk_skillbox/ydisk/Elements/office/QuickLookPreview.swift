//
//  QuickLookPreview.swift
//  idk yadisk
//
//  Created by Дмитрий Богданов on 30.03.2025.
//

import SwiftUI
import QuickLook


struct QuickLookPreview: UIViewControllerRepresentable {
    var fileURL: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: QuickLookPreview

        init(_ parent: QuickLookPreview) {
            self.parent = parent
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.fileURL as QLPreviewItem
        }
    }
}

struct OfficeView: View {
    @State private var showPreview = false
    @State private var downloadedFileURL: URL?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State var showShareOptions = false
    @State var showAlert = false

//    let remoteFileURL: URL
    let item: cell
    @State private var wrapper: Wrapper?

    var body: some View {
        ZStack{
            VStack {
                if isLoading {
                    ProgressView("Загрузка файла...")
                }
                
                if let errorMessage {
                    Text("Ошибка: \(errorMessage)")
                        .foregroundColor(.red)
                }
            }
            if let downloadedFileURL {
                QuickLookPreview(fileURL: downloadedFileURL)
            }
        }
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
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            downloadFile(from: URL(string: item.file ?? "")!)
        }
    }

    /// Скачивает файл по указанному URL
    func downloadFile(from url: URL) {
        isLoading = true
        errorMessage = nil

        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }

                guard let localURL = localURL else {
                    errorMessage = "Не удалось загрузить файл."
                    return
                }

                // Перемещаем файл во временную директорию
                let tempDirectory = FileManager.default.temporaryDirectory
                let destinationURL = tempDirectory.appendingPathComponent("document.docx")

                do {
                    if FileManager.default.fileExists(atPath: destinationURL.path) {
                        try FileManager.default.removeItem(at: destinationURL)
                    }
                    try FileManager.default.moveItem(at: localURL, to: destinationURL)
                    downloadedFileURL = destinationURL
                    showPreview = true
                } catch {
                    errorMessage = "Ошибка при сохранении файла: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
            }

}


//#Preview(){
//    OfficeView(remoteFileURL: URL(string:"https://downloader.disk.yandex.ru/disk/455d0efcea7ca7d0031a66e59f2e0c718c52793c19319c34b05b1ffee1d5b194/67e9e2e1/DPhZJKiI4dWvKww5NeSXJ_yjIqSVgUjOobTaglFLO-ChhNLp21Df4wGTVz6RqKKX0UMF-LFyFCaVCXnH_wfRvg%3D%3D?uid=461394823&filename=12.docx&disposition=attachment&hash=&limit=0&content_type=application%2Fvnd.openxmlformats-officedocument.wordprocessingml.document&owner_uid=461394823&fsize=16076&hid=eba340cc1f55765b136be496942c8242&media_type=document&tknv=v2&etag=3d1e672aef8462e6bb30bfbde675ec45")!)
//}
