import Foundation
import NukeUI
import SwiftUI


struct CardView: View {
    @Environment(\.colorScheme) var colorScheme

    let imageUrl: URL
    let title: String
    let subtitle: String

    var cardText: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            HStack(spacing: 2) {
                Image(systemName: "clock")
                Text(subtitle)
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 16)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LazyImage(url: imageUrl) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()        // fills entire frame, may overflow
                        .frame(height: 200)    // fixed height for image area
                        .frame(maxWidth: 220)
                        .clipped()             // crop overflow
                }
            }
            cardText
                .padding(.horizontal, 10)
                .padding(.top, 8)
        }
        .frame(width: 220, height: 250)      // fixed size card
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(
            color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2),
            radius: 8, x: 0, y: 4
        )
    }
}

struct Gallery: View {
    let backend: BackendManager
    
    @State private var events: [Event] = []
    @State private var errorMessage: String?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Click to view")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(events) { event in
                                Button {
                                    path.append(event)
                                } label: {
                                    CardView(
                                        imageUrl: event.imageURL,
                                        title: event.name,
                                        subtitle: event.startTimeFormatted
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .padding()
            }
            .navigationTitle("Your Events")
            .navigationDestination(for: Event.self) { event in
                FeedView(eventId: event.id, backendManager: backend, name: event.name)
            }
            .refreshable {
                await fetchEvents()
            }
        }
        .task {
            await fetchEvents()
        }
    }


    func fetchEvents() async {
        do {
            let loadedEvents = try await backend.fetchEvents()
            events = loadedEvents
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}


#Preview {
    Gallery(backend: LiveBackendManager())
}
