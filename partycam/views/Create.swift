import SwiftUI

struct Create: View {
    @EnvironmentObject private var galleryAndFeedDataModel: GalleryAndFeedDataModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
    
    @State private var isCreating = false
    @State private var message = ""
    @State private var hideImages = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    PartyTextInput(text: $name, placeholder: "Name")
                    
                    TextField("Description", text: $description)
                        .textFieldStyle(.roundedBorder)
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                    
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                    
                    Toggle("Hide images before the event ends", isOn: $hideImages)
                        .toggleStyle(.switch)
                    
                    if isCreating {
                        ProgressView()
                    }
                    
                    Button("Create Event") {
                        Task {
                            await createEvent()
                        }
                    }
                    .disabled(isCreating || name.isEmpty || description.isEmpty)
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
            let formatter = ISO8601DateFormatter()
            let startDateString = formatter.string(from: startDate)
            let endDateString = formatter.string(from: endDate)
            
            try await galleryAndFeedDataModel.createEvent(
                name: name,
                description: description,
                startDate: startDateString,
                endDate: endDateString,
                blur: hideImages
            )
            message = "Event created successfully!"
            name = ""
            description = ""
            startDate = Date()
            endDate = Date()
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
