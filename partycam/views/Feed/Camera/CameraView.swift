/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct CameraWrapper: View {
    @StateObject private var model: DataModel
    let backendManager: BackendManager
    
    init(model: DataModel, backendManager: BackendManager) {
        _model = StateObject(wrappedValue: model)
        self.backendManager = backendManager
        
    }
    
    var body: some View {
        CameraView(backend: backendManager, model: model)
    }
}

struct CameraView: View {
    let backend: BackendManager
    @ObservedObject private var model: DataModel
    @State private var showFeedView = false
    @EnvironmentObject private var galleryAndFeedDataModel: GalleryAndFeedDataModel
    @State private var photoTaken = false
    
    @State private var capturedImage: Image? = nil
    @State private var showCapturedOverlay = false
    @State private var overlayOffset: CGFloat = 0
 
    private static let barHeightFactor = 0.15
    
    init(backend: BackendManager, model: DataModel) {
        self.backend = backend
        self.model = model
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                if showCapturedOverlay, let image = capturedImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .offset(y: overlayOffset)
                        .transition(.move(edge: .bottom))
                }else{
                    ViewfinderView(image: model.viewfinderImage )
                        .overlay(alignment: .top) {
                            Color.black
                                .opacity(0.75)
                                .frame(height: geometry.size.height * Self.barHeightFactor)
                        }
                        .overlay(alignment: .bottom) {
                            buttonsView()
                                .frame(height: geometry.size.height * Self.barHeightFactor)
                                .background(.black.opacity(0.75))
                        }
                        .overlay(alignment: .center)  {
                            Color.clear
                                .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                                .accessibilityElement()
                                .accessibilityLabel("View Finder")
                                .accessibilityAddTraits([.isImage])
                        }
                        .background(.black)
                }
                
            }

        }
        .task {
            await model.camera.start()
            await model.loadPhotos()
            await model.loadThumbnail()
        }
        .navigationTitle(model.eventName)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .navigationDestination(isPresented: $showFeedView) {
            FeedView(eventId: model.eventId, backendManager: backend, name: model.eventName).environmentObject(galleryAndFeedDataModel)
        }
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            Spacer()
            Button {
                showFeedView = true
            } label: {
                Label("Thumbnails Camera", systemImage: "rectangle.grid.2x2")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(.white)
            }
            
            Button {
                // TODO, can we add a completion here?
                model.camera.takePhoto()
                capturedImage = model.viewfinderImage
                showPhotoOverlay()
            } label: {
                Label {
                    Text("Take Photo")
                } icon: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 62, height: 62)
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            

            
            Button {
                model.camera.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(.white)
            }
            Spacer()
        
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
    private func showPhotoOverlay() {
        guard capturedImage != nil else { return }
        overlayOffset = 0
        showCapturedOverlay = true

        // Slide up after a short delay
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            overlayOffset = -UIScreen.main.bounds.height
        }

        // Remove after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showCapturedOverlay = false
            capturedImage = nil
        }
    }
    
}
