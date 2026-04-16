import Foundation

enum SampleData {

    static let senders: [Sender: SenderInfo] = [
        .me: SenderInfo(sender: .me, displayName: "Me", avatarSymbolName: "person.crop.circle.fill"),
        .alex: SenderInfo(sender: .alex, displayName: "Alex", avatarSymbolName: "person.crop.circle"),
        .jordan: SenderInfo(sender: .jordan, displayName: "Jordan", avatarSymbolName: "person.crop.circle.badge.fill"),
    ]

    // Fixed "now" for deterministic timestamps across preview runs
    private static let now: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 15
        components.hour = 10
        components.minute = 31
        components.second = 0
        components.timeZone = TimeZone(identifier: "America/Los_Angeles")
        return Calendar.current.date(from: components) ?? Date()
    }()

    private static func date(daysOffset: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.day = daysOffset
        components.hour = hour - Calendar.current.component(.hour, from: now)
        components.minute = minute - Calendar.current.component(.minute, from: now)
        let base = Calendar.current.startOfDay(for: now)
        var dc = DateComponents()
        dc.day = daysOffset
        let dayDate = Calendar.current.date(byAdding: dc, to: base) ?? now
        var timeComponents = DateComponents()
        timeComponents.hour = hour
        timeComponents.minute = minute
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: dayDate) ?? dayDate
    }

    // Yesterday = -1 day from now; Today = 0
    static let conversation: [Message] = {
        let atlanticURL = URL(string: "https://www.theatlantic.com")!

        // Reply thread replies
        let reply1 = ReplyThread.Reply(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            sender: .jordan,
            body: "I think the hero is doing too much work",
            sentAt: date(daysOffset: 0, hour: 10, minute: 25)
        )
        let reply2 = ReplyThread.Reply(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            sender: .jordan,
            body: "maybe pull the subhead out and make it its own moment?",
            sentAt: date(daysOffset: 0, hour: 10, minute: 26)
        )
        let reply3 = ReplyThread.Reply(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            sender: .alex,
            body: "yeah let's try it",
            sentAt: date(daysOffset: 0, hour: 10, minute: 27)
        )
        let thread = ReplyThread(replies: [reply1, reply2, reply3])

        return [
            // 1. Date header — "Yesterday"
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                sender: .me,
                sentAt: date(daysOffset: -1, hour: 0, minute: 0),
                content: .dateHeader(date(daysOffset: -1, hour: 0, minute: 0))
            ),
            // 2. Received text from alex — short
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                sender: .alex,
                sentAt: date(daysOffset: -1, hour: 15, minute: 42),
                content: .text("hey, you around?")
            ),
            // 3. Sent text from me — multiline
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                sender: .me,
                sentAt: date(daysOffset: -1, hour: 15, minute: 44),
                content: .text("yeah, just finishing up. that thing we were talking about last week — I finally read the piece. it's good.")
            ),
            // 4. Received link preview from alex
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
                sender: .alex,
                sentAt: date(daysOffset: -1, hour: 15, minute: 48),
                content: .linkPreview(
                    body: "this one?",
                    preview: LinkPreview(
                        title: "The Case for a Slower Internet",
                        description: "Why we should stop optimizing for engagement and start optimizing for attention.",
                        thumbnailSystemName: "newspaper.fill",
                        sourceURL: atlanticURL,
                        sourceLabel: "theatlantic.com"
                    )
                )
            ),
            // 5. Sent text from me
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000005")!,
                sender: .me,
                sentAt: date(daysOffset: -1, hour: 15, minute: 51),
                content: .text("exactly that one.")
            ),
            // 6. Received photo from alex — inline image
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000006")!,
                sender: .alex,
                sentAt: date(daysOffset: -1, hour: 15, minute: 55),
                content: .photo(Attachment(
                    kind: .photo,
                    filename: "photo.jpg",
                    fileSizeBytes: 0,
                    systemSymbolName: "photo",
                    displayImageSystemName: "photo.stack"
                ))
            ),
            // 7. Sent text from me
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000007")!,
                sender: .me,
                sentAt: date(daysOffset: -1, hour: 16, minute: 8),
                content: .text("ha, perfect.")
            ),
            // 8. Date header — "Today"
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000008")!,
                sender: .me,
                sentAt: date(daysOffset: 0, hour: 0, minute: 0),
                content: .dateHeader(date(daysOffset: 0, hour: 0, minute: 0))
            ),
            // 9. Received text from alex
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000009")!,
                sender: .alex,
                sentAt: date(daysOffset: 0, hour: 10, minute: 15),
                content: .text("one more thing — sending over the brief")
            ),
            // 10. Received PDF attachment from alex
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000010")!,
                sender: .alex,
                sentAt: date(daysOffset: 0, hour: 10, minute: 16),
                content: .pdfAttachment(Attachment(
                    kind: .pdf,
                    filename: "chat-brief-v2-final.pdf",
                    fileSizeBytes: 1_468_006,   // ~1.4 MB
                    systemSymbolName: "doc.fill",
                    displayImageSystemName: nil
                ))
            ),
            // 11. Sent text from me
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000011")!,
                sender: .me,
                sentAt: date(daysOffset: 0, hour: 10, minute: 20),
                content: .text("got it, will read tonight")
            ),
            // 12. Received reply-thread root from alex
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000012")!,
                sender: .alex,
                sentAt: date(daysOffset: 0, hour: 10, minute: 23),
                content: .replyThreadRoot(
                    body: "also — the team had thoughts on the homepage. see below.",
                    thread: thread
                )
            ),
            // 13. Sent text from me
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000013")!,
                sender: .me,
                sentAt: date(daysOffset: 0, hour: 10, minute: 28),
                content: .text("makes sense. I'll cut a branch tonight.")
            ),
            // 14. Received text from alex — single emoji
            Message(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000014")!,
                sender: .alex,
                sentAt: date(daysOffset: 0, hour: 10, minute: 31),
                content: .text("\u{1F64F}")
            ),
        ]
    }()
}
