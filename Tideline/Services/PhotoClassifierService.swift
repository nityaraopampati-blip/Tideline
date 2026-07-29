import UIKit
import Vision

/// Identifies the general subject of a photo using Apple's built-in Vision
/// classifier. This runs on any iOS 17+ device — it's the "what am I looking
/// at" step. Turning an unrecognized label into a full environmental
/// estimate is a separate step handled by AIEstimateService (Foundation
/// Models), which is the part that actually needs iPhone 15 Pro / iOS 26.
enum PhotoClassifierService {
    static func classify(_ image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }
        let orientation = cgOrientation(from: image.imageOrientation)

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, _ in
                let results = request.results as? [VNClassificationObservation] ?? []
                let best = results
                    .filter { $0.confidence > 0.2 }
                    .max { $0.confidence < $1.confidence }
                let label = best?.identifier.replacingOccurrences(of: "_", with: " ")
                continuation.resume(returning: label)
            }
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }

    private static func cgOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
