//
//  renameOverlay.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 19.03.2025.
//

import SwiftUI

struct renameOverlay: View {
    @State var presentAlert = false
    @State var item: cell

    let onDismiss: ((String) -> Void)?
    
    var body: some View {
        VStack{
            Spacer()
            TextField("", text: .constant(""))
            Spacer()
        }
        
        .background{
            Color.clear.blur(radius: 10,opaque: false)
        }
    }
}

#Preview {
//    renameOverlay(){value in
//    }
}
