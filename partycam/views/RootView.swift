//
//  RootView.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation
import SwiftUI

import SwiftUI

struct CameraViewRep: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraController

    var controller: CameraController

    func makeUIViewController(context: Context) -> CameraController {
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraController, context: Context) {
        // No update logic for now
    }

    // Optional: expose a method to take a photo from SwiftUI
    func takePhoto(completion: @escaping (CameraController.Photo) -> Void) {
        print("PHOTO!")
        controller.takePhoto(completion)
    }
}

struct RootView: View {
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var galleryAndFeedDataModel: GalleryAndFeedDataModel

    @State private var photo: CameraController.Photo?
    @State private var showSheet = false
    @StateObject private var controller = CameraController()

    var body: some View {
        VStack {
            CameraViewRep(controller: controller)

            Button("Take Photo") {

                controller.takePhoto { capturedPhoto in
                    photo = capturedPhoto
                    print(photo?.image()?.size)
                    showSheet = true

                }
                
            }

        }.sheet(isPresented: $showSheet) {
            if let uiImage = photo?.image() {
                VStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    
                    Button("Close") {
                        showSheet = false
                    }
                    .padding()
                }
            } else {
                Text("No image available")
            }
        }
        
//        Group {
//            if session.isLoggedIn {
//                TabView(){
//                    Create().environmentObject(galleryAndFeedDataModel).tabItem { Image(systemName: "plus") }
//                    Gallery(backend: LiveBackendManager()).environmentObject(galleryAndFeedDataModel).tabItem { Image(systemName: "camera") }
//                    Settings(backend: LiveBackendManager()).tabItem { Image(systemName: "gear") }
//                }
//                
//            } else {
//                LoginView()
//            }
//        }
    }
}
