//
//  TabBarVisibility.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation
import UIKit
import SwiftUI

class TabBarVisibilityManager: ObservableObject {
    static let shared = TabBarVisibilityManager()

    @Published var isHidden: Bool = false {
        didSet {
            updateTabBarVisibility()
        }
    }

    private func updateTabBarVisibility() {
        DispatchQueue.main.async {
            if let tabBar = UIApplication.shared.windows.first?.rootViewController?.children
                .compactMap({ $0 as? UITabBarController }).first?.tabBar {
                tabBar.isHidden = self.isHidden
            }
        }
    }
}

struct HideTabBarModifier: ViewModifier {
    @ObservedObject private var manager = TabBarVisibilityManager.shared

    func body(content: Content) -> some View {
        content
            .onAppear {
                manager.isHidden = true
            }
    }
}

struct ShowTabBarModifier: ViewModifier {
    @ObservedObject private var manager = TabBarVisibilityManager.shared

    func body(content: Content) -> some View {
        content
            .onAppear {
                manager.isHidden = false
            }
    }
}


extension View {
    func hideTabBar() -> some View {
        self.modifier(HideTabBarModifier())
    }
    
    func showTabBar() -> some View {
        self.modifier(ShowTabBarModifier())
    }
}

struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBarController?) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            self.callback(vc.tabBarController)
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
