import Foundation

struct Attachment: Hashable {
    enum Kind: Hashable {
        case pdf
        case photo
    }
    let kind: Kind
    let filename: String
    let fileSizeBytes: Int
    let systemSymbolName: String       // "doc.fill" for pdf, "photo" for photo
    // For .photo: displayImageSystemName renders as SF Symbol stand-in for image asset.
    let displayImageSystemName: String?
}
