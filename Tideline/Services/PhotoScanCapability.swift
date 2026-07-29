import Foundation
import FoundationModels

/// Whether this device/OS can run the Foundation Models-powered part of
/// photo scanning (iOS 26 + iPhone 15 Pro or newer / Apple Intelligence
/// enabled). Callable from anywhere without callers needing `#available`
/// guards of their own.
enum PhotoScanCapability {
    static func isAvailable() -> Bool {
        if #available(iOS 26.0, *) {
            return SystemLanguageModel.default.availability == .available
        }
        return false
    }
}
