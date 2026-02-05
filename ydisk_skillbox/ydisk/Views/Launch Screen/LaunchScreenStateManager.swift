//
//  LaunchScreenStateManager.swift
//  ydisk_skillbox
//
//  Created by Дмитрий Богданов on 17.02.2025.
//

import Foundation
final class LaunchScreenStateManager: ObservableObject {

@MainActor @Published private(set) var state: LaunchScreenStep = .firstStep

    @MainActor func dismiss() {
        Task {
            state = .secondStep

//            try? await Task.sleep(for: Duration.seconds(1))

//            self.state = .finished
        }
    }
}
enum LaunchScreenStep {
    case firstStep
    case secondStep
    case finished
}

let isSimulator: Bool = {
    #if targetEnvironment(simulator)
    return true // Выполняется в симуляторе
    #else
    return false // Выполняется на реальном устройстве
    #endif
}()
