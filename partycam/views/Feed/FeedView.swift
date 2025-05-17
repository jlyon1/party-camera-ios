import Foundation
import SwiftUI

struct FeedView: View {
    @State private var feed: EventFeed?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isShowingCamera = false  // New state for camera view

    let eventId: Int
    let backendManager: BackendManager
        
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

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

                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(feed.feedItems, id: \.id) { item in
                                AsyncImage(url: URL(string: item.presignedUrl)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(height: 150)
                                .clipped()
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // Floating "+" button
            Button(action: {
                isShowingCamera = true
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
            .accessibilityLabel("Add photo or video")
        }
        .onAppear {
            Task {
                do {
                    self.feed = try await backendManager.fetchEventFeed(id: eventId)
                    self.isLoading = false
                } catch {
                    self.errorMessage = "\(error)"
                    self.isLoading = false
                }
            }
        }
        .sheet(isPresented: $isShowingCamera) {
//            CameraView() // Replace with your camera view implementation
        }
    }
}
