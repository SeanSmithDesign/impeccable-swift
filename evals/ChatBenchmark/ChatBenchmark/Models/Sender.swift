import Foundation

enum Sender: String, Hashable, Codable {
    case me
    case alex     // primary correspondent
    case jordan   // secondary correspondent (for reply thread variety)
}

struct SenderInfo: Hashable {
    let sender: Sender
    let displayName: String
    let avatarSymbolName: String   // SF Symbol fallback; no image assets required
}
