import Foundation

// Covers all 6 content types from the brief
enum MessageContent: Hashable {
    case text(String)
    case linkPreview(body: String?, preview: LinkPreview)
    case photo(Attachment)               // inline image
    case pdfAttachment(Attachment)
    case replyThreadRoot(body: String, thread: ReplyThread)
    case dateHeader(Date)                // rendered as a separator row
}
