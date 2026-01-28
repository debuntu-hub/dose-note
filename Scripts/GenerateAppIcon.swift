import Foundation
import AppKit

struct CLI {
    var title: String = "D"
    var color1Hex: String = "#6A5AE0"
    var color2Hex: String = "#8ED1FC"
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
        Generates placeholder iOS app icons (iPhone/iPad + App Store 1024) into an AppIcon.appiconset.

        Usage:
          xcrun swift Scripts/GenerateAppIcon.swift [--title "Dose"] [--color1 "#6A5AE0"] [--color2 "#8ED1FC"] [--output "Assets.xcassets/AppIcon.appiconset"]

        Options:
          --title   Text to render (first character is used). Default: D
          --color1  Start color in hex (#RRGGBB or #RRGGBBAA). Default: #6A5AE0
          --color2  End color in hex (#RRGGBB or #RRGGBBAA). Default: #8ED1FC
          --output  Path to AppIcon.appiconset. Default: Assets.xcassets/AppIcon.appiconset
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

func drawIcon(size: Int, title: String, color1: NSColor, color2: NSColor) -> NSImage {
    let imgSize = NSSize(width: size, height: size)
    let image = NSImage(size: imgSize)
    image.lockFocus()

    let rect = NSRect(origin: .zero, size: imgSize)
    if let gradient = NSGradient(colors: [color1, color2]) {
        gradient.draw(in: rect, angle: 90)
    } else {
        color1.setFill()
        rect.fill()
    }

    let letter = String(title.prefix(1)).uppercased()
    let fontSize = CGFloat(size) * 0.58
    let font = NSFont.systemFont(ofSize: fontSize, weight: .heavy)
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    paragraph.lineBreakMode = .byClipping

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph
    ]
    let attributed = NSAttributedString(string: letter, attributes: attributes)
    let textSize = attributed.size()
    let textRect = NSRect(
        x: (CGFloat(size) - textSize.width) / 2.0,
        y: (CGFloat(size) - textSize.height) / 2.0,
        width: textSize.width,
        height: textSize.height
    )
    attributed.draw(in: textRect)

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let data = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "GenerateAppIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PNG data"])
    }
    try data.write(to: url)
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
    // iPhone
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
    // iPad
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
    // App Store
    specs += [ IconSpec(idiom: "ios-marketing", pointSize: 1024, scale: 1) ]
    return specs
}

func main() throws {
    let cli = CLI.parse()

    let fm = FileManager.default
    let outputURL = URL(fileURLWithPath: cli.outputPath, isDirectory: true)
    try fm.createDirectory(at: outputURL, withIntermediateDirectories: true)

    let color1 = NSColor.fromHex(cli.color1Hex)
    let color2 = NSColor.fromHex(cli.color2Hex)

    let specs = generateSpecs()

    for spec in specs {
        let size = spec.pixelSize
        let image = drawIcon(size: size, title: cli.title, color1: color1, color2: color2)
        let fileURL = outputURL.appendingPathComponent(spec.filename)
        try savePNG(image, to: fileURL)
        print("Wrote \(fileURL.path)")
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

func printUsageAndExit() -> Never { CLI.printUsageAndExit() }

do { try main() } catch {
    fputs("Error: \(error.localizedDescription)\n", stderr)
    exit(1)
}
