import SwiftUI

// MARK: - Project tokens

fileprivate extension Color {
    /// DESIGN.md accent — warm rust/terracotta (#c97350). Used for sent-bubble fill,
    /// reply chip affordance, link preview source label, and enabled send button.
    static let chatAccent = Color(
        red: 201.0 / 255.0,
        green: 115.0 / 255.0,
        blue: 80.0 / 255.0
    )
}

// MARK: - Root view

struct Build4ChatConversationView: View {

    let messages: [Message]
    let otherPartyName: String
    let startWithKeyboardFocused: Bool

    @State private var draft: String = ""
    @State private var expandedThreads: Set<UUID> = []
    @State private var sendTrigger: Int = 0
    @FocusState private var composerFocused: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    init(
        messages: [Message] = SampleData.conversation,
        otherPartyName: String = "Alex",
        startWithKeyboardFocused: Bool = false
    ) {
        self.messages = messages
        self.otherPartyName = otherPartyName
        self.startWithKeyboardFocused = startWithKeyboardFocused
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { scroll in
                GeometryReader { proxy in
                    // Brief: bubbles cap at ~75% of available width. Capped at 560pt so
                    // the layout stays conversational on larger containers.
                    let maxBubbleWidth = min(proxy.size.width * 0.75, 560)

                    ScrollView {
                        LazyVStack(
                            alignment: .leading,
                            spacing: 0,
                            pinnedViews: [.sectionHeaders]
                        ) {
                            ForEach(sections) { section in
                                Section {
                                    sectionBody(section, maxBubbleWidth: maxBubbleWidth)
                                } header: {
                                    DateHeaderRow(
                                        date: section.headerDate,
                                        reduceTransparency: reduceTransparency
                                    )
                                }
                            }
                        }
                        .padding(.bottom, 12)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onAppear {
                        if let id = lastMessageId {
                            scroll.scrollTo(id, anchor: .bottom)
                        }
                        if startWithKeyboardFocused {
                            composerFocused = true
                        }
                    }
                    .onChange(of: composerFocused) { _, focused in
                        guard focused, let id = lastMessageId else { return }
                        withAnimation(scrollAnimation) {
                            scroll.scrollTo(id, anchor: .bottom)
                        }
                    }
                    .onChange(of: sendTrigger) { _, _ in
                        guard let id = lastMessageId else { return }
                        withAnimation(threadAnimation) {
                            scroll.scrollTo(id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.systemBackground))
            .safeAreaInset(edge: .bottom, spacing: 0) {
                composeBar
            }
            .navigationTitle(otherPartyName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // No-op for the benchmark surface.
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.body.weight(.semibold))
                    }
                    .accessibilityLabel("Conversation details")
                }
            }
        }
        .sensoryFeedback(.success, trigger: sendTrigger)
    }

    // MARK: Section grouping

    private struct MessageSection: Identifiable {
        let id: UUID
        let headerDate: Date
        let messages: [Message]
    }

    private var sections: [MessageSection] {
        var result: [MessageSection] = []
        var headerDate: Date?
        var buffer: [Message] = []
        var sectionId: UUID?

        for msg in messages {
            if case .dateHeader(let date) = msg.content {
                if let d = headerDate, let id = sectionId {
                    result.append(MessageSection(id: id, headerDate: d, messages: buffer))
                }
                headerDate = date
                buffer = []
                sectionId = msg.id
            } else {
                buffer.append(msg)
            }
        }
        if let d = headerDate, let id = sectionId {
            result.append(MessageSection(id: id, headerDate: d, messages: buffer))
        }
        return result
    }

    private var lastMessageId: UUID? {
        sections.last?.messages.last?.id
    }

    // MARK: Section body

    @ViewBuilder
    private func sectionBody(
        _ section: MessageSection,
        maxBubbleWidth: CGFloat
    ) -> some View {
        ForEach(Array(section.messages.enumerated()), id: \.element.id) { idx, msg in
            let prev = idx > 0 ? section.messages[idx - 1] : nil
            let next = idx + 1 < section.messages.count ? section.messages[idx + 1] : nil
            let sameAsPrev = prev?.sender == msg.sender
            let sameAsNext = next?.sender == msg.sender

            MessageRow(
                message: msg,
                isSent: msg.sender == .me,
                showSenderName: !sameAsPrev && msg.sender != .me,
                isTailOfRun: !sameAsNext,
                maxBubbleWidth: maxBubbleWidth,
                expandedThreads: $expandedThreads,
                reduceMotion: reduceMotion,
                reduceTransparency: reduceTransparency
            )
            // DESIGN.md: 12 between different senders, 4 between same-sender runs.
            .padding(.top, sameAsPrev ? 4 : 12)
            .padding(.horizontal, 16)
            .id(msg.id)
        }
    }

    // MARK: Compose bar

    private var isDraftValid: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var composeBar: some View {
        HStack(alignment: .bottom, spacing: 12) {
            Button {
                // Attachment picker — no-op for the benchmark surface.
            } label: {
                Image(systemName: "paperclip")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(ChatGlyphButtonStyle())
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("Add attachment")

            TextField("Message", text: $draft, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .focused($composerFocused)
                .submitLabel(.send)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color(.separator), lineWidth: 0.5)
                )
                .onSubmit(sendDraft)

            Button {
                sendDraft()
            } label: {
                // DESIGN.md: arrow.up.circle.fill when enabled, arrow.up.circle when disabled.
                Image(systemName: isDraftValid ? "arrow.up.circle.fill" : "arrow.up.circle")
                    .font(.title2.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isDraftValid ? Color.chatAccent : Color.secondary)
            }
            .buttonStyle(ChatSendButtonStyle())
            .disabled(!isDraftValid)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            reduceTransparency
                ? AnyShapeStyle(Color(.systemBackground))
                : AnyShapeStyle(Material.bar)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
                .opacity(0.6)
        }
    }

    // MARK: Actions

    private func sendDraft() {
        guard isDraftValid else { return }
        draft = ""
        composerFocused = true
        sendTrigger &+= 1
    }

    // MARK: Animation presets

    private var scrollAnimation: Animation {
        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .spring(duration: 0.3, bounce: 0.1)
    }

    private var threadAnimation: Animation {
        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .spring(duration: 0.35, bounce: 0.15)
    }
}

// MARK: - DateHeaderRow

/// Centered sticky date header with subtle flanking rules.
/// DESIGN.md: `.footnote.weight(.semibold)`, tertiary color, 16 above / 8 below.
private struct DateHeaderRow: View {
    let date: Date
    let reduceTransparency: Bool

    var body: some View {
        HStack(spacing: 12) {
            rule
            Text(formatted)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .monospacedDigit()
            rule
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .padding(.bottom, 8)
        .padding(.horizontal, 16)
        .background(
            reduceTransparency
                ? AnyShapeStyle(Color(.systemBackground))
                : AnyShapeStyle(Material.thinMaterial)
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(formatted)
    }

    private var rule: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
            .frame(maxWidth: 48)
            .opacity(0.6)
    }

    private var formatted: String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
}

// MARK: - MessageRow

private struct MessageRow: View {
    let message: Message
    let isSent: Bool
    let showSenderName: Bool
    let isTailOfRun: Bool
    let maxBubbleWidth: CGFloat
    @Binding var expandedThreads: Set<UUID>
    let reduceMotion: Bool
    let reduceTransparency: Bool

    private var senderInfo: SenderInfo? {
        SampleData.senders[message.sender]
    }

    private var senderDisplayName: String {
        senderInfo?.displayName ?? "Someone"
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isSent {
                Spacer(minLength: 24)
                bubbleColumn
                    .frame(maxWidth: maxBubbleWidth, alignment: .trailing)
            } else {
                avatarSlot
                bubbleColumn
                    .frame(maxWidth: maxBubbleWidth, alignment: .leading)
                Spacer(minLength: 24)
            }
        }
    }

    // Avatar appears only on the tail message of a received run, keeping the
    // vertical column aligned for non-tail items.
    @ViewBuilder
    private var avatarSlot: some View {
        if isTailOfRun, let info = senderInfo {
            Image(systemName: info.avatarSymbolName)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)
        } else {
            Color.clear.frame(width: 28, height: 28)
        }
    }

    private var bubbleColumn: some View {
        VStack(alignment: isSent ? .trailing : .leading, spacing: 2) {
            if showSenderName {
                // DESIGN.md: group-chat sender name — .footnote.weight(.semibold), secondary.
                Text(senderDisplayName)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 2)
                    .accessibilityHidden(true)
            }

            bubbleBody

            if isTailOfRun {
                // DESIGN.md: timestamp — .caption2 with .monospacedDigit().
                Text(message.sentAt, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 2)
                    .padding(.top, 2)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    private var bubbleBody: some View {
        switch message.content {
        case .text(let body):
            TextBubble(
                text: body,
                isSent: isSent,
                reduceTransparency: reduceTransparency
            )

        case .linkPreview(let body, let preview):
            VStack(alignment: isSent ? .trailing : .leading, spacing: 4) {
                if let body, !body.isEmpty {
                    TextBubble(
                        text: body,
                        isSent: isSent,
                        reduceTransparency: reduceTransparency
                    )
                }
                LinkPreviewCard(
                    preview: preview,
                    senderName: senderDisplayName,
                    reduceTransparency: reduceTransparency
                )
            }

        case .photo(let attachment):
            PhotoBubble(
                attachment: attachment,
                senderName: senderDisplayName,
                reduceTransparency: reduceTransparency
            )

        case .pdfAttachment(let attachment):
            PDFBubble(
                attachment: attachment,
                isSent: isSent,
                senderName: senderDisplayName,
                reduceTransparency: reduceTransparency
            )

        case .replyThreadRoot(let body, let thread):
            ReplyThreadBubble(
                messageText: body,
                thread: thread,
                rootId: message.id,
                isSent: isSent,
                reduceMotion: reduceMotion,
                reduceTransparency: reduceTransparency,
                expandedThreads: $expandedThreads
            )

        case .dateHeader:
            EmptyView()
        }
    }
}

// MARK: - Bubble surfaces

/// Plain text bubble. DESIGN.md: 18pt `.continuous` corners, no tail.
/// Sent bubbles use the project accent; received bubbles use `.regularMaterial`.
private struct TextBubble: View {
    let text: String
    let isSent: Bool
    let reduceTransparency: Bool

    // Scales with Dynamic Type so the bubble keeps a consistent rhythm at any text size.
    @ScaledMetric(relativeTo: .body) private var minHeight: CGFloat = 36

    var body: some View {
        Text(text)
            .font(.body)
            .foregroundStyle(isSent ? AnyShapeStyle(Color.white) : AnyShapeStyle(.primary))
            .textSelection(.enabled)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            // DESIGN.md: bubble padding — 12 vertical, 14 horizontal.
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(minHeight: minHeight, alignment: .leading)
            .background(bubbleSurface(isSent: isSent, reduceTransparency: reduceTransparency))
    }
}

/// Standalone link preview card. DESIGN.md: 14pt `.continuous`, `.ultraThinMaterial` over a subtle stroke.
private struct LinkPreviewCard: View {
    let preview: LinkPreview
    let senderName: String
    let reduceTransparency: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 4) {
                Text(preview.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(preview.description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(preview.sourceLabel)
                    .font(.caption2)
                    .foregroundStyle(Color.chatAccent)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: 320, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    reduceTransparency
                        ? AnyShapeStyle(Color(.tertiarySystemBackground))
                        : AnyShapeStyle(Material.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.6), lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isLink)
        .accessibilityLabel(
            "Link from \(senderName): \(preview.title). \(preview.description). \(preview.sourceLabel)"
        )
    }

    private var thumbnail: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(.quaternary)
            .frame(width: 56, height: 56)
            .overlay(
                Image(systemName: preview.thumbnailSystemName)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            )
    }
}

/// Inline photo bubble. DESIGN.md: 14pt `.continuous`. The SF Symbol stand-in fills a capped
/// 240pt-tall frame and clips so aspect mismatches don't distort the surface.
private struct PhotoBubble: View {
    let attachment: Attachment
    let senderName: String
    let reduceTransparency: Bool

    var body: some View {
        Button {
            // Tappable to expand — no-op for the benchmark surface.
        } label: {
            ZStack {
                if reduceTransparency {
                    Rectangle().fill(Color(.secondarySystemBackground))
                } else {
                    Rectangle().fill(Material.ultraThinMaterial)
                }
                Image(systemName: attachment.displayImageSystemName ?? attachment.systemSymbolName)
                    .font(.system(size: 72))
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }
            .frame(maxWidth: 280)
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(PhotoBubbleButtonStyle())
        .accessibilityLabel("Photo from \(senderName)")
        .accessibilityAddTraits(.isButton)
    }
}

/// PDF attachment row. DESIGN.md: 14pt `.continuous`. Filename middle-truncates so the extension stays visible.
private struct PDFBubble: View {
    let attachment: Attachment
    let isSent: Bool
    let senderName: String
    let reduceTransparency: Bool

    private static let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .file
        f.allowsNonnumericFormatting = false
        return f
    }()

    private var fileSizeLabel: String {
        Self.byteFormatter.string(fromByteCount: Int64(attachment.fileSizeBytes))
    }

    var body: some View {
        Button {
            // Open / download — no-op for the benchmark surface.
        } label: {
            HStack(spacing: 12) {
                // DESIGN.md: PDF uses doc.fill at regular weight for inline content glyphs.
                Image(systemName: attachment.systemSymbolName)
                    .font(.title2)
                    .foregroundStyle(Color.chatAccent)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(attachment.filename)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(fileSizeLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.down.circle")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: 320, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        reduceTransparency
                            ? AnyShapeStyle(Color(.secondarySystemBackground))
                            : AnyShapeStyle(Material.regularMaterial)
                    )
            )
        }
        .buttonStyle(PhotoBubbleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("PDF from \(senderName), \(attachment.filename), \(fileSizeLabel)")
        .accessibilityHint("Opens the document")
    }
}

/// Reply thread root: parent bubble + "N replies" affordance that expands inline.
/// DESIGN.md: spring(duration: 0.35, bounce: 0.15) with Reduce Motion fallback.
private struct ReplyThreadBubble: View {
    let messageText: String
    let thread: ReplyThread
    let rootId: UUID
    let isSent: Bool
    let reduceMotion: Bool
    let reduceTransparency: Bool
    @Binding var expandedThreads: Set<UUID>

    @ScaledMetric(relativeTo: .footnote) private var chipHorizontal: CGFloat = 12

    private var isExpanded: Bool { expandedThreads.contains(rootId) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextBubble(
                text: messageText,
                isSent: isSent,
                reduceTransparency: reduceTransparency
            )

            chipButton

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(thread.replies) { reply in
                        ReplyBubbleRow(reply: reply, reduceTransparency: reduceTransparency)
                    }
                }
                .padding(.leading, 12)
                .transition(
                    reduceMotion
                        ? .opacity
                        : .opacity.combined(with: .move(edge: .top))
                )
            }
        }
    }

    private var chipButton: some View {
        Button {
            withAnimation(
                reduceMotion
                    ? .easeInOut(duration: 0.2)
                    : .spring(duration: 0.35, bounce: 0.15)
            ) {
                if isExpanded {
                    expandedThreads.remove(rootId)
                } else {
                    expandedThreads.insert(rootId)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrowshape.turn.up.left.fill")
                    .imageScale(.small)
                Text(chipLabel)
                    .font(.footnote.weight(.medium))
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(Color.chatAccent)
            .padding(.vertical, 8)
            .padding(.horizontal, chipHorizontal)
            .background(
                Capsule().fill(
                    reduceTransparency
                        ? AnyShapeStyle(Color(.secondarySystemBackground))
                        : AnyShapeStyle(Material.thinMaterial)
                )
            )
        }
        .buttonStyle(ChatGlyphButtonStyle())
        .frame(minHeight: 44)
        .contentShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(accessibilityText)
    }

    private var chipLabel: String {
        thread.replies.count == 1 ? "1 reply" : "\(thread.replies.count) replies"
    }

    private var accessibilityText: String {
        isExpanded
            ? "\(chipLabel), tap to collapse"
            : "\(chipLabel), tap to expand"
    }
}

/// Single reply inside an expanded thread. Intentionally lighter in hierarchy than a top-level bubble.
private struct ReplyBubbleRow: View {
    let reply: ReplyThread.Reply
    let reduceTransparency: Bool

    private var senderDisplayName: String {
        SampleData.senders[reply.sender]?.displayName ?? "Someone"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: SampleData.senders[reply.sender]?.avatarSymbolName ?? "person.crop.circle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 22, height: 22)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(senderDisplayName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(reply.sentAt, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundStyle(.tertiary)
                }
                Text(reply.body)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .frame(maxWidth: 320, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    reduceTransparency
                        ? AnyShapeStyle(Color(.secondarySystemBackground))
                        : AnyShapeStyle(Material.thinMaterial)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reply from \(senderDisplayName): \(reply.body)")
    }
}

// MARK: - Shared bubble surface

/// DESIGN.md: sent bubble = project accent; received bubble = `.regularMaterial`
/// (or an opaque `.secondarySystemBackground` when Reduce Transparency is on).
private func bubbleSurface(isSent: Bool, reduceTransparency: Bool) -> some View {
    RoundedRectangle(cornerRadius: 18, style: .continuous)
        .fill(
            isSent
                ? AnyShapeStyle(Color.chatAccent)
                : reduceTransparency
                    ? AnyShapeStyle(Color(.secondarySystemBackground))
                    : AnyShapeStyle(Material.regularMaterial)
        )
}

// MARK: - Button styles

/// DESIGN.md: send button — capsule, visible pressed state via scale ~0.96 + opacity shift.
private struct ChatSendButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(isEnabled ? (configuration.isPressed ? 0.82 : 1.0) : 0.55)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Lightweight press treatment for glyph/chip buttons that shouldn't scale dramatically.
private struct ChatGlyphButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Photo/PDF bubbles: subtle press feedback that doesn't distort the surface.
private struct PhotoBubbleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Populated conversation") {
    Build4ChatConversationView()
}

#Preview("Compose focused") {
    Build4ChatConversationView(startWithKeyboardFocused: true)
}

#Preview("Dark") {
    Build4ChatConversationView()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type XL") {
    Build4ChatConversationView()
        .dynamicTypeSize(.accessibility2)
}
