import SwiftUI
import NukeUI

struct GalleryImageView: View {
    let imageId: String
    let backend: BackendManager

    @State private var errorMessage: String?
    @State private var imageAssets: ImageWithAssets?
    @State private var loaded: Bool = false

    var thumbnailAsset: ImageAsset? {
        imageAssets?.assets.first(where: { $0.size == "thumbnail" })
    }
    @State private var zoomScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if let asset = thumbnailAsset, loaded {
//                TODO: How do I keep this loaded
                LazyImage(url: URL(string: asset.url)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .transition(.opacity)
                            .scaleEffect(zoomScale)
                            .gesture(MagnificationGesture()
                                .onChanged { value in zoomScale = value }
                                .onEnded { _ in withAnimation { zoomScale = max(1.0, zoomScale) } })
                    }
                }
            } else if let errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.white)
                    .padding()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await getImageAssets()
        }
    }

    func getImageAssets() async {
        do {
            imageAssets = try await backend.fetchImageAssets(id: imageId)
            loaded = true
        } catch {
            errorMessage = error.localizedDescription
            loaded = false
        }
    }
}
