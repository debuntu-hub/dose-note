import Foundation
import AppKit

struct CLI {
    var title: String = "" 
    var color1Hex: String = "#434343" 
    var color2Hex: String = "#000000" 
    var iconSymbol: String = "key.fill"
    var outputPath: String = "Assets.xcassets/AppIcon.appiconset"

    static func parse() -> CLI {
        var cli = CLI()
        let args = CommandLine.arguments
        var i = 1
        func readValue() -> String? {
            guard i + 1 < args.count else { return nil }
            let v = args[i + 1]
            i += 2
            return v
        }
        while i < args.count {
            let arg = args[i]
            switch arg {
            case "--title":
                if let v = readValue() { cli.title = v }
            case "--color1":
                if let v = readValue() { cli.color1Hex = v }
            case "--color2":
                if let v = readValue() { cli.color2Hex = v }
            case "--symbol":
                if let v = readValue() { cli.iconSymbol = v }
            case "--output":
                if let v = readValue() { cli.outputPath = v }
            case "--help", "-h":
                printUsageAndExit()
            default:
                i += 1
            }
        }
        return cli
    }

    static func printUsageAndExit() -> Never {
        let usage = """
        GenerateAppIcon.swift
        Generates stylish iOS app icons using SF Symbols and Gradients.

        Usage:
          xcrun swift Scripts/GenerateAppIcon.swift [--symbol "key.fill"] [--color1 "#434343"] [--color2 "#000000"]

        Options:
          --symbol  SF Symbol name to render. Default: key.fill
          --title   (Optional) Text to render instead of symbol.
          --color1  Start color in hex. Default: #434343
          --color2  End color in hex. Default: #000000
          --output  Path to AppIcon.appiconset.
        """
        print(usage)
        exit(0)
    }
}

extension NSColor {
    static func fromHex(_ hex: String) -> NSColor {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        let scanner = Scanner(string: str)
        var value: UInt64 = 0
        guard scanner.scanHexInt64(&value) else { return NSColor.systemBlue }
        switch str.count {
        case 6: // RRGGBB
            let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((value & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(value & 0x0000FF) / 255.0
            return NSColor(srgbRed: r, green: g, blue: b, alpha: 1.0)
        case 8: // RRGGBBAA
            let r = CGFloat((value & 0xFF000000) >> 24) / 255.0
            let g = CGFloat((value & 0x00FF0000) >> 16) / 255.0
            let b = CGFloat((value & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(value & 0x000000FF) / 255.0
            return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
        default:
            return NSColor.systemBlue
        }
    }
}

func generateIconData(pixelSize: Int, title: String, symbol: String, color1: NSColor, color2: NSColor) -> Data? {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB, 
        bytesPerRow: 0,
        bitsPerPixel: 32
    )
    guard let bitmapRep = rep else { return nil }

    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: bitmapRep) else { return nil }
    NSGraphicsContext.current = context

    // 1. Background Gradient
    let rect = NSRect(x: 0, y: 0, width: CGFloat(pixelSize), height: CGFloat(pixelSize))
    if let gradient = NSGradient(colors: [color1, color2]) {
        gradient.draw(in: rect, angle: -45)
    } else {
        color1.setFill()
        rect.fill()
    }

    // 2. Glossy Overlay (Subtle)
    if let gloss = NSGradient(colors: [NSColor.white.withAlphaComponent(0.1), NSColor.white.withAlphaComponent(0.0)]) {
        let glossRect = NSRect(x: 0, y: CGFloat(pixelSize) * 0.4, width: CGFloat(pixelSize), height: CGFloat(pixelSize) * 0.6)
        gloss.draw(in: glossRect, angle: 90)
    }

    // 3. Content
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.4)
    shadow.shadowOffset = NSSize(width: 0, height: -CGFloat(pixelSize) * 0.02)
    shadow.shadowBlurRadius = CGFloat(pixelSize) * 0.04
    shadow.set()

    if !title.isEmpty {
        let letter = String(title.prefix(1)).uppercased()
        let fontSize = CGFloat(pixelSize) * 0.6
        let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraph
        ]
        let attributed = NSAttributedString(string: letter, attributes: attributes)
        let textSize = attributed.size()
        let textRect = NSRect(
            x: (CGFloat(pixelSize) - textSize.width) / 2.0,
            y: (CGFloat(pixelSize) - textSize.height) / 2.0,
            width: textSize.width,
            height: textSize.height
        )
        attributed.draw(in: textRect)
    } else {
        // SF Symbol Drawing
        if let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil) {
             let symbolSize = CGFloat(pixelSize) * 0.6
             let destRect = NSRect(
                 x: (CGFloat(pixelSize) - symbolSize) / 2.0,
                 y: (CGFloat(pixelSize) - symbolSize) / 2.0,
                 width: symbolSize,
                 height: symbolSize
             )
             
             // Tint white
             if let tintedImage = image.copy() as? NSImage {
                 tintedImage.lockFocus()
                 NSColor.white.set()
                 let r = NSRect(origin: .zero, size: image.size)
                 r.fill(using: .sourceIn)
                 tintedImage.unlockFocus()
                 tintedImage.draw(in: destRect, from: .zero, operation: .sourceOver, fraction: 1.0)
             }
        }
    }

    NSGraphicsContext.restoreGraphicsState()
    return bitmapRep.representation(using: .png, properties: [:])
}

struct IconSpec {
    let idiom: String
    let pointSize: Double
    let scale: Int

    var pixelSize: Int { Int((pointSize * Double(scale)).rounded()) }

    var sizeString: String {
        if pointSize.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(pointSize))x\(Int(pointSize))"
        } else {
            return "\(pointSize)x\(pointSize)"
        }
    }
    var scaleString: String { "\(scale)x" }

    var filename: String {
        if idiom == "ios-marketing" { return "AppIcon-1024.png" }
        let ptDisplay: String = {
            if pointSize.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(pointSize))pt"
            } else {
                return "\(pointSize)pt"
            }
        }()
        return "AppIcon-\(idiom)-\(ptDisplay)@\(scaleString).png"
    }
}

struct ImageJSON: Codable { let idiom: String; let size: String; let scale: String; let filename: String }
struct InfoJSON: Codable { let version: Int; let author: String }
struct ContentsJSON: Codable { let images: [ImageJSON]; let info: InfoJSON }

func generateSpecs() -> [IconSpec] {
    var specs: [IconSpec] = []
    specs += [
        IconSpec(idiom: "iphone", pointSize: 20, scale: 2),
        IconSpec(idiom: "iphone", pointSize: 20, scale: 3),
        IconSpec(idiom: "iphone", pointSize: 29, scale: 2),
        IconSpec(idiom: "iphone", pointSize: 29, scale: 3),
        IconSpec(idiom: "iphone", pointSize: 40, scale: 2),
        IconSpec(idiom: "iphone", pointSize: 40, scale: 3),
        IconSpec(idiom: "iphone", pointSize: 60, scale: 2),
        IconSpec(idiom: "iphone", pointSize: 60, scale: 3),
    ]
    specs += [
        IconSpec(idiom: "ipad", pointSize: 20, scale: 1),
        IconSpec(idiom: "ipad", pointSize: 20, scale: 2),
        IconSpec(idiom: "ipad", pointSize: 29, scale: 1),
        IconSpec(idiom: "ipad", pointSize: 29, scale: 2),
        IconSpec(idiom: "ipad", pointSize: 40, scale: 1),
        IconSpec(idiom: "ipad", pointSize: 40, scale: 2),
        IconSpec(idiom: "ipad", pointSize: 76, scale: 1),
        IconSpec(idiom: "ipad", pointSize: 76, scale: 2),
        IconSpec(idiom: "ipad", pointSize: 83.5, scale: 2),
    ]
    specs += [ IconSpec(idiom: "ios-marketing", pointSize: 1024, scale: 1) ]
    return specs
}

func main() throws {
    let cli = CLI.parse()
    let fm = FileManager.default
    let outputURL = URL(fileURLWithPath: cli.outputPath, isDirectory: true)
    try? fm.createDirectory(at: outputURL, withIntermediateDirectories: true)
    let color1 = NSColor.fromHex(cli.color1Hex)
    let color2 = NSColor.fromHex(cli.color2Hex)
    let specs = generateSpecs()
    for spec in specs {
        guard let data = generateIconData(pixelSize: spec.pixelSize, title: cli.title, symbol: cli.iconSymbol, color1: color1, color2: color2) else {
             print("Failed to generate icon for \(spec.filename)")
             continue
        }
        let fileURL = outputURL.appendingPathComponent(spec.filename)
        do {
            try data.write(to: fileURL)
            print("Wrote \(fileURL.path)")
        } catch {
            print("Error writing \(fileURL.path): \(error)")
        }
    }
    let imagesJSON: [ImageJSON] = specs.map { spec in
        ImageJSON(idiom: spec.idiom, size: spec.sizeString, scale: spec.scaleString, filename: spec.filename)
    }
    let contents = ContentsJSON(images: imagesJSON, info: InfoJSON(version: 1, author: "xcode"))
    let jsonURL = outputURL.appendingPathComponent("Contents.json")
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(contents)
    try data.write(to: jsonURL)
    print("Updated \(jsonURL.path)")
    print("\nDone. Open Assets.xcassets > AppIcon to preview.")
}

do { try main() } catch {
    fputs("Error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
