import SwiftUI

// MARK: - Design tokens
//
// Semantic, named tokens — the SwiftUI analog of CSS custom properties.
// Palette is a warm paper/moss scheme: cream background, deep moss for
// the brand (sent bubbles), warm ink for text. No pure black / white;
// all neutrals are tinted toward the brand hue for cohesion.

private enum Palette {
    static let background     = Color(red: 0.974, green: 0.962, blue: 0.938)
    static let surface        = Color(red: 0.988, green: 0.980, blue: 0.960)
    static let border         = Color(red: 0.820, green: 0.800, blue: 0.745)
    static let divider        = Color(red: 0.870, green: 0.852, blue: 0.800)
    static let textPrimary    = Color(red: 0.140, green: 0.150, blue: 0.125)
    static let textSecondary  = Color(red: 0.430, green: 0.435, blue: 0.390)
    static let textTertiary   = Color(red: 0.615, green: 0.600, blue: 0.545)
    static let brand          = Color(red: 0.265, green: 0.345, blue: 0.245)
    static let brandSoft      = Color(red: 0.902, green: 0.908, blue: 0.860)
    static let onBrand        = Color(red: 0.980, green: 0.972, blue: 0.928)
}

// 4pt spacing scale, semantic names (not pixel-named)
private enum Space {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
}

private enum Radius {
    static let sm:     CGFloat = 8
    static let md:     CGFloat = 12
    static let lg:     CGFloat = 20
    static let bubble: CGFloat = 18
}

// ease-out-quart / ease-out-quint — the web skill's recommended curves
private enum Motion {
    static let snap   = Animation.timingCurve(0.25, 1.0, 0.5,  1.0, duration: 0.15)
    static let base   = Animation.timingCurve(0.25, 1.0, 0.5,  1.0, duration: 0.30)
    static let layout = Animation.timingCurve(0.22, 1.0, 0.36, 1.0, duration: 0.42)
}

// MARK: - Date grouping

private struct DaySection: Identifiable {
    let date: Date
    let messages: [Message]
    var id: TimeInterval { date.timeIntervalSince1970 }
}

// MARK: - Root

struct Build2ChatConversationView: View {

    @State private var composeText: String = ""
    @State private var expandedThreadIDs: Set<UUID> = []
    @FocusState private var composeFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let messages: [Message]
    private let correspondent: SenderInfo

    init(messages: [Message] = SampleData.conversation) {
        self.messages = messages
        self.correspondent = SampleData.senders[.alex]
            ?? SenderInfo(sender: .alex, displayName: "Alex", avatarSymbolName: "person.crop.circle")
    }

    var body: some View {
        VStack(spacing: 0) {
            ConversationHeader(correspondent: correspondent)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(daySections) { section in
                            Section {
                                VStack(alignment: .leading, spacing: Space.md) {
                                    ForEach(Array(section.messages.enumerated()), id: \.element.id) { index, message in
                                        MessageRow(
                                            message: message,
                                            previousMessage: index > 0 ? section.messages[index - 1] : nil,
                                            expandedThreadIDs: $expandedThreadIDs,
                                            reduceMotion: reduceMotion
                                        )
                                        .id(message.id)
                                    }
                                }
                                .padding(.horizontal, Space.lg)
                                .padding(.top, Space.sm)
                                .padding(.bottom, Space.xl)
                            } header: {
                                DateHeaderView(date: section.date)
                            }
                        }
                    }
                }
                .background(Palette.background)
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    if let id = lastContentID {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
                .onChange(of: composeFocused) { _, focused in
                    guard focused, let id = lastContentID else { return }
                    withAnimation(reduceMotion ? nil : Motion.base) {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
                .onChange(of: messages.count) { _, _ in
                    guard let id = lastContentID else { return }
                    withAnimation(reduceMotion ? nil : Motion.base) {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Palette.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            ComposeBar(
                text: $composeText,
                focused: $composeFocused,
                onSend: { composeText = "" }
            )
        }
    }

    private var daySections: [DaySection] {
        var sections: [DaySection] = []
        var currentDate: Date?
        var bucket: [Message] = []
        for message in messages {
            if case .dateHeader(let date) = message.content {
                if let existing = currentDate {
                    sections.append(DaySection(date: existing, messages: bucket))
                }
                currentDate = date
                bucket = []
            } else {
                bucket.append(message)
            }
        }
        if let date = currentDate {
            sections.append(DaySection(date: date, messages: bucket))
        } else if !bucket.isEmpty {
            sections.append(DaySection(date: bucket.first?.sentAt ?? Date(), messages: bucket))
        }
        return sections
    }

    private var lastContentID: UUID? {
        messages.last {
            if case .dateHeader = $0.content { return false }
            return true
        }?.id
    }
}

// MARK: - Header

private struct ConversationHeader: View {
    let correspondent: SenderInfo

    var body: some View {
        HStack(alignment: .center, spacing: Space.md) {
            Button {
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Palette.textSecondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel("Back")

            Avatar(symbolName: correspondent.avatarSymbolName, size: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 1) {
                Text(correspondent.displayName)
                    .font(.headline)
                    .foregroundStyle(Palette.textPrimary)
                Text("Active now")
                    .font(.caption2)
                    .tracking(0.4)
                    .textCase(.uppercase)
                    .foregroundStyle(Palette.textSecondary)
            }

            Spacer(minLength: Space.sm)

            Button {
            } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(Palette.textSecondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel("Conversation details")
        }
        .padding(.horizontal, Space.md)
        .padding(.vertical, Space.sm)
        .background(.bar)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Palette.divider.opacity(0.6))
                .frame(height: 0.5)
        }
    }
}

// MARK: - Date header (sticky, subtle rule — not a full Divider())

private struct DateHeaderView: View {
    let date: Date

    private var label: String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(spacing: Space.md) {
            Rectangle()
                .fill(Palette.divider.opacity(0.7))
                .frame(height: 0.5)
            Text(label)
                .font(.footnote.weight(.semibold))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundStyle(Palette.textSecondary)
                .fixedSize(horizontal: true, vertical: false)
            Rectangle()
                .fill(Palette.divider.opacity(0.7))
                .frame(height: 0.5)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.md)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
    }
}

// MARK: - Message row (layout + avatar)

private struct MessageRow: View {
    let message: Message
    let previousMessage: Message?
    @Binding var expandedThreadIDs: Set<UUID>
    let reduceMotion: Bool

    private var isSent: Bool { message.sender == .me }
    private var senderInfo: SenderInfo {
        SampleData.senders[message.sender]
            ?? SenderInfo(sender: message.sender, displayName: "Unknown", avatarSymbolName: "person.crop.circle")
    }
    private var isContinuation: Bool {
        guard let previous = previousMessage else { return false }
        if case .dateHeader = previous.content { return false }
        return previous.sender == message.sender
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Space.sm) {
            if isSent {
                Spacer(minLength: Space.xl)
                MessageBubble(
                    message: message,
                    isSent: true,
                    senderInfo: senderInfo,
                    showsSenderName: false,
                    expandedThreadIDs: $expandedThreadIDs,
                    reduceMotion: reduceMotion
                )
            } else {
                if isContinuation {
                    Color.clear.frame(width: 32, height: 1)
                } else {
                    Avatar(symbolName: senderInfo.avatarSymbolName, size: 32)
                        .accessibilityHidden(true)
                }
                MessageBubble(
                    message: message,
                    isSent: false,
                    senderInfo: senderInfo,
                    showsSenderName: !isContinuation,
                    expandedThreadIDs: $expandedThreadIDs,
                    reduceMotion: reduceMotion
                )
                Spacer(minLength: Space.xl)
            }
        }
    }
}

// MARK: - Bubble container

private struct MessageBubble: View {
    let message: Message
    let isSent: Bool
    let senderInfo: SenderInfo
    let showsSenderName: Bool
    @Binding var expandedThreadIDs: Set<UUID>
    let reduceMotion: Bool

    private var timestampText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: message.sentAt)
    }

    private var bubbleMaxWidth: CGFloat {
        UIScreen.main.bounds.width * 0.75
    }

    var body: some View {
        VStack(alignment: isSent ? .trailing : .leading, spacing: Space.xs) {
            if showsSenderName && !isSent {
                Text(senderInfo.displayName)
                    .font(.caption.weight(.semibold))
                    .tracking(0.2)
                    .foregroundStyle(Palette.textSecondary)
                    .padding(.leading, Space.sm)
            }

            content

            Text(timestampText)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(Palette.textTertiary)
                .padding(.horizontal, Space.sm)
                .accessibilityLabel("Sent at \(timestampText)")
        }
        .frame(maxWidth: bubbleMaxWidth, alignment: isSent ? .trailing : .leading)
    }

    @ViewBuilder
    private var content: some View {
        switch message.content {
        case .text(let body):
            TextBubble(text: body, isSent: isSent)

        case .linkPreview(let body, let preview):
            VStack(alignment: isSent ? .trailing : .leading, spacing: Space.sm) {
                if let body, !body.isEmpty {
                    TextBubble(text: body, isSent: isSent)
                }
                LinkPreviewCard(preview: preview)
            }

        case .photo(let attachment):
            PhotoMessage(attachment: attachment, senderName: senderInfo.displayName)

        case .pdfAttachment(let attachment):
            PDFAttachmentCard(attachment: attachment, isSent: isSent)

        case .replyThreadRoot(let body, let thread):
            VStack(alignment: .leading, spacing: Space.sm) {
                TextBubble(text: body, isSent: isSent)
                ReplyThreadView(
                    thread: thread,
                    messageID: message.id,
                    expandedThreadIDs: $expandedThreadIDs,
                    reduceMotion: reduceMotion
                )
            }

        case .dateHeader:
            EmptyView()
        }
    }
}

// MARK: - Text bubble

private struct TextBubble: View {
    let text: String
    let isSent: Bool

    var body: some View {
        Text(text)
            .font(.system(.body, design: .serif))
            .foregroundStyle(isSent ? Palette.onBrand : Palette.textPrimary)
            .lineSpacing(2)
            .padding(.horizontal, Space.lg)
            .padding(.vertical, Space.md)
            .background {
                RoundedRectangle(cornerRadius: Radius.bubble, style: .continuous)
                    .fill(isSent ? AnyShapeStyle(Palette.brand) : AnyShapeStyle(.thinMaterial))
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.bubble, style: .continuous)
                    .stroke(Palette.divider.opacity(isSent ? 0 : 0.55), lineWidth: 0.5)
            }
            .textSelection(.enabled)
    }
}

// MARK: - Link preview card

private struct LinkPreviewCard: View {
    let preview: LinkPreview

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Palette.brandSoft
                Image(systemName: preview.thumbnailSystemName)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(Palette.brand.opacity(0.75))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 132)

            VStack(alignment: .leading, spacing: Space.xs) {
                Text(preview.sourceLabel)
                    .font(.caption2.weight(.semibold))
                    .tracking(1.4)
                    .textCase(.uppercase)
                    .foregroundStyle(Palette.textSecondary)

                Text(preview.title)
                    .font(.system(.subheadline, design: .serif).weight(.semibold))
                    .foregroundStyle(Palette.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(preview.description)
                    .font(.footnote)
                    .foregroundStyle(Palette.textSecondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(Space.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(.thinMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Palette.divider.opacity(0.6), lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isLink)
        .accessibilityLabel("\(preview.title). From \(preview.sourceLabel). \(preview.description)")
    }
}

// MARK: - Photo message

private struct PhotoMessage: View {
    let attachment: Attachment
    let senderName: String

    var body: some View {
        ZStack {
            Rectangle().fill(Palette.brandSoft)
            Image(systemName: attachment.displayImageSystemName ?? "photo")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Palette.brand.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Palette.divider.opacity(0.5), lineWidth: 0.5)
        }
        .accessibilityElement()
        .accessibilityLabel("Photo from \(senderName)")
        .accessibilityAddTraits(.isImage)
        .accessibilityHint("Double tap to expand")
    }
}

// MARK: - PDF attachment row

private struct PDFAttachmentCard: View {
    let attachment: Attachment
    let isSent: Bool

    private var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(attachment.fileSizeBytes))
    }

    var body: some View {
        HStack(alignment: .center, spacing: Space.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(Palette.brand.opacity(0.10))
                Image(systemName: attachment.systemSymbolName)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Palette.brand)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.filename)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(Palette.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(formattedSize)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(Palette.textSecondary)
            }

            Spacer(minLength: Space.sm)

            Button {
            } label: {
                Image(systemName: "arrow.down.circle")
                    .font(.title3)
                    .foregroundStyle(Palette.brand)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel("Download \(attachment.filename)")
        }
        .padding(Space.md)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .fill(.thinMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                .stroke(Palette.divider.opacity(0.55), lineWidth: 0.5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("PDF: \(attachment.filename), \(formattedSize)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Reply thread

private struct ReplyThreadView: View {
    let thread: ReplyThread
    let messageID: UUID
    @Binding var expandedThreadIDs: Set<UUID>
    let reduceMotion: Bool

    private var isExpanded: Bool { expandedThreadIDs.contains(messageID) }

    private var replyCountText: String {
        let count = thread.replies.count
        return "\(count) \(count == 1 ? "reply" : "replies")"
    }

    private var lastReplyTime: String {
        guard let last = thread.replies.last else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: last.sentAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Button {
                let anim: Animation? = reduceMotion ? nil : Motion.layout
                withAnimation(anim) {
                    if isExpanded {
                        expandedThreadIDs.remove(messageID)
                    } else {
                        expandedThreadIDs.insert(messageID)
                    }
                }
            } label: {
                HStack(spacing: Space.sm) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Palette.brand)

                    Text(replyCountText)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Palette.brand)

                    if !lastReplyTime.isEmpty && !isExpanded {
                        Text("Last reply \(lastReplyTime)")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(Palette.textSecondary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Palette.brand.opacity(0.7))
                }
                .padding(.horizontal, Space.md)
                .padding(.vertical, Space.sm)
                .background {
                    Capsule(style: .continuous)
                        .fill(Palette.brand.opacity(0.10))
                }
            }
            .buttonStyle(PressableStyle())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(replyCountText)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(isExpanded ? "Collapse thread" : "Expand thread")

            if isExpanded {
                VStack(alignment: .leading, spacing: Space.md) {
                    ForEach(thread.replies) { reply in
                        ReplyRow(reply: reply)
                    }
                }
                .padding(.leading, Space.lg)
                .padding(.top, Space.xs)
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .offset(y: -4)),
                        removal: .opacity
                    )
                )
            }
        }
    }
}

private struct ReplyRow: View {
    let reply: ReplyThread.Reply

    private var senderName: String {
        SampleData.senders[reply.sender]?.displayName ?? "Unknown"
    }

    private var timestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: reply.sentAt)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: Space.xs) {
                Text(senderName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Palette.textPrimary)
                Text(timestamp)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(Palette.textTertiary)
            }
            Text(reply.body)
                .font(.system(.footnote, design: .serif))
                .foregroundStyle(Palette.textPrimary)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(senderName), \(timestamp). \(reply.body)")
    }
}

// MARK: - Avatar

private struct Avatar: View {
    let symbolName: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(Palette.brandSoft)
            Image(systemName: symbolName)
                .font(.system(size: size * 0.55, weight: .regular))
                .foregroundStyle(Palette.brand.opacity(0.85))
        }
        .frame(width: size, height: size)
        .overlay {
            Circle().stroke(Palette.divider.opacity(0.6), lineWidth: 0.5)
        }
    }
}

// MARK: - Compose bar (pinned via .safeAreaInset)

private struct ComposeBar: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding
    let onSend: () -> Void

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Space.sm) {
            Button {
            } label: {
                Image(systemName: "paperclip")
                    .font(.title3)
                    .foregroundStyle(Palette.textSecondary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel("Add attachment")

            ComposeField(text: $text, focused: focused)

            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.callout.weight(.bold))
                    .foregroundStyle(canSend ? Palette.onBrand : Palette.textTertiary.opacity(0.85))
                    .frame(width: 36, height: 36)
                    .background {
                        Circle().fill(canSend ? AnyShapeStyle(Palette.brand) : AnyShapeStyle(Palette.brandSoft))
                    }
            }
            .buttonStyle(SendButtonStyle())
            .disabled(!canSend)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, Space.lg)
        .padding(.top, Space.md)
        .padding(.bottom, Space.md)
        .background(.bar)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Palette.divider.opacity(0.5))
                .frame(height: 0.5)
        }
    }
}

private struct ComposeField: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding

    var body: some View {
        TextField("Message", text: $text, axis: .vertical)
            .focused(focused)
            .font(.system(.body, design: .serif))
            .foregroundStyle(Palette.textPrimary)
            .tint(Palette.brand)
            .lineLimit(1...5)
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.sm)
            .frame(minHeight: 36)
            .background {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .fill(Palette.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                    .stroke(
                        focused.wrappedValue ? Palette.brand.opacity(0.45) : Palette.divider.opacity(0.7),
                        lineWidth: focused.wrappedValue ? 1 : 0.5
                    )
            }
            .animation(.timingCurve(0.25, 1, 0.5, 1, duration: 0.15), value: focused.wrappedValue)
    }
}

// MARK: - Button styles

private struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.timingCurve(0.25, 1, 0.5, 1, duration: 0.12), value: configuration.isPressed)
    }
}

private struct SendButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.90 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.timingCurve(0.25, 1, 0.5, 1, duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Conversation") {
    Build2ChatConversationView()
}
