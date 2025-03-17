//
//  UI.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 01.03.2025.
//



//@ViewBuilder
//private var loginFields: some View{
//    VStack(alignment: .leading, spacing: 20){
//        TextField("Логин", text: $login)
//            .textFieldStyle(.roundedBorder)
//            .tint(.uIblue)
//            .overlay{
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(.uIblue, lineWidth: 2)
//            }
//        
//        
//        SecureField("Пароль" , text: $password)
//            .textFieldStyle(.roundedBorder)
//            .tint(.uIblue)
//            .overlay{
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(.uIblue, lineWidth: 2)
//            }
//    }.frame(width: 325)
//}
//
//@ViewBuilder
//private var loginButton: some View{
//    Button(action: {
//        if login.count > 0 && password.count > 0{
//            isAuthed = true
//            username = login
//        }
//    }) {
//        Label("Войти", systemImage: "arrow.up")
//            .frame(width: UIScreen.main.bounds.width - 80, height: 40)
//    }
//    .buttonStyle(.borderedProminent)
//    .buttonBorderShape(.roundedRectangle)
//    .tint(.uIblue)
//    .offset(y: -15)
////                    .opacity(launchScreenState.state == .secondStep ? 1 : 0)
////                    .animation(.easeInOut(duration: 0.3).delay(1.3), value: launchScreenState.state == .secondStep)
////        .disabled((launchScreenState.state != .secondStep) )
//    .contextMenu{
////            if isSimulator{
//            Menu {
//                Button {
//                    isFirstLaunch.toggle()
//                    print("Toggle FirstLaunch to \(isFirstLaunch)")
//                } label: {
//                    Label("Toggle FirstLaunch", systemImage: isFirstLaunch ? "checkmark.circle" : "xmark.circle")
//                }
//                Button(role: .destructive) {
//                    print("RESTART UI")
//                    appState.isRestarted.toggle()
//                } label: {
//                    Label("RESTART UI", systemImage: "arrow.trianglehead.clockwise")
//                }
//            } label: {
//                Label("Debug Menu", systemImage: "desktopcomputer.trianglebadge.exclamationmark")
//            }
////            }
//    }
//}
