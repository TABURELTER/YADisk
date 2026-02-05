//
//  PublicList.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 31.03.2025.
//

import SwiftUI

struct PublicList: View {
    @State var q: [CustomCell] = []
    var body: some View {
        Text("Hello, World!")
 
            .onAppear {
                DataManager.shared.GetPublicCells(path: "", offset: 0){i in
                    i.items.forEach{print($0)}
//                    cell(isFolder: false, name: <#T##String#>, path: <#T##String#>, icon: <#T##Image?#>, dateCreate: <#T##Date#>, size: <#T##String#>, sizes: <#T##[Size]?#>, file: <#T##String?#>, MD5: <#T##String?#>)
//                    CustomCell(item: i.items[0])
                    
                    
                }
                
            }
    }
    
}

#Preview {
    PublicList()
}
