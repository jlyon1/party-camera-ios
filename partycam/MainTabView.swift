//
//  MainTabView.swift
//  partycam
//
//  Created by Joey Lyon on 5/9/25.
//

import Foundation
import SwiftUI

enum Tab {
    case camera, gallery, settings
}

let tabBarBackgroundColor = Color(UIColor.systemGray6)
let selectedTabColor = Color.blue

struct MainTabView: View {
    @State private var selectedTab: Tab = .camera

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .camera: ContentView(text: "Camera")
                case .gallery: ContentView(text: "Gallery")
                case .settings: LoginView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 60) // space for tab bar

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard) // Optional, in case keyboard appears in gallery/settings
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            tabButton(tab: .camera, icon: "camera")
            tabButton(tab: .gallery, icon: "photo.on.rectangle")
            tabButton(tab: .settings, icon: "gear")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(tabBarBackgroundColor.ignoresSafeArea(edges: .bottom))
        .overlay(
            Rectangle().frame(height: 0.5).foregroundColor(.gray), alignment: .top
        )
    }
    private func tabButton(tab: Tab, icon: String) -> some View {
        Button(action: {
            if selectedTab != tab {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()

                // Apply the animation directly here to change selectedTab
                withAnimation(.easeInOut(duration: 0.01)) {
                    selectedTab = tab
                }
            }
        }) {
            ZStack {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedTabColor.opacity(0.2))
                        .frame(height: 60) // Increase height
                        .padding(.horizontal, 8)
                        .transition(.move(edge: .trailing)) // Slight move effect
                }

                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22) // Adjust icon size to match tab height
                    .foregroundColor(selectedTab == tab ? selectedTabColor : .gray)
            }
            .frame(maxWidth: .infinity, minHeight: 60) // Increase minHeight here
        }
    }
}
