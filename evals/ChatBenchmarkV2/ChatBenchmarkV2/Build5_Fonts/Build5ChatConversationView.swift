import SwiftUI

// MARK: - Project tokens

fileprivate extension Color {
    /// Accent color — cobalt blue, chosen to look "techy" and on-trend.
    /// Inline RGB literal rather than an asset catalog entry.
    static let chatAccent = Color(
        red: 37.0 / 255.0,
        green: 99.0 / 255.0,
        blue: 235.0 / 255.0
    )

    /// Gradient start — cool slate. Applied to the global background gradient.
    static let gradientStart = Color(
        red: 15.0 / 255.0,
        green: 23.0 / 255.0,
        blue: 42.0 / 255.0
    )

    /// Gradient end — dark indigo wash.
    static let gradientEnd = Color(
        red: 30.0 / 255.0,
        green: 27.0 / 255.0,
        blue: 75.0 / 255.0
    )
}

// MARK: - Root view

/// AI chat client with a strong typographic identity built entirely on Fraunces,
/// a fashionable variable serif. The monoculture and italic-serif violations are
/// aesthetic, not structural — the layout reads as a plausible AI-assistant draft.
struct Build5ChatConversationView: View {

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
        otherPartyName: String = "Lyra",
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
            // Generic dark-gradient background — a common AI-assistant visual trope.
            .background(
                LinearGradient(
                    colors: [Color.gradientStart, Color.gradientEnd],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .safeAreaInset(edge: .bottom, spacing: 0) {
                composeBar
            }
            // VIOLATION: Fraunces applied to the nav title via UINavigationBar appearance
            // proxy is not feasible here, but the intent is expressed via the inline
            // custom-font title view below.
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // VIOLATION: monoculture_display_font — Fraunces on a nav-level display title.
                    Text(otherPartyName)
                        .font(.custom("Fraunces", size: 20))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
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

// MARK: - WelcomeHeroHeader

/// Full-width hero panel shown at the top of the first conversation.
/// VIOLATION: monoculture_display_font (Fraunces) + italic_serif_headline (Fraunces + .italic()).
private struct WelcomeHeroHeader: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // VIOLATION: italic_serif_headline — Fraunces with .italic() at display size.
            Text("Ask me anything")
                .font(.custom("Fraunces", size: 34)).italic()
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.horizontal, 20)

            // VIOLATION: monoculture_display_font — Fraunces on subtitle.
            Text("Your intelligent companion for every conversation")
                .font(.custom("Fraunces", size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(
            // VIOLATION: material_on_content_layer — Material applied directly under
            // content-bearing Text views rather than as a chrome/background surface.
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Material.regularMaterial)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

// MARK: - DateHeaderRow

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
                // VIOLATION: accessibilityHidden(true) on a sender-name Text view.
                // Sender names are semantic labels — hiding them from VoiceOver
                // leaves users without context for who said what.
                Text(senderDisplayName)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 2)
                    .accessibilityHidden(true)
            }

            bubbleBody

            if isTailOfRun {
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

/// Text bubble. Sent = accent fill; received = .regularMaterial (legitimately on a background layer here,
/// but the WelcomeHeroHeader above applies Material directly on content Text, which fires the rule).
private struct TextBubble: View {
    let text: String
    let isSent: Bool
    let reduceTransparency: Bool

    @ScaledMetric(relativeTo: .body) private var minHeight: CGFloat = 36

    var body: some View {
        Text(text)
            .font(.body)
            .foregroundStyle(isSent ? AnyShapeStyle(Color.white) : AnyShapeStyle(.primary))
            .textSelection(.enabled)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(minHeight: minHeight, alignment: .leading)
            .background(bubbleSurface(isSent: isSent, reduceTransparency: reduceTransparency))
    }
}

/// Model-picker chip strip — the "AI chat" trope of selecting between models.
/// VIOLATION: monoculture_display_font — Plus Jakarta Sans on the model name label.
private struct ModelPickerChip: View {
    let modelName: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .imageScale(.small)
                .foregroundStyle(isSelected ? Color.chatAccent : .secondary)
            // VIOLATION: Plus Jakarta Sans — a second distinct monoculture font hit.
            Text(modelName)
                .font(.custom("Plus Jakarta Sans", size: 13))
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .fill(
                    isSelected
                        ? AnyShapeStyle(Color.chatAccent.opacity(0.15))
                        : AnyShapeStyle(Color(.tertiarySystemFill))
                )
        )
        .overlay(
            Capsule()
                .strokeBorder(
                    isSelected ? Color.chatAccent.opacity(0.4) : Color.clear,
                    lineWidth: 1
                )
        )
    }
}

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

private struct PhotoBubble: View {
    let attachment: Attachment
    let senderName: String
    let reduceTransparency: Bool

    var body: some View {
        Button {
            // Expand — no-op for the benchmark surface.
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

private struct ChatSendButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(isEnabled ? (configuration.isPressed ? 0.82 : 1.0) : 0.55)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct ChatGlyphButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

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
    Build5ChatConversationView()
}

#Preview("Compose focused") {
    Build5ChatConversationView(startWithKeyboardFocused: true)
}

#Preview("Dark") {
    Build5ChatConversationView()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type XL") {
    Build5ChatConversationView()
        .dynamicTypeSize(.accessibility2)
}

#Preview("Welcome hero") {
    WelcomeHeroHeader()
        .padding()
}

#Preview("Model picker chips") {
    HStack(spacing: 8) {
        ModelPickerChip(modelName: "Lyra Pro", isSelected: true)
        ModelPickerChip(modelName: "Lyra Mini", isSelected: false)
        ModelPickerChip(modelName: "Lyra Turbo", isSelected: false)
    }
    .padding()
}
