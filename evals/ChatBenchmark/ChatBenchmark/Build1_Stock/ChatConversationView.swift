import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Build 1: Stock SwiftUI — no design guidance

struct Build1ChatConversationView: View {
    @State private var messageText = ""
    @State private var expandedThreadIDs: Set<UUID> = []

    private let messages = SampleData.conversation

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(messages) { message in
                                messageRow(message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                composeBar
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Message Row

    @ViewBuilder
    private func messageRow(_ message: Message) -> some View {
        switch message.content {
        case .dateHeader(let date):
            dateHeaderView(date)
        case .text(let text):
            textBubble(text: text, sender: message.sender, sentAt: message.sentAt)
        case .linkPreview(let body, let preview):
            linkPreviewBubble(body: body, preview: preview, sender: message.sender, sentAt: message.sentAt)
        case .photo(let attachment):
            photoBubble(attachment: attachment, sender: message.sender, sentAt: message.sentAt)
        case .pdfAttachment(let attachment):
            pdfBubble(attachment: attachment, sender: message.sender, sentAt: message.sentAt)
        case .replyThreadRoot(let body, let thread):
            replyThreadBubble(body: body, thread: thread, message: message)
        }
    }

    // MARK: - Date Header

    private func dateHeaderView(_ date: Date) -> some View {
        HStack {
            Divider()
            Text(dateLabel(for: date))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            Divider()
        }
        .padding(.vertical, 8)
    }

    private func dateLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }

    // MARK: - Text Bubble

    private func textBubble(text: String, sender: Sender, sentAt: Date) -> some View {
        HStack {
            if sender == .me { Spacer() }
            VStack(alignment: sender == .me ? .trailing : .leading, spacing: 2) {
                if let info = SampleData.senders[sender], sender != .me {
                    Text(info.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(sender == .me ? Color.blue : Color(.systemGray6))
                    .foregroundStyle(sender == .me ? Color.white : Color.primary)
                    .cornerRadius(10)
                Text(timeString(sentAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: sender == .me ? .trailing : .leading)
            if sender != .me { Spacer() }
        }
    }

    // MARK: - Link Preview Bubble

    private func linkPreviewBubble(body: String?, preview: LinkPreview, sender: Sender, sentAt: Date) -> some View {
        HStack {
            if sender == .me { Spacer() }
            VStack(alignment: .leading, spacing: 4) {
                if let body = body {
                    Text(body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(sender == .me ? Color.blue : Color(.systemGray6))
                        .foregroundStyle(sender == .me ? Color.white : Color.primary)
                        .cornerRadius(10)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: preview.thumbnailSystemName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preview.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(2)
                            Text(preview.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            Text(preview.sourceLabel)
                                .font(.caption2)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                Text(timeString(sentAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            if sender != .me { Spacer() }
        }
    }

    // MARK: - Photo Bubble

    private func photoBubble(attachment: Attachment, sender: Sender, sentAt: Date) -> some View {
        let senderName = SampleData.senders[sender]?.displayName ?? "Unknown"
        return HStack {
            if sender == .me { Spacer() }
            VStack(alignment: sender == .me ? .trailing : .leading, spacing: 2) {
                ZStack {
                    Color(.systemGray5)
                    Image(systemName: attachment.displayImageSystemName ?? attachment.systemSymbolName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 200, height: 150)
                .cornerRadius(10)
                .accessibilityLabel("Photo from \(senderName)")
                Text(timeString(sentAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: sender == .me ? .trailing : .leading)
            if sender != .me { Spacer() }
        }
    }

    // MARK: - PDF Bubble

    private func pdfBubble(attachment: Attachment, sender: Sender, sentAt: Date) -> some View {
        let senderName = SampleData.senders[sender]?.displayName ?? "Unknown"
        return HStack {
            if sender == .me { Spacer() }
            VStack(alignment: sender == .me ? .trailing : .leading, spacing: 2) {
                HStack(spacing: 10) {
                    Image(systemName: attachment.systemSymbolName)
                        .font(.title2)
                        .foregroundStyle(.red)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(attachment.filename)
                            .font(.subheadline)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text(fileSizeString(attachment.fileSizeBytes))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .accessibilityLabel("PDF from \(senderName), \(attachment.filename), \(fileSizeString(attachment.fileSizeBytes))")
                Text(timeString(sentAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: sender == .me ? .trailing : .leading)
            if sender != .me { Spacer() }
        }
    }

    // MARK: - Reply Thread Bubble

    private func replyThreadBubble(body: String, thread: ReplyThread, message: Message) -> some View {
        let isExpanded = expandedThreadIDs.contains(message.id)
        let senderName = SampleData.senders[message.sender]?.displayName ?? "Unknown"

        return HStack {
            if message.sender == .me { Spacer() }
            VStack(alignment: message.sender == .me ? .trailing : .leading, spacing: 4) {
                if let info = SampleData.senders[message.sender], message.sender != .me {
                    Text(info.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.sender == .me ? Color.blue : Color(.systemGray6))
                    .foregroundStyle(message.sender == .me ? Color.white : Color.primary)
                    .cornerRadius(10)

                Button {
                    withAnimation {
                        if isExpanded {
                            expandedThreadIDs.remove(message.id)
                        } else {
                            expandedThreadIDs.insert(message.id)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.caption)
                        Text("\(thread.replies.count) replies")
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(thread.replies.count) replies — tap to \(isExpanded ? "collapse" : "expand")")

                if isExpanded {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(thread.replies) { reply in
                            VStack(alignment: .leading, spacing: 2) {
                                if let info = SampleData.senders[reply.sender] {
                                    Text(info.displayName)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                }
                                Text(reply.body)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                }

                Text(timeString(message.sentAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.sender == .me ? .trailing : .leading)
            if message.sender != .me { Spacer() }
        }
        .accessibilityLabel(message.sender == .me ? "You" : senderName)
    }

    // MARK: - Compose Bar

    private var composeBar: some View {
        HStack(spacing: 8) {
            TextField("Message", text: $messageText, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)

            Button {
                messageText = ""
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.systemGray3) : Color.blue)
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    // MARK: - Helpers

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    private func fileSizeString(_ bytes: Int) -> String {
        if bytes >= 1_000_000 {
            return String(format: "%.1f MB", Double(bytes) / 1_000_000)
        } else if bytes >= 1_000 {
            return String(format: "%.0f KB", Double(bytes) / 1_000)
        }
        return "\(bytes) B"
    }
}

#Preview("Build 1 — Stock") {
    Build1ChatConversationView()
}
