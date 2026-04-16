import SwiftUI

// MARK: - Build 4: impeccable-swift + DESIGN.md (Full Sean setup)
//
// SwiftUI Reflex Check (per SKILL.md protocol):
// Brand words (DESIGN.md): "focused, fast, familiar"
// Project DESIGN.md tokens override universal defaults per two-layer read precedence:
//   - Accent: #c97350 (warm rust / terracotta) — DESIGN.md
//   - Bubble radius: 18pt .continuous — DESIGN.md
//   - Spacing rhythm: 4/8/12/16/24 — DESIGN.md
//   - Compose bar: .bar material via .safeAreaInset — DESIGN.md
//   - Sent bubbles: accent-tinted surface — DESIGN.md
//   - Received bubbles: .regularMaterial — DESIGN.md
// Universal rules fill gaps where DESIGN.md is silent (animations, accessibility, symbols).
//
// Rejected reflexes (SKILL.md + DESIGN.md anti-patterns):
//   - Color.blue / Color(.systemGray6) — DESIGN.md: explicitly banned
//   - cornerRadius(10) with raw number — DESIGN.md: use .continuous + token
//   - VStack keyboard avoidance — DESIGN.md: .safeAreaInset only
//   - Decorative shadows — DESIGN.md: no decorative shadows
//   - Emoji in comments — DESIGN.md: no emoji in comments

// MARK: - Accent color token (DESIGN.md: accent #c97350)
private extension Color {
    // DESIGN.md: accent #c97350 — warm rust / terracotta
    static let terracotta = Color(red: 0.788, green: 0.451, blue: 0.314)
}

// MARK: - Spacing tokens (DESIGN.md: rhythm 4/8/12/16/24)
private enum Space {
    static let xxs: CGFloat = 4
    static let xs:  CGFloat = 8
    static let sm:  CGFloat = 12
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let tap: CGFloat = 44  // spatial-design.md: 44pt minimum tap target
}

// MARK: - Send button style (interaction-design.md + DESIGN.md: scale ~0.96, opacity shift)
private struct SendButtonStyle: ButtonStyle {
    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.72 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct Build4ChatConversationView: View {
    @State private var messageText = ""
    @State private var expandedThreadIDs: Set<UUID> = []
    @State private var sendTrigger = false

    // accessibility.md: always check
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    // DESIGN.md: @ScaledMetric for bubble min-height and reply-count chip
    // typography.md: @ScaledMetric scales with Dynamic Type
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
                        // DESIGN.md: spacing rhythm; spatial-design.md: 16pt horizontal gutter
                        .padding(.horizontal, Space.md)
                        .padding(.top, Space.sm)
                        .padding(.bottom, Space.xs)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
            }
            // DESIGN.md: .safeAreaInset only — no VStack keyboard avoidance
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
                // DESIGN.md: 16pt above, 8pt below date header
                .padding(.top, Space.md)
                .padding(.bottom, Space.xs)

        case .text(let text):
            textBubble(text: text, message: message, maxWidth: maxWidth)
                // DESIGN.md: 4pt gap between same-sender bubbles
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
                // DESIGN.md: 12pt gap between senders
                .padding(.bottom, Space.sm)
        }
    }

    // MARK: - Date Header

    private func dateHeaderView(_ date: Date) -> some View {
        HStack(spacing: Space.xs) {
            Rectangle().fill(.separator).frame(height: 0.5)
            // DESIGN.md: .footnote.weight(.semibold), centered, tertiary color
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
                    // DESIGN.md: .footnote.weight(.semibold), secondary color
                    Text(info.displayName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.leading, Space.sm)
                }
                Text(text)
                    // DESIGN.md: .body at default weight
                    .font(.body)
                    .foregroundStyle(isMe ? Color.white : .primary)
                    // DESIGN.md: bubble padding 12 vertical, 14 horizontal
                    .padding(.horizontal, 14)
                    .padding(.vertical, Space.sm)
                    .frame(minHeight: bubbleMinHeight)
                    .background(sentOrReceivedBackground(isMe: isMe))
                    .frame(maxWidth: maxWidth, alignment: isMe ? .trailing : .leading)
                // DESIGN.md: .caption2.monospacedDigit()
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
                        .background(sentOrReceivedBackground(isMe: isMe))
                }
                // DESIGN.md: link preview card radius 14 .continuous, .ultraThinMaterial + stroke
                VStack(alignment: .leading, spacing: Space.xs) {
                    HStack(alignment: .top, spacing: Space.sm) {
                        Image(systemName: preview.thumbnailSystemName)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .frame(width: 40, height: 40)
                            .background(
                                // spatial-design.md: concentric corners (14 outer - 6 pad = 8 inner)
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(.quaternary)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            // DESIGN.md: .subheadline.weight(.semibold)
                            Text(preview.title)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(2)
                            // DESIGN.md: .footnote, two-line truncation
                            Text(preview.description)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            // DESIGN.md: .caption2 in accent color
                            Text(preview.sourceLabel)
                                .font(.caption2)
                                .foregroundStyle(Color.terracotta)
                        }
                    }
                }
                .padding(Space.sm)
                .background(
                    // DESIGN.md: .ultraThinMaterial over a subtle stroke
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(reduceTransparency
                            ? AnyShapeStyle(Color(.secondarySystemBackground))
                            : AnyShapeStyle(Material.ultraThinMaterial))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.separator, lineWidth: 0.5)
                        )
                )
                // accessibility.md: .isLink trait
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
                    // DESIGN.md: inline photo radius 14 .continuous
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
                // DESIGN.md + accessibility.md: accessibilityLabel required
                .accessibilityLabel("Photo from \(senderName)")
                .accessibilityAddTraits(.isButton)

                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Space.tap) }
        }
    }

    // MARK: - PDF Attachment Row

    private func pdfBubble(attachment: Attachment, message: Message, maxWidth: CGFloat) -> some View {
        let isMe = message.sender == .me
        let senderName = SampleData.senders[message.sender]?.displayName ?? "Unknown"
        return HStack(alignment: .bottom, spacing: 0) {
            if isMe { Spacer(minLength: Space.tap) }
            VStack(alignment: isMe ? .trailing : .leading, spacing: Space.xxs) {
                HStack(spacing: Space.sm) {
                    // DESIGN.md: doc.fill symbol, .semibold for action glyphs
                    Image(systemName: attachment.systemSymbolName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.terracotta)  // DESIGN.md: accent sparingly
                        .frame(width: 40, height: 40)
                        .background(
                            // spatial-design.md: concentric corners (14 outer - 6 pad = 8 inner)
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.terracotta.opacity(0.1))
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        // DESIGN.md: .subheadline, lineLimit(1), .truncationMode(.middle)
                        Text(attachment.filename)
                            .font(.subheadline)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        // DESIGN.md: .caption, secondary color
                        Text(fileSizeString(attachment.fileSizeBytes))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(Space.sm)
                .background(
                    // DESIGN.md: PDF attachment row radius 14 .continuous
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(reduceTransparency
                            ? AnyShapeStyle(Color(.secondarySystemBackground))
                            : AnyShapeStyle(Material.regularMaterial))
                )
                .frame(maxWidth: maxWidth)
                // DESIGN.md + accessibility.md: label required
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

                // Root message bubble
                Text(body)
                    .font(.body)
                    .foregroundStyle(isMe ? Color.white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, Space.sm)
                    .background(sentOrReceivedBackground(isMe: isMe))
                    .frame(maxWidth: maxWidth, alignment: isMe ? .trailing : .leading)

                // Reply thread affordance (DESIGN.md: .footnote.weight(.medium), accent color)
                Button {
                    // DESIGN.md: spring(duration: 0.35, bounce: 0.15); reduce-motion fallback
                    let animation: Animation = reduceMotion
                        ? .easeInOut(duration: 0.15)
                        : .spring(duration: 0.35, bounce: 0.15)
                    withAnimation(animation) {
                        if isExpanded {
                            expandedThreadIDs.remove(message.id)
                        } else {
                            expandedThreadIDs.insert(message.id)
                        }
                    }
                } label: {
                    HStack(spacing: Space.xxs) {
                        // DESIGN.md: arrowshape.turn.up.left.fill, .semibold weight
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.caption.weight(.semibold))
                        // DESIGN.md: .footnote.weight(.medium)
                        Text("\(thread.replies.count) replies")
                            .font(.footnote.weight(.medium))
                    }
                    .foregroundStyle(Color.terracotta)  // DESIGN.md: accent for active reply affordance
                    .frame(minHeight: replyChipHeight)
                    .padding(.horizontal, Space.xs)
                }
                .buttonStyle(SendButtonStyle(isEnabled: true))
                // DESIGN.md + accessibility.md: combine for VoiceOver
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
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(reduceTransparency
                                        ? AnyShapeStyle(Color(.tertiarySystemBackground))
                                        : AnyShapeStyle(Material.thinMaterial))
                            )
                        }
                    }
                    // motion-design.md: opacity-only when reduce motion is on
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                }

                Text(timeString(message.sentAt))
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
            if !isMe { Spacer(minLength: Space.tap) }
        }
    }

    // MARK: - Compose Bar
    // DESIGN.md: .bar material, pinned via .safeAreaInset

    private var composeBar: some View {
        HStack(spacing: Space.sm) {
            TextField("Message", text: $messageText, axis: .vertical)
                .font(.body)
                .lineLimit(1...5)
                // DESIGN.md: compose bar internal padding 12 vertical, 16 horizontal
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
                sendTrigger.toggle()
                messageText = ""
            } label: {
                // DESIGN.md: arrow.up.circle.fill enabled / arrow.up.circle disabled
                // sf-symbols.md: .semibold for action glyphs
                Image(systemName: canSend ? "arrow.up.circle.fill" : "arrow.up.circle")
                    .font(.title2.weight(.semibold))
                    // DESIGN.md: accent as send-button fill when enabled
                    .foregroundStyle(canSend ? Color.terracotta : Color.secondary)
            }
            // DESIGN.md + interaction-design.md: custom ButtonStyle with pressed state
            .buttonStyle(SendButtonStyle(isEnabled: canSend))
            // spatial-design.md: 44pt minimum tap target
            .frame(minWidth: Space.tap, minHeight: Space.tap)
            .contentShape(Rectangle())
            .disabled(!canSend)
            .accessibilityLabel("Send message")
            // DESIGN.md: .sensoryFeedback(.success) on send
            .sensoryFeedback(.success, trigger: sendTrigger)
        }
        // DESIGN.md: compose bar padding 12 vertical, 16 horizontal
        .padding(.horizontal, Space.md)
        .padding(.vertical, Space.sm)
        // DESIGN.md: .bar material for compose bar
        .background(.bar)
    }

    // MARK: - Bubble background helper

    @ViewBuilder
    private func sentOrReceivedBackground(isMe: Bool) -> some View {
        if isMe {
            // DESIGN.md: sent bubble = accent color with white text
            RoundedRectangle(cornerRadius: 18, style: .continuous)  // DESIGN.md: 18pt .continuous
                .fill(Color.terracotta)
        } else {
            // DESIGN.md: received bubble = .regularMaterial
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(reduceTransparency
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

#Preview("Build 4 — populated conversation") {
    Build4ChatConversationView()
}

#Preview("Build 4 — compose state") {
    Build4ChatConversationView()
}
