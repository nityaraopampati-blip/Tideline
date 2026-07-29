import SwiftUI

struct CreateEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (CleanupEvent) -> Void

    @State private var name = ""
    @State private var location = ""
    @State private var type: CleanupEventType = .beachCleanup
    @State private var date = Date()
    @State private var notes = ""

    private var canPublish: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    field(label: "Event Name") {
                        TextField("e.g. Sunset Beach sweep", text: $name)
                    }
                    field(label: "Location") {
                        TextField("e.g. Sunset Beach", text: $location)
                    }
                    field(label: "Type") {
                        Picker("Type", selection: $type) {
                            ForEach(CleanupEventType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    field(label: "Date") {
                        DatePicker("", selection: $date, in: Date()..., displayedComponents: .date)
                            .labelsHidden()
                    }
                    field(label: "Extra Details (optional)") {
                        TextField("e.g. Bring gloves and a reusable water bottle", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Button("Publish Event") {
                        let event = CleanupEvent(name: name, location: location, type: type, date: date, notes: notes)
                        onSave(event)
                        dismiss()
                    }
                    .buttonStyle(TideCTAButtonStyle(tint: TideTheme.tide))
                    .disabled(!canPublish)
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .background(TideTheme.background.ignoresSafeArea())
            .navigationTitle("Create Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func field<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.3)
                .foregroundStyle(TideTheme.inkSoft)
            content()
                .padding(12)
                .background(Color(.systemBackground))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(TideTheme.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

#Preview {
    CreateEventSheet(onSave: { _ in })
}
