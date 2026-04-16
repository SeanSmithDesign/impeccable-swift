import Foundation

struct LinkPreview: Hashable {
    let title: String
    let description: String
    let thumbnailSystemName: String   // SF Symbol stand-in for thumbnail
    let sourceURL: URL
    let sourceLabel: String            // e.g. "nytimes.com"
}
