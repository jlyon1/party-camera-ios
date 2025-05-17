import Foundation
import SwiftUI

// TODO UNUSED
struct EventDetailView: View {
    let event: Event
    let backend: BackendManager

    @State private var fetchedEvent: Event? = nil
    @State private var fetchError: String? = nil
    @State private var isLoading = false

    var body: some View {
        VStack(alignment: .leading) {
            
            
        }
        .navigationTitle(event.name)
        .hideTabBar()
    }

}
