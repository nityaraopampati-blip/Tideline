import SwiftUI

struct CreateEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (CleanupEvent) -> Void

    @State private var name = ""
    @State private var location = ""
    @State private var type: CleanupEventType = .beachCleanup
    @State private var day = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(2 * 3600)
    @State private var notes = ""
    @State private var errorMessage: String?

    private var canPublish: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .top, spacing: 10) {
                        Text("📍").font(.system(size: 15))
                        Text("This publishes to your device only — after creating it, use the share button to invite people. It won't show up for them on its own.")
                            .font(.system(size: 11.5))
                            .foregroundStyle(Color(hex: 0x0D3A32))
                    }
                    .padding(11)
                    .background(TideTheme.seafoamLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

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
                        DatePicker("", selection: $day, in: Date()..., displayedComponents: .date)
                            .labelsHidden()
                    }

                    HStack(spacing: 12) {
                        field(label: "Start Time") {
                            DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        field(label: "End Time") {
                            DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 11.5))
                            .foregroundStyle(TideTheme.coral)
                    }

                    field(label: "Extra Details (optional)") {
                        TextField("e.g. Bring gloves and a reusable water bottle", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    Button("Publish Event") {
                        publish()
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

    private func publish() {
        let start = combine(day: day, time: startTime)
        let end = combine(day: day, time: endTime)
        guard end > start else {
            errorMessage = "End time needs to be after the start time."
            return
        }
        errorMessage = nil
        let event = CleanupEvent(name: name, location: location, type: type, date: start, endDate: end, notes: notes)
        onSave(event)
        dismiss()
    }

    private func combine(day: Date, time: Date) -> Date {
        let calendar = Calendar.current
        var merged = calendar.dateComponents([.year, .month, .day], from: day)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        merged.hour = timeComponents.hour
        merged.minute = timeComponents.minute
        return calendar.date(from: merged) ?? day
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
