import SwiftUI

struct Build1ChatConversationView: View {
    let messages: [Message] = SampleData.conversation
    @State private var composeText: String = ""
    @State private var expandedThreads: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages) { message in
                        messageRow(for: message)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }

            HStack {
                TextField("Message", text: $composeText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    composeText = ""
                }) {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .padding(.bottom, 34)
            .background(Color(.systemBackground))
        }
        .navigationTitle("Alex")
    }

    @ViewBuilder
    private func messageRow(for message: Message) -> some View {
        switch message.content {
        case .dateHeader(let date):
            HStack {
                Spacer()
                Text(dateHeaderText(for: date))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.vertical, 8)

        case .text(let body):
            if message.sender == .me {
                HStack {
                    Spacer()
                    Text(body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(senderName(message.sender))
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        Text(body)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        Spacer()
                    }
                    Text(timeText(message.sentAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

        case .linkPreview(let body, let preview):
            VStack(alignment: .leading, spacing: 2) {
                Text(senderName(message.sender))
                    .font(.caption)
                    .foregroundColor(.gray)
                VStack(alignment: .leading, spacing: 6) {
                    if let body = body {
                        Text(body)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: preview.thumbnailSystemName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 100)
                        Text(preview.title)
                            .font(.headline)
                        Text(preview.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(preview.sourceLabel)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                Text(timeText(message.sentAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

        case .photo(let attachment):
            VStack(alignment: .leading, spacing: 2) {
                Text(senderName(message.sender))
                    .font(.caption)
                    .foregroundColor(.gray)
                Image(systemName: attachment.displayImageSystemName ?? "photo")
                    .resizable()
                    .frame(width: 200, height: 150)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                Text(timeText(message.sentAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

        case .pdfAttachment(let attachment):
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    HStack {
                        Image(systemName: attachment.systemSymbolName)
                        Text(attachment.filename)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Text(timeText(message.sentAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

        case .replyThreadRoot(let body, let thread):
            VStack(alignment: .leading, spacing: 2) {
                Text(senderName(message.sender))
                    .font(.caption)
                    .foregroundColor(.gray)
                VStack(alignment: .leading, spacing: 8) {
                    Text(body)
                    if expandedThreads.contains(message.id) {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(thread.replies) { reply in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(senderName(reply.sender))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(reply.body)
                                }
                            }
                        }
                    } else {
                        Button("\(thread.replies.count) replies") {
                            if expandedThreads.contains(message.id) {
                                expandedThreads.remove(message.id)
                            } else {
                                expandedThreads.insert(message.id)
                            }
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                Text(timeText(message.sentAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    private func senderName(_ sender: Sender) -> String {
        SampleData.senders[sender]?.displayName ?? ""
    }

    private func timeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func dateHeaderText(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    Build1ChatConversationView()
}
