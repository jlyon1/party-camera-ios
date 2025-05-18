import Foundation
import NukeUI
import SwiftUI


struct FeedView: View {
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isShowingCamera = false  // New state for camera view
    @EnvironmentObject private var galleryAndFeedDataModel: GalleryAndFeedDataModel
    
    // get the feed from galleryAndFeedDataModel
    private var feed: EventFeed? {
        galleryAndFeedDataModel.eventFeedsDict[eventId]
    }
    
    init(eventId: Int, backendManager: BackendManager, name: String) {
        self.eventId = eventId
        self.backendManager = backendManager
        self.name = name
    }

    
    let eventId: Int
    let backendManager: BackendManager
    let name: String
        
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let imageSize: CGFloat = 150 // Adjust as needed for your design

    var body: some View {
        let spacing: CGFloat = 2
        let columnsCount = columns.count
        let totalSpacing = spacing * CGFloat(columnsCount - 1)
        // Calculate image size based on screen width minus horizontal padding (32)
        let screenWidth = UIScreen.main.bounds.width
        let imageSize = (screenWidth - totalSpacing - 32) / CGFloat(columnsCount)
        
        return ZStack(alignment: .bottomTrailing) {
            ScrollView {
                Text("ID \(eventId): \(name)")
                Text("Length \(feed?.feedItems.count ?? 0)")
                Button("Manual Refresh") {
                    Task {
                        do{
                            try await galleryAndFeedDataModel.fetchEventFeed(id: eventId, overwrite: true)
                            isLoading = false
                        } catch {
                            errorMessage = error.localizedDescription // TODO needs to be real error handling
                        }
                    }
                }
                if isLoading {
                    ProgressView("Loading Feed...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if let feed = feed {
                    VStack(alignment: .leading) {
                        Text(feed.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding([.horizontal, .bottom])

                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(feed.feedItems, id: \.id) { item in
                                NavigationLink(destination: GalleryImageView(imageId: item.id, backend: backendManager)) {
                                    LazyImage(url: URL(string: item.presignedUrl)) { state in
                                        if let image = state.image {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: imageSize, height: imageSize)
                                                .clipped()
                                        } else {
                                            Color.gray
                                                .frame(width: imageSize, height: imageSize)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
//            Button(action: {
//                isShowingCamera = true
//            }) {
//                Image(systemName: "plus")
//                    .font(.system(size: 24))
//                    .foregroundColor(.white)
//                    .frame(width: 60, height: 60)
//                    .background(Color.blue)
//                    .clipShape(Circle())
//                    .shadow(radius: 4)
//                    .padding()
//            }
            .navigationTitle(name)
            .hideTabBar()
        }
//        .refreshable {
//            try? await Task.sleep(nanoseconds: 400_000_000) // 0.2 sec debounce
//            do{
//                try await galleryAndFeedDataModel.fetchEventFeed(id: eventId, overwrite: true)
//                isLoading = false
//            } catch {
//                errorMessage = error.localizedDescription // TODO needs to be real error handling
//            }
//        }
        .task {
            do{
                try await galleryAndFeedDataModel.fetchEventFeed(id: eventId)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription // TODO needs to be real error handling
            }
        }
//        .sheet(isPresented: $isShowingCamera) {
//            CameraView(backend: backendManager, model: model)
//        }
    }
    
    func refreshFeed(force: Bool) async {
//        do {
//            if force || feed == nil {
//                // Avoid changing feed here before the await call
//                let newFeed = try await backendManager.fetchEventFeed(id: eventId)
//                // Now update state on the main thread after await finishes
//                await MainActor.run {
//                    feed = newFeed
//                    isLoading = false
//                }
//            }
//        } catch {
//            await MainActor.run {
//                if let urlError = error as? URLError, urlError.code == .cancelled {
//                    print("Fetch cancelled - ignoring")
//                } else {
//                    errorMessage = "\(error)"
//                    isLoading = false
//                }
//            }
//        }
    }

}
