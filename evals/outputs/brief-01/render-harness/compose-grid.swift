// compose-grid.swift
//
// Usage: swift compose-grid.swift <c1.png> <c2.png> <c3.png> <c4.png> <output.png>
//
// Composites four 800x1000 code-card PNGs into a 2x2 grid image at 1600x2000 pt
// (rendered 2x -> 3200x4000 px). Adds quadrant labels and a small title banner.
//
// The four inputs are expected in order: C1 (top-left), C2 (top-right),
// C3 (bottom-left), C4 (bottom-right).

import AppKit
import CoreGraphics
import Foundation

guard CommandLine.arguments.count == 6 else {
    FileHandle.standardError.write(Data("Usage: compose-grid.swift <c1> <c2> <c3> <c4> <out>\n".utf8))
    exit(2)
}

let inputs = Array(CommandLine.arguments[1...4])
let outputPath = CommandLine.arguments[5]

// Dimensions (points)
let cellWidth: CGFloat = 800
let cellHeight: CGFloat = 1000
let gap: CGFloat = 8
let titleHeight: CGFloat = 72
let totalWidth = cellWidth * 2 + gap
let totalHeight = titleHeight + cellHeight * 2 + gap

let scale: CGFloat = 1.0 // inputs are already 2x; we keep natural here
let widthPx = Int(totalWidth * scale)
let heightPx = Int(totalHeight * scale)

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
    FileHandle.standardError.write(Data("Bitmap context failed\n".utf8))
    exit(1)
}

ctx.scaleBy(x: scale, y: scale)
ctx.translateBy(x: 0, y: totalHeight)
ctx.scaleBy(x: 1, y: -1)

// Background
ctx.setFillColor(CGColor(red: 0.07, green: 0.08, blue: 0.10, alpha: 1.0))
ctx.fill(CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight))

// Title bar
ctx.setFillColor(CGColor(red: 0.11, green: 0.12, blue: 0.14, alpha: 1.0))
ctx.fill(CGRect(x: 0, y: 0, width: totalWidth, height: titleHeight))

func drawText(_ text: String, at point: CGPoint, size: CGFloat, weight: NSFont.Weight, color: CGColor) {
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(cgColor: color) ?? .white,
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attrs))
    ctx.saveGState()
    ctx.translateBy(x: point.x, y: point.y)
    ctx.scaleBy(x: 1, y: -1)
    ctx.textMatrix = .identity
    ctx.textPosition = .zero
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

drawText(
    "impeccable-swift — brief-01 (Settings) 4-way ablation",
    at: CGPoint(x: 24, y: 46),
    size: 24,
    weight: .semibold,
    color: CGColor(red: 1, green: 1, blue: 1, alpha: 1)
)

// Composite inputs
let positions: [(CGFloat, CGFloat)] = [
    (0, titleHeight),                             // C1 top-left
    (cellWidth + gap, titleHeight),               // C2 top-right
    (0, titleHeight + cellHeight + gap),          // C3 bottom-left
    (cellWidth + gap, titleHeight + cellHeight + gap), // C4 bottom-right
]

for (idx, path) in inputs.enumerated() {
    guard
        let img = NSImage(contentsOfFile: path),
        let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else {
        FileHandle.standardError.write(Data("Failed to load \(path)\n".utf8))
        exit(1)
    }
    let (x, y) = positions[idx]
    // Context is flipped (top-left origin via translateBy + scaleBy(1,-1)), but
    // CGContext.draw interprets the rect in its own (now flipped) coord space,
    // so the image would appear upside-down. Counter-flip per-image by saving
    // state, un-flipping y, and drawing at the natural rect.
    ctx.saveGState()
    ctx.translateBy(x: 0, y: y + cellHeight)
    ctx.scaleBy(x: 1, y: -1)
    ctx.draw(cg, in: CGRect(x: x, y: 0, width: cellWidth, height: cellHeight))
    ctx.restoreGState()
}

guard let out = ctx.makeImage() else { exit(1) }
let rep = NSBitmapImageRep(cgImage: out)
rep.size = NSSize(width: totalWidth, height: totalHeight)
guard let data = rep.representation(using: .png, properties: [:]) else { exit(1) }
try data.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(outputPath) (\(data.count) bytes)")
