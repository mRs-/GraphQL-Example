import Foundation

typealias Products = [Product]
struct Product: Codable {
    let id: UUID = UUID()
    var name: String
    var categories: Categories = []
    var description: String?
    var recommendations: RecommendationProducts = []
    var favorised: Bool = false
}

typealias RecommendationProducts = [UUID]

typealias Categories = [Category]
struct Category: Codable {
    let id: UUID = UUID()
    let name: String
}
