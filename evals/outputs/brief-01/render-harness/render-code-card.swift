// render-code-card.swift
//
// Usage: swift render-code-card.swift <input.swift> <output.png> <label>
//
// Renders the contents of a .swift file as a labeled PNG "code card":
// a dark card with a header bar (label) and the syntax-highlighted-ish source
// drawn below via CoreText. Output dimensions: 800x1000 pt, 2x rendered (1600x2000 px).
//
// This is a pragmatic fallback in lieu of running each view through an iOS
// simulator: we show the *code produced* per condition rather than the
// rendered UI. Honest about what the 4-way grid represents.

import AppKit
import CoreGraphics
import CoreText
import Foundation

// MARK: - Args

guard CommandLine.arguments.count == 4 else {
    FileHandle.standardError.write(Data("Usage: render-code-card.swift <input.swift> <output.png> <label>\n".utf8))
    exit(2)
}

let inputPath = CommandLine.arguments[1]
let outputPath = CommandLine.arguments[2]
let label = CommandLine.arguments[3]

guard let sourceData = try? String(contentsOfFile: inputPath, encoding: .utf8) else {
    FileHandle.standardError.write(Data("Failed to read \(inputPath)\n".utf8))
    exit(1)
}

// MARK: - Dimensions (points, 2x render)

let scale: CGFloat = 2.0
let widthPt: CGFloat = 800
let heightPt: CGFloat = 1000
let widthPx = Int(widthPt * scale)
let heightPx = Int(heightPt * scale)

let headerHeightPt: CGFloat = 64
let paddingPt: CGFloat = 24

// Colors
let bgColor = CGColor(red: 0.11, green: 0.12, blue: 0.14, alpha: 1.0)       // #1c1e23
let headerColor = CGColor(red: 0.16, green: 0.17, blue: 0.20, alpha: 1.0)   // #292b33
let accentColor = CGColor(red: 0.79, green: 0.45, blue: 0.31, alpha: 1.0)   // #c97350
let textColor = CGColor(red: 0.88, green: 0.88, blue: 0.86, alpha: 1.0)     // #e0e0db
let commentColor = CGColor(red: 0.50, green: 0.55, blue: 0.52, alpha: 1.0)
let keywordColor = CGColor(red: 0.95, green: 0.65, blue: 0.51, alpha: 1.0)
let stringColor = CGColor(red: 0.62, green: 0.80, blue: 0.60, alpha: 1.0)
let headerTextColor = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

// MARK: - Bitmap context

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil,
    width: widthPx,
    height: heightPx,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    FileHandle.standardError.write(Data("Failed to create bitmap context\n".utf8))
    exit(1)
}

ctx.scaleBy(x: scale, y: scale)
// Flip so top-left is origin (CG default is bottom-left)
ctx.translateBy(x: 0, y: heightPt)
ctx.scaleBy(x: 1, y: -1)

// MARK: - Background

ctx.setFillColor(bgColor)
ctx.fill(CGRect(x: 0, y: 0, width: widthPt, height: heightPt))

// MARK: - Header bar

ctx.setFillColor(headerColor)
ctx.fill(CGRect(x: 0, y: 0, width: widthPt, height: headerHeightPt))

// Accent stripe on left
ctx.setFillColor(accentColor)
ctx.fill(CGRect(x: 0, y: 0, width: 4, height: headerHeightPt))

// MARK: - Text drawing helper

func drawText(_ text: String, at point: CGPoint, font: NSFont, color: CGColor) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(cgColor: color) ?? NSColor.white,
    ]
    let attributed = NSAttributedString(string: text, attributes: attrs)
    let line = CTLineCreateWithAttributedString(attributed)

    // Flip context temporarily for text drawing (CoreText expects upright)
    ctx.saveGState()
    ctx.translateBy(x: point.x, y: point.y)
    ctx.scaleBy(x: 1, y: -1)
    ctx.textMatrix = .identity
    ctx.textPosition = .zero
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

// MARK: - Header label

let labelFont = NSFont.systemFont(ofSize: 22, weight: .semibold)
drawText(label, at: CGPoint(x: paddingPt, y: 40), font: labelFont, color: headerTextColor)

// MARK: - Source code rendering

// Strip license comment header (first 8 lines or so) if it's just a
// condition description — keep it, it's informative.
let lines = sourceData.components(separatedBy: "\n")

// Figure out how many lines fit
let codeFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
let lineHeight: CGFloat = 14
let codeStartY: CGFloat = headerHeightPt + paddingPt
let availableHeight = heightPt - codeStartY - paddingPt
let maxLines = Int(availableHeight / lineHeight)

// Swift keywords for rudimentary highlighting
let keywords: Set<String> = [
    "import", "struct", "var", "let", "private", "fileprivate", "public",
    "enum", "case", "if", "else", "return", "func", "some", "static",
    "@ViewBuilder", "@State", "@ScaledMetric", "@Environment",
    "Section", "Form", "Button", "Toggle", "Text", "VStack", "HStack",
    "ZStack", "ScrollView", "Spacer", "Divider", "Label", "NavigationStack",
    "body", "in"
]

for (i, line) in lines.prefix(maxLines).enumerated() {
    let y = codeStartY + CGFloat(i) * lineHeight + 11

    // Pick color based on line type
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    let color: CGColor
    if trimmed.hasPrefix("//") {
        color = commentColor
    } else if trimmed.contains("\"") {
        color = textColor
    } else if keywords.contains(where: { trimmed.hasPrefix($0 + " ") }) {
        color = keywordColor
    } else {
        color = textColor
    }

    drawText(line, at: CGPoint(x: paddingPt, y: y), font: codeFont, color: color)
}

// If we truncated, add an indicator
if lines.count > maxLines {
    let indicator = "... (\(lines.count - maxLines) more lines)"
    drawText(
        indicator,
        at: CGPoint(x: paddingPt, y: codeStartY + CGFloat(maxLines) * lineHeight + 11),
        font: codeFont,
        color: commentColor
    )
}

// MARK: - Write PNG

guard let cgImage = ctx.makeImage() else {
    FileHandle.standardError.write(Data("Failed to make image\n".utf8))
    exit(1)
}

let rep = NSBitmapImageRep(cgImage: cgImage)
rep.size = NSSize(width: widthPt, height: heightPt)

guard let pngData = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write(Data("Failed to encode PNG\n".utf8))
    exit(1)
}

try pngData.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(outputPath) (\(pngData.count) bytes)")
