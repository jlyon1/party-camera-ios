//
//  RootView.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation
import SwiftUI

import SwiftUI


struct RootView: View {
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var galleryAndFeedDataModel: GalleryAndFeedDataModel

    
    @State private var showSheet = false


    var body: some View {
        Group {
            if session.isLoggedIn {
                TabView(){
                    Create().environmentObject(galleryAndFeedDataModel).tabItem { Image(systemName: "plus") }
                    Gallery(backend: LiveBackendManager()).environmentObject(galleryAndFeedDataModel).tabItem { Image(systemName: "camera") }
                    Settings(backend: LiveBackendManager()).tabItem { Image(systemName: "gear") }
                }
                
            } else {
                LoginView()
            }
        }
    }
}
