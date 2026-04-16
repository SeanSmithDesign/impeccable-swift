import SwiftUI

// MARK: - Build 2: Web impeccable applied to SwiftUI
// Applies impeccable design principles from the web skill as best as SwiftUI allows.
// No Swift-specific APIs implied by the web skill (no Liquid Glass, no @ScaledMetric).
// Web equivalents mapped: CSS variables → semantic colors, backdrop-filter → Material,
// hover: → pressed states, max-width → frame(maxWidth:), gap/padding → spacing system.

// MARK: - Spacing tokens (mapped from impeccable's 4pt rhythm)
private enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Send button style with visible pressed state
private struct SendButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.75 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Thread expand button style
private struct ThreadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct Build2ChatConversationView: View {
    @State private var messageText = ""
    @State private var expandedThreadIDs: Set<UUID> = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let messages = SampleData.conversation

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(messages) { message in
                            messageRow(message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, Spacing.sm)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                composeBar
            }
            .navigationTitle("Conversation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Message Row dispatch

    @ViewBuilder
    private func messageRow(_ message: Message) -> some View {
        switch message.content {
        case .dateHeader(let date):
            dateHeaderRow(date)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.md)

        case .text(let text):
            textBubbleRow(text: text, message: message)
                .padding(.bottom, Spacing.xs)

        case .linkPreview(let body, let preview):
            linkPreviewRow(body: body, preview: preview, message: message)
                .padding(.bottom, Spacing.xs)

        case .photo(let attachment):
            photoBubbleRow(attachment: attachment, message: message)
                .padding(.bottom, Spacing.xs)

        case .pdfAttachment(let attachment):
            pdfBubbleRow(attachment: attachment, message: message)
                .padding(.bottom, Spacing.xs)

        case .replyThreadRoot(let body, let thread):
            replyThreadRow(body: body, thread: thread, message: message)
                .padding(.bottom, Spacing.sm)
        }
    }

    // MARK: - Date Header

    private func dateHeaderRow(_ date: Date) -> some View {
        HStack(spacing: Spacing.md) {
            Rectangle()
                .fill(.separator)
                .frame(height: 0.5)
            Text(dateLabel(for: date))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .fixedSize()
            Rectangle()
                .fill(.separator)
                .frame(height: 0.5)
        }
    }

    // MARK: - Text Bubble

    private func textBubbleRow(text: String, message: Message) -> some View {
        let isMe = message.sender == .me
        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Spacing.xxl) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Spacing.xs) {
                if !isMe, let info = SampleData.senders[message.sender] {
                    Text(info.displayName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, Spacing.md)
                }
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isMe ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.regularMaterial))
                    )
                    .foregroundStyle(isMe ? Color.white : .primary)
                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Spacing.xxl) }
        }
    }

    // MARK: - Link Preview Row

    private func linkPreviewRow(body: String?, preview: LinkPreview, message: Message) -> some View {
        let isMe = message.sender == .me
        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Spacing.xxl) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Spacing.xs) {
                if let body = body {
                    Text(body)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isMe ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.regularMaterial))
                        )
                }
                // Link preview card (mapped from CSS card with border + backdrop-filter)
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(alignment: .top, spacing: Spacing.md) {
                        Image(systemName: preview.thumbnailSystemName)
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.quaternary)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preview.title)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(2)
                            Text(preview.description)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            Text(preview.sourceLabel)
                                .font(.caption2)
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(.separator, lineWidth: 0.5)
                        )
                )
                .accessibilityAddTraits(.isLink)
                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Spacing.xxl) }
        }
    }

    // MARK: - Photo Bubble

    private func photoBubbleRow(attachment: Attachment, message: Message) -> some View {
        let isMe = message.sender == .me
        let senderName = SampleData.senders[message.sender]?.displayName ?? "Unknown"
        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Spacing.xxl) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Spacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.quaternary)
                    Image(systemName: attachment.displayImageSystemName ?? attachment.systemSymbolName)
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 220)
                .frame(height: 160)
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .onTapGesture { }
                .accessibilityLabel("Photo from \(senderName)")
                .accessibilityAddTraits(.isButton)
                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Spacing.xxl) }
        }
    }

    // MARK: - PDF Attachment Row

    private func pdfBubbleRow(attachment: Attachment, message: Message) -> some View {
        let isMe = message.sender == .me
        let senderName = SampleData.senders[message.sender]?.displayName ?? "Unknown"
        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Spacing.xxl) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: attachment.systemSymbolName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.tint)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.tint.opacity(0.12))
                        )
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
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.regularMaterial)
                )
                .accessibilityLabel("PDF from \(senderName), \(attachment.filename), \(fileSizeString(attachment.fileSizeBytes))")
                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Spacing.xxl) }
        }
    }

    // MARK: - Reply Thread Row

    private func replyThreadRow(body: String, thread: ReplyThread, message: Message) -> some View {
        let isMe = message.sender == .me
        let isExpanded = expandedThreadIDs.contains(message.id)

        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Spacing.xxl) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Spacing.xs) {
                if !isMe, let info = SampleData.senders[message.sender] {
                    Text(info.displayName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, Spacing.md)
                }
                // Root message bubble
                Text(body)
                    .font(.body)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isMe ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.regularMaterial))
                    )
                    .foregroundStyle(isMe ? Color.white : .primary)

                // Reply affordance
                Button {
                    let animation: Animation = reduceMotion
                        ? .easeInOut(duration: 0.15)
                        : .spring(response: 0.35, dampingFraction: 0.8)
                    withAnimation(animation) {
                        if isExpanded {
                            expandedThreadIDs.remove(message.id)
                        } else {
                            expandedThreadIDs.insert(message.id)
                        }
                    }
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.caption.weight(.semibold))
                        Text("\(thread.replies.count) replies")
                            .font(.footnote.weight(.medium))
                    }
                    .foregroundStyle(.tint)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                }
                .buttonStyle(ThreadButtonStyle())
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(thread.replies.count) replies — tap to \(isExpanded ? "collapse" : "expand")")

                // Expanded replies
                if isExpanded {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ForEach(thread.replies) { reply in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                VStack(alignment: .leading, spacing: 2) {
                                    if let info = SampleData.senders[reply.sender] {
                                        Text(info.displayName)
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(reply.body)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                }
                                Spacer()
                                Text(timeString(reply.sentAt))
                                    .font(.caption2.monospacedDigit())
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.thinMaterial)
                            )
                        }
                    }
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                }

                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Spacing.xxl) }
        }
    }

    // MARK: - Compose Bar
    // Mapped from CSS: sticky bottom bar with backdrop-filter

    private var composeBar: some View {
        HStack(spacing: Spacing.md) {
            TextField("Message", text: $messageText, axis: .vertical)
                .font(.body)
                .lineLimit(1...5)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.regularMaterial)
                )

            let canSend = !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            Button {
                messageText = ""
            } label: {
                Image(systemName: canSend ? "arrow.up.circle.fill" : "arrow.up.circle")
                    .font(.title2)
                    .foregroundStyle(canSend ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
            }
            .buttonStyle(SendButtonStyle())
            .disabled(!canSend)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(.bar)
    }

    // MARK: - Helpers

    private func dateLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }

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

#Preview("Build 2 — Web impeccable") {
    Build2ChatConversationView()
}
