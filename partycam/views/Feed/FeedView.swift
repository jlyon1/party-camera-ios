import Foundation
import NukeUI
import SwiftUI

struct FeedView: View {
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isShowingQrCode: Bool = false
    @EnvironmentObject private var galleryAndFeedDataModel:
        GalleryAndFeedDataModel

    let eventId: Int
    let backendManager: BackendManager
    let name: String

    private var feed: EventFeed? {
        galleryAndFeedDataModel.eventFeedsDict[eventId]
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        let spacing: CGFloat = 2
        let columnsCount = columns.count
        let totalSpacing = spacing * CGFloat(columnsCount - 1)
        let screenWidth = UIScreen.main.bounds.width
        let imageSize =
            (screenWidth - totalSpacing - 32) / CGFloat(columnsCount)
        //        if let qrImage = galleryAndFeedDataModel.generateQRCode(from: ...) {
        //            Image(uiImage: qrImage)
        //                .interpolation(.none)
        //                .resizable()
        //                .scaledToFit()
        //                .frame(width: 200, height: 200)
        //                .padding()
        //        }

        return ZStack(alignment: .bottomTrailing) {
            ScrollView {
                Text("ID \(eventId): \(name)")
                Text("Length \(feed?.feedItems.count ?? 0)")

                Button("Manual Refresh") {
                    Task {
                        do {
                            try await galleryAndFeedDataModel.fetchEventFeed(
                                id: eventId,
                                overwrite: true
                            )
                            isLoading = false
                        } catch {
                            errorMessage = error.localizedDescription
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

                        Text("Your Photos:")
                            .font(.caption)
                            .foregroundColor(.gray)

                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(
                                feed.feedItems.filter {
                                    $0.ownerId == galleryAndFeedDataModel.userId
                                },
                                id: \.id
                            ) { item in
                                NavigationLink(
                                    destination: GalleryImageView(
                                        imageId: item.id,
                                        backend: backendManager
                                    )
                                ) {
                                    LazyImage(
                                        url: URL(string: item.presignedUrl)
                                    ) { state in
                                        if let image = state.image {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(
                                                    width: imageSize,
                                                    height: imageSize
                                                )
                                                .clipped()
                                        } else {
                                            Color.gray
                                                .frame(
                                                    width: imageSize,
                                                    height: imageSize
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        Text("Everyone's Photos:")
                            .font(.caption)
                            .foregroundColor(.gray)

                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(
                                feed.feedItems.filter {
                                    $0.ownerId != galleryAndFeedDataModel.userId
                                },
                                id: \.id
                            ) { item in
                                NavigationLink(
                                    destination: GalleryImageView(
                                        imageId: item.id,
                                        backend: backendManager
                                    )
                                ) {
                                    LazyImage(
                                        url: URL(string: item.presignedUrl)
                                    ) { state in
                                        if let image = state.image {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(
                                                    width: imageSize,
                                                    height: imageSize
                                                )
                                                .clipped()
                                        } else {
                                            Color.gray
                                                .frame(
                                                    width: imageSize,
                                                    height: imageSize
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }

            // Uncomment to enable camera button
            /*
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
            */
        }
        .navigationTitle(name)
        .hideTabBar()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingQrCode = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .task {
            do {
                try await galleryAndFeedDataModel.fetchSession()
                try await galleryAndFeedDataModel.fetchEventFeed(id: eventId)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
            }
        }.sheet(isPresented: $isShowingQrCode) {
            VStack {
                Text("Scan QR Code to Join Event")
                    .font(.headline)
                Text("Anyone with this code can join the event")
                    .font(.caption)

                Image(
                    uiImage: galleryAndFeedDataModel.generateQRCode(
                        from:
                            "event://\(eventId)&name=\(name)&description=\(feed?.description ?? "")"
                    )
                )
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding()

                //              TODO: More Styles
            }
        }
        // Uncomment to enable pull-to-refresh
        /*
        .refreshable {
            try? await Task.sleep(nanoseconds:   400_000_000)
            do {
                try await galleryAndFeedDataModel.fetchEventFeed(id: eventId, overwrite: true)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        */
        // Uncomment to enable camera sheet
        /*
        .sheet(isPresented: $isShowingCamera) {
            CameraView(backend: backendManager, model: model)
        }
        */
    }
}
