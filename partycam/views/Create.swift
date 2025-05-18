import SwiftUI

struct Create: View {
    @EnvironmentObject private var galleryAndFeedDataModel: GalleryAndFeedDataModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var startDate = ""
    @State private var endDate = ""
    
    @State private var isCreating = false
    @State private var message = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Description", text: $description)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Start Date (e.g. 2025-05-18)", text: $startDate)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("End Date (e.g. 2025-05-20)", text: $endDate)
                        .textFieldStyle(.roundedBorder)
                    
                    if isCreating {
                        ProgressView()
                    }
                    
                    Button("Create Event") {
                        Task {
                            await createEvent()
                        }
                    }
                    .disabled(isCreating || name.isEmpty || description.isEmpty || startDate.isEmpty || endDate.isEmpty)
                    .buttonStyle(.borderedProminent)
                    
                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(message.contains("success") ? .green : .red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            .navigationTitle("Create Event")
        }
    }
    
    func createEvent() async {
        isCreating = true
        message = ""
        do {
            // Call your backend manager method via the data model
            try await galleryAndFeedDataModel.createEvent(
                name: name,
                description: description,
                startDate: startDate,
                endDate: endDate
            )
            message = "Event created successfully!"
            name = ""
            description = ""
            startDate = ""
            endDate = ""
        } catch {
            message = "Failed to create event: \(error.localizedDescription)"
        }
        isCreating = false
    }
}

#Preview {
    Create()
        .environmentObject(GalleryAndFeedDataModel())
}
