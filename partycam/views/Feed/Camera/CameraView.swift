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

struct CameraView: View {
    let backend: BackendManager
    @ObservedObject private var model: DataModel
    @State private var showFeedView = false
    @EnvironmentObject private var galleryAndFeedDataModel: GalleryAndFeedDataModel
    @State private var photoTaken = false
    
    @State private var capturedImage: Image? = nil
    @State private var showCapturedOverlay = false
    @State private var overlayOffset: CGFloat = 0
    @State private var overlayScale: CGFloat = 0.1  // New state for scale
    @State private var showFlash = false
    
    @StateObject private var controller = CameraController()
    @State private var photo: CameraController.Photo?
 
    private static let barHeightFactor = 0.15
    
    init(backend: BackendManager, model: DataModel) {
        self.backend = backend
        self.model = model
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                CameraViewRep(controller: controller)
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
                if showCapturedOverlay {
                    capturedImage!
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(overlayScale)   // <-- apply scale here
                        .clipped()
                        .offset(y: overlayOffset)
//                        .animation(.easeOut(duration: 0.1), value: overlayOffset)
                }
                if showFlash {
                    Color.white
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(10) // make sure it's on top
                }
            }

        }
//        .task {
//            await model.camera.start()
//            await model.loadPhotos()
//            await model.loadThumbnail()
//        }
//        .navigationTitle(model.eventName)
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
                flash()
                controller.takePhoto{ result in
                    if let uiImage = result.image() {
                        
                        capturedImage = Image(uiImage: uiImage)
//                        showPhotoOverlay()
                        self.model.enqueuePhotoForUpload((result.image()?.jpegData(compressionQuality: 100))!)

                    } else {
                        // Handle nil case if needed
                        print("Failed to get UIImage from result")
                    }
                }
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
                if controller.camera == CameraController.Camera.back {
                    controller.setCamera(CameraController.Camera.front)
                }else{
                    controller.setCamera(CameraController.Camera.back)
                }
                
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
    private func flash(){
        showFlash = true

        // Hide flash quickly after 0.15s (adjust timing as needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                showFlash = false
            }
        }
        
    }
    
    private func showPhotoOverlay() {
        guard capturedImage != nil else { return }

        overlayOffset = 0
        overlayScale = 0.4    // reset scale to normal
        showCapturedOverlay = true
        
        // Slide up after a short delay
        withAnimation(.easeOut(duration: 0.2).delay(0)) {
            overlayOffset = -UIScreen.main.bounds.height
            overlayScale = 1   // shrink to 30% size
        }

        // Remove after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showCapturedOverlay = false
            capturedImage = nil
        }
    }
    
}
