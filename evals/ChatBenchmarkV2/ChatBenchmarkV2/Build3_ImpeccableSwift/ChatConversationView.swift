import SwiftUI

// Chat conversation for ChatBenchmarkV2, Build 3 (impeccable-swift).
// Decisions trace to the reference docs — not to trained SwiftUI reflex.

struct Build3ChatConversationView: View {

    // MARK: - Input

    var messages: [Message]
    var initialDraft: String

    // MARK: - State

    @State private var draft: String
    @State private var sendPulse: Int = 0
    @FocusState private var composeFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(messages: [Message] = SampleData.conversation, initialDraft: String = "") {
        self.messages = messages
        self.initialDraft = initialDraft
        _draft = State(initialValue: initialDraft)
    }

    // MARK: - Derived sections

    private struct DateSection: Identifiable {
        let id: Date
        let date: Date
        let rows: [Message]
    }

    private var sections: [DateSection] {
        var result: [DateSection] = []
        var currentDate: Date? = nil
        var currentRows: [Message] = []

        func flush() {
            if let date = currentDate, !currentRows.isEmpty {
                result.append(DateSection(id: date, date: date, rows: currentRows))
            }
        }

        for message in messages {
            if case .dateHeader(let date) = message.content {
                flush()
                currentDate = date
                currentRows = []
            } else {
                if currentDate == nil { currentDate = message.sentAt }
                currentRows.append(message)
            }
        }
        flush()
        return result
    }

    private var partner: SenderInfo? { SampleData.senders[.alex] }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    // spatial-design.md: 4pt scale — 16pt for row rhythm, 12pt for top breathing room.
                    // pinnedViews makes date headers float above messages on scroll without a List.
                    LazyVStack(alignment: .leading, spacing: 12, pinnedViews: [.sectionHeaders]) {
                        ForEach(sections) { section in
                            Section {
                                ForEach(section.rows) { message in
                                    MessageRow(message: message, reduceMotion: reduceMotion)
                                        .id(message.id)
                                        .padding(.horizontal, 16)
                                }
                            } header: {
                                DateHeader(date: section.date)
                            }
                        }
                        Color.clear
                            .frame(height: 1)
                            .id(Self.scrollAnchor)
                    }
                    .padding(.vertical, 12)
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    proxy.scrollTo(Self.scrollAnchor, anchor: .bottom)
                }
                .onChange(of: messages.count) { _, _ in
                    // motion-design.md: cross-fade when reduceMotion is true, spring otherwise.
                    withAnimation(reduceMotion ? .easeOut(duration: 0.2)
                                               : .spring(response: 0.35, dampingFraction: 0.85)) {
                        proxy.scrollTo(Self.scrollAnchor, anchor: .bottom)
                    }
                }
                .onChange(of: composeFocused) { _, focused in
                    guard focused else { return }
                    withAnimation(reduceMotion ? .easeOut(duration: 0.2)
                                               : .spring(response: 0.35, dampingFraction: 0.85)) {
                        proxy.scrollTo(Self.scrollAnchor, anchor: .bottom)
                    }
                }
            }
            .navigationTitle(partner?.displayName ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ChatTitle(partner: partner)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // intentional no-op in the benchmark
                    } label: {
                        Image(systemName: "phone")
                    }
                    .accessibilityLabel("Start a call")
                }
            }
            // navigation.md: pin the compose bar via .safeAreaInset — never hardcode bottom padding.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                ComposeBar(
                    text: $draft,
                    focused: $composeFocused,
                    onSend: send
                )
            }
            // interaction-design.md: .success is an outcome signal, not decoration.
            .sensoryFeedback(.success, trigger: sendPulse)
        }
    }

    private static let scrollAnchor = "chat.bottom.sentinel"

    private func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        draft = ""
        sendPulse &+= 1
    }
}

// MARK: - Title

private struct ChatTitle: View {
    let partner: SenderInfo?

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: partner?.avatarSymbolName ?? "person.crop.circle")
                .font(.title3)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(partner?.displayName ?? "Chat")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("Active now")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Date header (sticky)

private struct DateHeader: View {
    let date: Date

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Text(label)
                // typography.md: footnote semibold for section landmarks; monospacedDigit keeps
                // "Apr 15" and date numerals steady across locales.
                .font(.footnote.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                // materials.md: thin material for subtle separation, not a full Divider().
                .background(.thinMaterial, in: Capsule())
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }

    private var label: String {
        let calendar = Calendar.current
        let now = Date()
        if calendar.isDate(date, inSameDayAs: now) { return "Today" }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) { return "Yesterday" }
        return date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
}

// MARK: - Message row

private struct MessageRow: View {
    let message: Message
    let reduceMotion: Bool

    private var isSent: Bool { message.sender == .me }
    private var senderInfo: SenderInfo? { SampleData.senders[message.sender] }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isSent {
                // spatial-design.md: Spacer(minLength:) acts as the bubble max-width constraint
                // instead of reading UIScreen bounds — survives Split View, Stage Manager, Dynamic Type.
                Spacer(minLength: 56)
                bubble
            } else {
                avatar
                bubble
                Spacer(minLength: 56)
            }
        }
    }

    private var avatar: some View {
        Image(systemName: senderInfo?.avatarSymbolName ?? "person.crop.circle")
            .font(.title2)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.secondary)
            .frame(width: 32, height: 32)
            .accessibilityHidden(true)
    }

    @ViewBuilder private var bubble: some View {
        switch message.content {
        case .text(let text):
            TextBubble(text: text, sentAt: message.sentAt, isSent: isSent, senderName: senderInfo?.displayName)
        case .linkPreview(let bodyText, let preview):
            LinkPreviewBubble(bodyText: bodyText, preview: preview, sentAt: message.sentAt, isSent: isSent, senderName: senderInfo?.displayName)
        case .photo(let attachment):
            PhotoBubble(attachment: attachment, sentAt: message.sentAt, isSent: isSent, senderName: senderInfo?.displayName)
        case .pdfAttachment(let attachment):
            PDFAttachmentBubble(attachment: attachment, sentAt: message.sentAt, isSent: isSent, senderName: senderInfo?.displayName)
        case .replyThreadRoot(let bodyText, let thread):
            ReplyThreadBubble(bodyText: bodyText, thread: thread, sentAt: message.sentAt, isSent: isSent, senderName: senderInfo?.displayName, reduceMotion: reduceMotion)
        case .dateHeader:
            EmptyView()
        }
    }
}

// MARK: - Bubble surface

private struct BubbleSurface<Content: View>: View {
    let isSent: Bool
    @ViewBuilder let content: Content

    // materials.md: continuous corner style — squircle, not the default circular arc.
    private let radius: CGFloat = 22

    var body: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                // color-and-contrast.md: sent bubble = accent wash over material, not hardcoded blue.
                // One material per surface (materials.md) — the accent tint layers with hierarchical
                // shape style so it respects Dark Mode and contrast settings.
                ZStack {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(.regularMaterial)
                    if isSent {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .fill(Color.accentColor.opacity(0.22))
                    }
                }
            }
    }
}

// MARK: - Timestamp

private struct Timestamp: View {
    let date: Date

    var body: some View {
        // typography.md: caption2 monospacedDigit — numerals don't reflow as time ticks.
        Text(date.formatted(date: .omitted, time: .shortened))
            .font(.caption2)
            .monospacedDigit()
            .foregroundStyle(.tertiary)
    }
}

// MARK: - Sender label (received bubbles only)

private struct SenderBadge: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }
}

// MARK: - Text bubble

private struct TextBubble: View {
    let text: String
    let sentAt: Date
    let isSent: Bool
    let senderName: String?

    var body: some View {
        BubbleSurface(isSent: isSent) {
            VStack(alignment: isSent ? .trailing : .leading, spacing: 4) {
                if !isSent, let senderName {
                    SenderBadge(name: senderName)
                }
                Text(text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: isSent ? .trailing : .leading)
                    .multilineTextAlignment(isSent ? .trailing : .leading)
                Timestamp(date: sentAt)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(senderName ?? (isSent ? "Me" : "Them")). \(text)"))
    }
}

// MARK: - Link preview bubble

private struct LinkPreviewBubble: View {
    let bodyText: String?
    let preview: LinkPreview
    let sentAt: Date
    let isSent: Bool
    let senderName: String?

    var body: some View {
        VStack(alignment: isSent ? .trailing : .leading, spacing: 6) {
            if !isSent, let senderName {
                SenderBadge(name: senderName)
                    .padding(.horizontal, 4)
            }
            if let bodyText, !bodyText.isEmpty {
                BubbleSurface(isSent: isSent) {
                    Text(bodyText)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            linkCard
            Timestamp(date: sentAt)
                .padding(.horizontal, 4)
        }
        .accessibilityElement(children: .contain)
    }

    private var linkCard: some View {
        HStack(alignment: .top, spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.35), Color.accentColor.opacity(0.14)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: preview.thumbnailSystemName)
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
            }
            .frame(width: 88)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(preview.sourceLabel)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(preview.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(preview.description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: 320)
        .background(.regularMaterial)
        // materials.md: continuous radius, concentric — outer 18 with 0 padding wraps cleanly.
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        // accessibility.md: use .isLink so VoiceOver announces navigation affordance.
        .accessibilityAddTraits(.isLink)
        .accessibilityLabel(Text("Link. \(preview.title). \(preview.description). From \(preview.sourceLabel)."))
        .accessibilityHint(Text("Opens the article"))
    }
}

// MARK: - Photo bubble

private struct PhotoBubble: View {
    let attachment: Attachment
    let sentAt: Date
    let isSent: Bool
    let senderName: String?

    var body: some View {
        VStack(alignment: isSent ? .trailing : .leading, spacing: 6) {
            if !isSent, let senderName {
                SenderBadge(name: senderName)
                    .padding(.horizontal, 4)
            }
            photoSurface
                // brief-04: constrain photo to a max height with scaledToFill semantics.
                .frame(maxWidth: 280)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            Timestamp(date: sentAt)
                .padding(.horizontal, 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Photo from \(senderName ?? (isSent ? "me" : "them"))."))
        .accessibilityHint(Text("Opens the photo"))
    }

    private var photoSurface: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.45), Color.accentColor.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: attachment.displayImageSystemName ?? attachment.systemSymbolName)
                .font(.system(size: 56, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - PDF attachment bubble

private struct PDFAttachmentBubble: View {
    let attachment: Attachment
    let sentAt: Date
    let isSent: Bool
    let senderName: String?

    var body: some View {
        BubbleSurface(isSent: isSent) {
            VStack(alignment: isSent ? .trailing : .leading, spacing: 6) {
                if !isSent, let senderName {
                    SenderBadge(name: senderName)
                }
                HStack(alignment: .center, spacing: 12) {
                    // sf-symbols.md: hierarchical rendering across this bubble; doc.fill carries
                    // the filetype rather than a PNG.
                    Image(systemName: attachment.systemSymbolName)
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.tint)
                        .frame(width: 36, height: 44)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        // typography.md: truncationMode(.middle) keeps the extension visible.
                        Text(attachment.filename)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        HStack(spacing: 6) {
                            Text(formattedFileSize).monospacedDigit()
                            Text("·").foregroundStyle(.tertiary)
                            Text("PDF")
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }
                .frame(minWidth: 240)
                Timestamp(date: sentAt)
            }
        }
        // accessibility.md: .combine merges icon + filename + size into one VoiceOver stop.
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("PDF. \(attachment.filename). \(formattedFileSize)."))
        .accessibilityHint(Text("Opens the document"))
        .accessibilityAddTraits(.isButton)
    }

    private var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(attachment.fileSizeBytes), countStyle: .file)
    }
}

// MARK: - Reply thread bubble

private struct ReplyThreadBubble: View {
    let bodyText: String
    let thread: ReplyThread
    let sentAt: Date
    let isSent: Bool
    let senderName: String?
    let reduceMotion: Bool

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: isSent ? .trailing : .leading, spacing: 8) {
            BubbleSurface(isSent: isSent) {
                VStack(alignment: isSent ? .trailing : .leading, spacing: 4) {
                    if !isSent, let senderName {
                        SenderBadge(name: senderName)
                    }
                    Text(bodyText)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: isSent ? .trailing : .leading)
                    Timestamp(date: sentAt)
                }
            }

            disclosure

            if isExpanded {
                replyList
                    // motion-design.md: opacity-only transition when reduceMotion is on.
                    .transition(reduceMotion
                                ? .opacity
                                : .asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .opacity))
            }
        }
    }

    private var disclosure: some View {
        Button {
            withAnimation(reduceMotion ? .easeInOut(duration: 0.2)
                                       : .spring(response: 0.35, dampingFraction: 0.85)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isExpanded ? "chevron.down" : "arrowshape.turn.up.left.fill")
                    .font(.caption.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                Text(replyCountLabel)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
            }
            .foregroundStyle(.tint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.thinMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        // spatial-design.md: 44pt tap floor even when the visible capsule is smaller.
        .frame(minHeight: 44, alignment: isSent ? .trailing : .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(replyCountLabel))
        .accessibilityHint(Text(isExpanded ? "Collapses the thread" : "Expands the thread"))
        .accessibilityAddTraits(.isButton)
    }

    private var replyList: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(thread.replies) { reply in
                ReplyRow(reply: reply)
            }
        }
        .padding(.leading, 16)
        .overlay(alignment: .leading) {
            // Subtle vertical rule as the thread indent — dominant hierarchy cue, not decoration.
            Rectangle()
                .fill(.tint.opacity(0.4))
                .frame(width: 2)
                .padding(.vertical, 2)
        }
    }

    private var replyCountLabel: String {
        thread.replies.count == 1 ? "1 reply" : "\(thread.replies.count) replies"
    }
}

private struct ReplyRow: View {
    let reply: ReplyThread.Reply

    private var senderInfo: SenderInfo? { SampleData.senders[reply.sender] }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: senderInfo?.avatarSymbolName ?? "person.crop.circle")
                .font(.callout)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(senderInfo?.displayName ?? "")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(reply.sentAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .monospacedDigit()
                        .foregroundStyle(.tertiary)
                }
                Text(reply.body)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(senderInfo?.displayName ?? "Reply"). \(reply.body)"))
    }
}

// MARK: - Compose bar

private struct ComposeBar: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding
    let onSend: () -> Void

    // responsive-design.md: @ScaledMetric so the input well grows with Dynamic Type.
    @ScaledMetric private var fieldMinHeight: CGFloat = 40
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        // materials.md: GlassEffectContainer merges sibling glass surfaces into one coherent pane.
        // Reduce Transparency is honored automatically by the system material stack (accessibility.md).
        GlassEffectContainer {
            HStack(alignment: .bottom, spacing: 8) {
                Button {
                    // benchmark: surface exists, action is intentionally a no-op
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
                .accessibilityLabel("Add attachment")

                TextField("Message", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .font(.body)
                    .focused(focused)
                    .submitLabel(.send)
                    .onSubmit { if canSend { onSend() } }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(minHeight: fieldMinHeight)
                    // .quaternary is a hierarchical fill — respects Dark Mode + Reduce Transparency
                    // without hardcoding an opacity per color-and-contrast.md.
                    .background(.quaternary, in: Capsule())

                Button(action: onSend) {
                    Image(systemName: "arrow.up")
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(SendButtonStyle(isEnabled: canSend))
                .disabled(!canSend)
                .accessibilityLabel("Send message")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .glassEffect()
    }
}

// MARK: - Send button style

private struct SendButtonStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 40, height: 40)
            .background(
                Circle()
                    .fill(isEnabled ? Color.accentColor : Color.accentColor.opacity(0.35))
                    // interaction-design.md: pressed state must change at least two of opacity,
                    // scale, background fill, or elevation. Here: opacity + scale.
                    .opacity(configuration.isPressed ? 0.75 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Populated conversation") {
    Build3ChatConversationView()
}

#Preview("Compose focused (keyboard open)") {
    // Approximates the keyboard-up state: draft already entered, send enabled, field focused.
    KeyboardOpenPreview()
}

#Preview("Dark") {
    Build3ChatConversationView()
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type XL") {
    Build3ChatConversationView()
        .dynamicTypeSize(.accessibility2)
}

private struct KeyboardOpenPreview: View {
    @FocusState private var composeFocused: Bool

    var body: some View {
        Build3ChatConversationView(
            initialDraft: "sounds good — I'll cut a branch tonight and share the link."
        )
        // Visual stand-in for the keyboard — SwiftUI previews can't raise the actual keyboard,
        // so a safe-area inset approximates the available compose-bar region.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: 291)
        }
    }
}
