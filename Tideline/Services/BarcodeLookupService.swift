import Foundation

/// Looks up a scanned barcode against Open Food Facts, then Open Beauty
/// Facts, then Open Products Facts — all free, keyless, and together
/// covering far more of Tideline's target items than any one alone.
struct BarcodeLookupService {
    private let endpoints = [
        "https://world.openfoodfacts.org/api/v2/product/",
        "https://world.openbeautyfacts.org/api/v2/product/",
        "https://world.openproductsfacts.org/api/v2/product/",
    ]

    func lookupProductName(barcode: String) async -> String? {
        for base in endpoints {
            guard let url = URL(string: "\(base)\(barcode).json") else { continue }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { continue }
                let decoded = try JSONDecoder().decode(OpenFactsResponse.self, from: data)
                if decoded.status == 1, let product = decoded.product {
                    if let name = product.productName, !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        return name
                    }
                    if let categories = product.categories, !categories.isEmpty {
                        return categories.split(separator: ",").first.map(String.init)
                    }
                }
            } catch {
                continue
            }
        }
        return nil
    }
}

private struct OpenFactsResponse: Decodable {
    let status: Int
    let product: Product?

    struct Product: Decodable {
        let productName: String?
        let categories: String?

        enum CodingKeys: String, CodingKey {
            case productName = "product_name"
            case categories
        }
    }
}
