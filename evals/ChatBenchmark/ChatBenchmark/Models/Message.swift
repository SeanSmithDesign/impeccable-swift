import Foundation

struct Message: Identifiable, Hashable {
    let id: UUID
    let sender: Sender
    let sentAt: Date
    let content: MessageContent
}
