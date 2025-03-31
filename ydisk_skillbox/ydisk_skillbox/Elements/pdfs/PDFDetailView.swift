//
//  PDFViewer.swift
//  WebReadingListApp
//
//  Created by Karin Prater on 17/11/2024.
//

import SwiftUI

struct PDFDetailView: View {
    
    let fileURL: URL
    @Bindable var pdfViewModel: PDFViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        PDFViewWrapper(fileURL: fileURL)
            .toolbar {
                Button {
                    pdfViewModel.delete(fileURL)
                    dismiss()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                ShareLink(item: fileURL)
            }
            .navigationTitle(fileURL.lastPathComponent)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PDFDetailView(fileURL: URL(string: "//Users/karinprater/Library/Developer/CoreSimulator/Devices/880EFCD5-0829-47B3-BC5C-F01FD7CC6CC2/data/Containers/Data/Application/82F27C43-1362-4C17-927A-60B13AC26C8A/Documents/title.pdf")!,
                      pdfViewModel: PDFViewModel())
    }
}
///Users/tab/Library/Developer/CoreSimulator/Devices/2500CB68-B428-4A66-A82A-09F9A76EE408/data/Containers/Data/Application/8170B6C5-AE25-4764-B8F3-33E9EC89ED83/Documents/2.pdf
