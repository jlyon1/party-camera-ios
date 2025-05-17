import Foundation
import NukeUI
import SwiftUI


struct FeedView: View {
    @State private var feed: EventFeed?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isShowingCamera = false  // New state for camera view

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
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
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

                        GeometryReader { geometry in
                            let spacing: CGFloat = 2
                            let columnsCount = columns.count
                            let totalSpacing = spacing * CGFloat(columnsCount - 1)
                            let imageSize = (geometry.size.width - totalSpacing - 32) / CGFloat(columnsCount) // 32 accounts for .horizontal padding

                            LazyVGrid(columns: columns, spacing: spacing) {
                                ForEach(feed.feedItems, id: \.id) { item in
                                    NavigationLink(destination: GalleryImageView(imageId: item.id, backend: backendManager)) {
                                        LazyImage(url: URL(string: item.presignedUrl)){ state in
                                            if let image = state.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: imageSize, height: imageSize)
                                                    .clipped()
                                            }
                                        }

                                    }
                                    
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(minHeight: 0, maxHeight: .infinity) // Let GeometryReader size naturally
                    }
                }
            }

            // Floating "+" button
            Button(action: {
                if let url = URL(string: "\(backendUrl)/user/\(eventId)"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
                
//                isShowingCamera = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                    .padding()
            }
//            .accessibilityLabel("Add photo or video")
            .navigationTitle(name)
            .hideTabBar()
        }
        .task {
            
            do {
                if feed == nil {
                    self.feed = try await backendManager.fetchEventFeed(id: eventId)
                    self.isLoading = false
                }
            } catch {
                self.errorMessage = "\(error)"
                self.isLoading = false
            }
            
        }
//        .sheet(isPresented: $isShowingCamera) {
////            CameraView() // Replace with your camera view implementation
//        }
    }
}
