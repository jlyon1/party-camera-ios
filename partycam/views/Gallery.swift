import Foundation
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
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()        // fills entire frame, may overflow
                        .frame(height: 260)    // fixed height for image area
                        .frame(maxWidth: .infinity)
                        .clipped()             // crop overflow
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                @unknown default:
                    EmptyView()
                }
            }
            cardText
                .padding(.horizontal, 10)
                .padding(.top, 8)
        }
        .frame(width: 280, height: 320)      // fixed size card
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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Subtitle below the title
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
                                CardView(
                                    imageUrl: event.imageURL,
                                    title: event.name,
                                    subtitle: event.startTimeFormatted
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .padding()
            }
            .navigationTitle("Your Events") // stays at the top
        }
        .onAppear {
            fetchEvents()
        }
    }

    func fetchEvents() {
        backend.fetchEvents { result in
            switch result {
            case .success(let loadedEvents):
                events = loadedEvents
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}


#Preview {
    Gallery(backend: LiveBackendManager())
}
