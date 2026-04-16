import Foundation

struct ReplyThread: Hashable {
    let replies: [Reply]

    struct Reply: Hashable, Identifiable {
        let id: UUID
        let sender: Sender
        let body: String
        let sentAt: Date
    }
}
