import Foundation

/// Encodes a cleanup event into a `tideline://join?event=…` link that gets
/// shared alongside the evite image. There's no shared backend, so this is
/// the only way another device running Tideline can "receive" an event —
/// tapping the link opens the app and offers to add it locally.
enum EventDeepLink {
    private static let scheme = "tideline"
    private static let host = "join"

    static func url(for event: CleanupEvent) -> URL? {
        guard let data = try? JSONEncoder().encode(event) else { return nil }
        let token = data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.queryItems = [URLQueryItem(name: "event", value: token)]
        return components.url
    }

    static func event(from url: URL) -> CleanupEvent? {
        guard url.scheme == scheme, url.host == host,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let token = components.queryItems?.first(where: { $0.name == "event" })?.value
        else { return nil }

        let base64 = token
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        guard let data = Data(base64Encoded: base64) else { return nil }
        return try? JSONDecoder().decode(CleanupEvent.self, from: data)
    }
}
