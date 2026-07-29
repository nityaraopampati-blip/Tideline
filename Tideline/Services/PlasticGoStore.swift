import Foundation
import UIKit

/// Persists Plastic-Go sightings: photos on disk (Documents/PlasticGo/),
/// metadata (note, timestamp, filename) in UserDefaults — same pattern as
/// LocalStore, just split out since this one deals with image files too.
final class PlasticGoStore {
    static let shared = PlasticGoStore()

    private let defaults = UserDefaults.standard
    private let key = "tideline.plasticGoEntries"

    private var directory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = documents.appendingPathComponent("PlasticGo", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    var entries: [PlasticGoEntry] {
        get {
            guard let data = defaults.data(forKey: key) else { return [] }
            return (try? JSONDecoder().decode([PlasticGoEntry].self, from: data)) ?? []
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            defaults.set(data, forKey: key)
        }
    }

    @discardableResult
    func addEntry(image: UIImage, note: String) -> PlasticGoEntry? {
        let fileName = "\(UUID().uuidString).jpg"
        guard let jpegData = image.jpegData(compressionQuality: 0.7) else { return nil }
        let fileURL = directory.appendingPathComponent(fileName)
        do {
            try jpegData.write(to: fileURL)
        } catch {
            return nil
        }
        let entry = PlasticGoEntry(imageFileName: fileName, note: note)
        entries.insert(entry, at: 0)
        return entry
    }

    func image(for entry: PlasticGoEntry) -> UIImage? {
        UIImage(contentsOfFile: directory.appendingPathComponent(entry.imageFileName).path)
    }

    func deleteEntry(_ entry: PlasticGoEntry) {
        try? FileManager.default.removeItem(at: directory.appendingPathComponent(entry.imageFileName))
        entries.removeAll { $0.id == entry.id }
    }
}
