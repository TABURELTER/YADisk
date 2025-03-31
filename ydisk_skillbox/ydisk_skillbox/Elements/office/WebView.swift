//
//  WebView.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 30.03.2025.
//


import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let path:String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let officeURLString = "https://disk.yandex.ru/edit/disk/\(DataManager.shared.formatePath(path))"
        if let officeURL = URL(string: officeURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            let request = URLRequest(url: officeURL)
            webView.load(request)
        }
    }
}


#Preview{
//    struct ContentView: View {
//        var body: some View {
            NavigationView {
                WebView(path:  "https://softonit.ru/upload/price_1c.xls") 
                    .navigationTitle("Просмотр файла")
                    .navigationBarTitleDisplayMode(.inline)
            }
//        }
//    }

}
