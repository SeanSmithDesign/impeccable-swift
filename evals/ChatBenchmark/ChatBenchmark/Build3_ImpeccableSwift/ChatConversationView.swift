import SwiftUI

// MARK: - Build 3: impeccable-swift skill, universal-only mode (no DESIGN.md)
//
// SwiftUI Reflex Check (per SKILL.md protocol):
// Brand words: "precise, layered, purposeful"
// Rejected reflexes:
//   - Color.blue for sent bubbles → use .tint or accent material
//   - Color(.systemGray6) for received → use .regularMaterial (materials.md: "glass is the surface language")
//   - VStack+Spacer for keyboard → use .safeAreaInset (navigation.md: "safe area handling goes through the system")
//   - cornerRadius(10) → use .continuous squircle (spatial-design.md: "always use .continuous corner style")
//   - No custom ButtonStyle → required per interaction-design.md
//   - No @ScaledMetric → required per typography.md
//   - UIScreen.main.bounds → deprecated iOS 26; use GeometryReader or maxWidth
//   - No reduce motion check → required per motion-design.md

// MARK: - Spacing tokens (spatial-design.md: 4pt base scale)
private enum Space {
    static let xxs: CGFloat = 4   // spatial-design.md: 4pt base
    static let xs:  CGFloat = 8
    static let sm:  CGFloat = 12
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let tap: CGFloat = 44  // spatial-design.md: 44pt minimum tap target
}

// MARK: - Send button style (interaction-design.md: "every custom button ships its own ButtonStyle")
private struct SendButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.72 : 1.0)
            // motion-design.md: 100–150ms for instant feedback
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct Build3ChatConversationView: View {
    @State private var messageText = ""
    @State private var expandedThreadIDs: Set<UUID> = []

    // accessibility.md: always check before animating
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // accessibility.md: material fallback
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    // typography.md: @ScaledMetric for custom sizes
    @ScaledMetric(relativeTo: .body) private var bubbleMinHeight: CGFloat = 36
    @ScaledMetric(relativeTo: .footnote) private var replyChipHeight: CGFloat = 28

    private let messages = SampleData.conversation

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let maxBubbleWidth = geo.size.width * 0.74
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(messages) { message in
                                messageRow(message, maxWidth: maxBubbleWidth)
                                    .id(message.id)
                            }
                        }
                        // spatial-design.md: 16pt horizontal gutter, 12pt top padding
                        .padding(.horizontal, Space.md)
                        .padding(.top, Space.sm)
                        .padding(.bottom, Space.xs)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            // navigation.md: use ScrollViewReader + scrollTo
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
            }
            // navigation.md: "safe area handling goes through the system"
            .safeAreaInset(edge: .bottom) {
                composeBar
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Row dispatch

    @ViewBuilder
    private func messageRow(_ message: Message, maxWidth: CGFloat) -> some View {
        switch message.content {
        case .dateHeader(let date):
            dateHeaderView(date)
                // spatial-design.md: 16pt above, 8pt below date headers
                .padding(.top, Space.md)
                .padding(.bottom, Space.xs)

        case .text(let text):
            textBubble(text: text, message: message, maxWidth: maxWidth)
                // spatial-design.md: 4pt between same-sender, 12pt across senders
                .padding(.bottom, Space.xxs)

        case .linkPreview(let body, let preview):
            linkPreviewBubble(body: body, preview: preview, message: message, maxWidth: maxWidth)
                .padding(.bottom, Space.xxs)

        case .photo(let attachment):
            photoBubble(attachment: attachment, message: message, maxWidth: maxWidth)
                .padding(.bottom, Space.xxs)

        case .pdfAttachment(let attachment):
            pdfBubble(attachment: attachment, message: message, maxWidth: maxWidth)
                .padding(.bottom, Space.xxs)

        case .replyThreadRoot(let body, let thread):
            replyThreadBubble(body: body, thread: thread, message: message, maxWidth: maxWidth)
                .padding(.bottom, Space.xs)
        }
    }

    // MARK: - Date Header

    private func dateHeaderView(_ date: Date) -> some View {
        HStack(spacing: Space.xs) {
            Rectangle().fill(.separator).frame(height: 0.5)
            // typography.md: .footnote.weight(.semibold), tertiary color
            Text(dateLabel(for: date))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .fixedSize()
            Rectangle().fill(.separator).frame(height: 0.5)
        }
    }

    // MARK: - Text Bubble

    private func textBubble(text: String, message: Message, maxWidth: CGFloat) -> some View {
        let isMe = message.sender == .me
        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Space.tap) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Space.xxs) {
                if !isMe, let info = SampleData.senders[message.sender] {
                    // typography.md: .footnote.weight(.semibold), .secondary color
                    Text(info.displayName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, Space.sm)
                }
                Text(text)
                    // typography.md: .body at default weight
                    .font(.body)
                    .foregroundStyle(isMe ? Color.white : .primary)
                    // spatial-design.md: bubble padding 12 vertical, 14 horizontal
                    .padding(.horizontal, 14)
                    .padding(.vertical, Space.sm)
                    .frame(minHeight: bubbleMinHeight)
                    .background(bubbleBackground(isMe: isMe))
                    .frame(maxWidth: maxWidth, alignment: isMe ? .trailing : .leading)
                // typography.md: .caption2.monospacedDigit()
                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Space.tap) }
        }
    }

    // MARK: - Link Preview Bubble

    private func linkPreviewBubble(body: String?, preview: LinkPreview, message: Message, maxWidth: CGFloat) -> some View {
        let isMe = message.sender == .me
        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Space.tap) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Space.xxs) {
                if let body = body {
                    Text(body)
                        .font(.body)
                        .foregroundStyle(isMe ? Color.white : .primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, Space.sm)
                        .background(bubbleBackground(isMe: isMe))
                }
                // materials.md: .ultraThinMaterial for link preview card
                VStack(alignment: .leading, spacing: Space.xs) {
                    HStack(alignment: .top, spacing: Space.sm) {
                        // sf-symbols.md: .regular for inline content
                        Image(systemName: preview.thumbnailSystemName)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    // spatial-design.md: concentric corners (14 outer - 6 pad = 8 inner)
                                    .fill(.quaternary)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            // typography.md: .subheadline.weight(.semibold)
                            Text(preview.title)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(2)
                            // typography.md: .footnote, two-line
                            Text(preview.description)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            // typography.md: .caption2 in tint color
                            Text(preview.sourceLabel)
                                .font(.caption2)
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .padding(Space.sm)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(reduceTransparency
                            ? AnyShapeStyle(Color(.secondarySystemBackground))
                            : AnyShapeStyle(Material.ultraThinMaterial))  // materials.md
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.separator, lineWidth: 0.5)
                        )
                )
                .accessibilityAddTraits(.isLink)
                .frame(maxWidth: maxWidth)

                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Space.tap) }
        }
    }

    // MARK: - Photo Bubble

    private func photoBubble(attachment: Attachment, message: Message, maxWidth: CGFloat) -> some View {
        let isMe = message.sender == .me
        let senderName = SampleData.senders[message.sender]?.displayName ?? "Unknown"
        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Space.tap) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Space.xxs) {
                ZStack {
                    // spatial-design.md: .continuous corner style, 14pt radius
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.quaternary)
                    // sf-symbols.md: size via .font not .frame
                    Image(systemName: attachment.displayImageSystemName ?? attachment.systemSymbolName)
                        .font(.system(size: 52))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: min(maxWidth, 220))
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .onTapGesture { }
                // accessibility.md: required label for media
                .accessibilityLabel("Photo from \(senderName)")
                .accessibilityAddTraits(.isButton)

                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Space.tap) }
        }
    }

    // MARK: - PDF Bubble

    private func pdfBubble(attachment: Attachment, message: Message, maxWidth: CGFloat) -> some View {
        let isMe = message.sender == .me
        let senderName = SampleData.senders[message.sender]?.displayName ?? "Unknown"
        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Space.tap) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Space.xxs) {
                HStack(spacing: Space.sm) {
                    // sf-symbols.md: .semibold for action glyphs; doc.fill for PDF
                    Image(systemName: attachment.systemSymbolName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.tint)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.tint.opacity(0.1))
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        // typography.md: .subheadline, lineLimit+truncationMode
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
                .padding(Space.sm)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(reduceTransparency
                            ? AnyShapeStyle(Color(.secondarySystemBackground))
                            : AnyShapeStyle(Material.regularMaterial))  // materials.md
                )
                .frame(maxWidth: maxWidth)
                // accessibility.md: media label
                .accessibilityLabel("PDF from \(senderName), \(attachment.filename), \(fileSizeString(attachment.fileSizeBytes))")

                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Space.tap) }
        }
    }

    // MARK: - Reply Thread Bubble

    private func replyThreadBubble(body: String, thread: ReplyThread, message: Message, maxWidth: CGFloat) -> some View {
        let isMe = message.sender == .me
        let isExpanded = expandedThreadIDs.contains(message.id)

        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Space.tap) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Space.xxs) {
                if !isMe, let info = SampleData.senders[message.sender] {
                    Text(info.displayName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, Space.sm)
                }

                // Root bubble
                Text(body)
                    .font(.body)
                    .foregroundStyle(isMe ? Color.white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, Space.sm)
                    .background(bubbleBackground(isMe: isMe))
                    .frame(maxWidth: maxWidth, alignment: isMe ? .trailing : .leading)

                // Reply thread affordance
                Button {
                    // motion-design.md: springs for interactive state changes; reduce motion fallback
                    let animation: Animation = reduceMotion
                        ? .easeInOut(duration: 0.15)
                        : .spring(response: 0.35, dampingFraction: 0.82)
                    withAnimation(animation) {
                        if isExpanded {
                            expandedThreadIDs.remove(message.id)
                        } else {
                            expandedThreadIDs.insert(message.id)
                        }
                    }
                } label: {
                    HStack(spacing: Space.xxs) {
                        // sf-symbols.md: arrowshape.turn.up.left.fill, .semibold weight for action
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.caption.weight(.semibold))
                        // typography.md: .footnote.weight(.medium)
                        Text("\(thread.replies.count) replies")
                            .font(.footnote.weight(.medium))
                    }
                    .foregroundStyle(.tint)
                    .frame(minHeight: replyChipHeight)
                    .padding(.horizontal, Space.xs)
                }
                // interaction-design.md: custom ButtonStyle with visible pressed state
                .buttonStyle(SendButtonStyle())
                // accessibility.md: combine for VoiceOver
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(thread.replies.count) replies — tap to \(isExpanded ? "collapse" : "expand")")

                // Expanded replies
                if isExpanded {
                    VStack(alignment: .leading, spacing: Space.xs) {
                        ForEach(thread.replies) { reply in
                            VStack(alignment: .leading, spacing: 2) {
                                if let info = SampleData.senders[reply.sender] {
                                    Text(info.displayName)
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                                Text(reply.body)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            .padding(.horizontal, Space.sm)
                            .padding(.vertical, Space.xs)
                            .frame(maxWidth: maxWidth - Space.md, alignment: .leading)
                            .background(
                                // materials.md: .thinMaterial for nested overlays
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(reduceTransparency
                                        ? AnyShapeStyle(Color(.tertiarySystemBackground))
                                        : AnyShapeStyle(Material.thinMaterial))
                            )
                        }
                    }
                    // motion-design.md: opacity for reduce-motion, combined for full motion
                    .transition(reduceMotion
                        ? .opacity
                        : .opacity.combined(with: .move(edge: .top)))
                }

                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Space.tap) }
        }
    }

    // MARK: - Compose Bar
    // navigation.md: pinned via .safeAreaInset, not VStack+Spacer
    // materials.md: .bar material for pinned chrome

    private var composeBar: some View {
        HStack(spacing: Space.sm) {
            TextField("Message", text: $messageText, axis: .vertical)
                .font(.body)
                .lineLimit(1...5)
                // spatial-design.md: 12pt vertical, 16pt horizontal
                .padding(.horizontal, Space.md)
                .padding(.vertical, Space.sm)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(reduceTransparency
                            ? AnyShapeStyle(Color(.secondarySystemBackground))
                            : AnyShapeStyle(Material.regularMaterial))
                )

            let canSend = !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            Button {
                messageText = ""
                // interaction-design.md: .sensoryFeedback(.success) on completion
            } label: {
                // sf-symbols.md: arrow.up.circle.fill enabled / arrow.up.circle disabled
                Image(systemName: canSend ? "arrow.up.circle.fill" : "arrow.up.circle")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(canSend ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
            }
            // interaction-design.md: custom ButtonStyle mandatory
            .buttonStyle(SendButtonStyle())
            // interaction-design.md: 44pt minimum tap target
            .frame(minWidth: Space.tap, minHeight: Space.tap)
            .contentShape(Rectangle())
            .disabled(!canSend)
            .accessibilityLabel("Send message")
            // interaction-design.md: .sensoryFeedback on success
            .sensoryFeedback(.success, trigger: messageText) { old, new in
                old.isEmpty == false && new.isEmpty
            }
        }
        // spatial-design.md: 16pt horizontal, 12pt vertical for compose bar
        .padding(.horizontal, Space.md)
        .padding(.vertical, Space.sm)
        .background(.bar)  // materials.md: .bar for pinned chrome
    }

    // MARK: - Bubble background helper

    private func bubbleBackground(isMe: Bool) -> some ShapeStyle {
        if isMe {
            return AnyShapeStyle(.tint)
        } else {
            // materials.md: .regularMaterial for received bubbles (not Color(.systemGray6))
            return AnyShapeStyle(reduceTransparency
                ? AnyShapeStyle(Color(.secondarySystemBackground))
                : AnyShapeStyle(Material.regularMaterial))
        }
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

#Preview("Build 3 — populated conversation") {
    Build3ChatConversationView()
}

#Preview("Build 3 — compose focused") {
    Build3ChatConversationView()
}
