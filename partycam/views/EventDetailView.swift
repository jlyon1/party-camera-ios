import Foundation
import SwiftUI

struct EventDetailView: View {
    let event: Event
    let backend: BackendManager

    @State private var fetchedEvent: Event? = nil
    @State private var fetchError: String? = nil
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading) {
            FeedView()
            
        }
        .navigationTitle(event.name)
        .hideTabBar()
        .task {
            await loadEvent()
        }
    }

    func loadEvent() async {
        isLoading = true
        fetchError = nil
        do {
            fetchedEvent = try await backend.fetchEvent(id: event.id)
        } catch {
            fetchError = error.localizedDescription
        }
        isLoading = false
    }
}
