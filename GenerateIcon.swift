import Cocoa

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

guard let ctx = NSGraphicsContext.current?.cgContext else {
    exit(1)
}

// 1. Background Gradient (Blue)
let colorSpace = CGColorSpaceCreateDeviceRGB()
let colors = [
    NSColor(red: 0.25, green: 0.7, blue: 1.0, alpha: 1.0).cgColor, // Sky Blue
    NSColor(red: 0.0, green: 0.45, blue: 0.85, alpha: 1.0).cgColor  // Royal Blue
] as CFArray

// Diagonal gradient
let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0])!
ctx.drawLinearGradient(gradient,
                       start: CGPoint(x: 0, y: 1024),
                       end: CGPoint(x: 1024, y: 0),
                       options: [])

// 2. Draw Pill (Capsule)
ctx.saveGState()

// Center and Rotate
ctx.translateBy(x: 512, y: 512)
ctx.rotate(by: -CGFloat.pi / 4) // Tilted
ctx.translateBy(x: -512, y: -512)

// Pill Dimensions
let pillWidth: CGFloat = 400
let pillHeight: CGFloat = 700 // Elongated
let x = (1024 - pillWidth) / 2
let y = (1024 - pillHeight) / 2
let rect = CGRect(x: x, y: y, width: pillWidth, height: pillHeight)
let radius = pillWidth / 2

// Full Pill Path
let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)

// Shadow
ctx.setShadow(offset: CGSize(width: 10, height: -20), blur: 30, color: NSColor(white: 0, alpha: 0.3).cgColor)
ctx.addPath(path)
ctx.setFillColor(NSColor.white.cgColor)
ctx.fillPath()

// Remove Shadow for details
ctx.setShadow(offset: .zero, blur: 0, color: nil)

// Bottom Half (White/Light Blue)
ctx.addPath(path)
ctx.clip()

// Calculate split point (middle)
let midY = rect.midY

// Draw Top Half Color (Darker part of pill)
let topRect = CGRect(x: rect.minX, y: midY, width: rect.width, height: rect.height/2 + radius) // Overshoot a bit
ctx.setFillColor(NSColor(red: 0.92, green: 0.92, blue: 0.95, alpha: 1.0).cgColor) // Off-white/Gray for one half
ctx.fill(topRect)

// Accent Stripe
let stripeHeight: CGFloat = 20
let stripeRect = CGRect(x: rect.minX, y: midY - stripeHeight/2, width: rect.width, height: stripeHeight)
ctx.setFillColor(NSColor(red: 0.8, green: 0.8, blue: 0.85, alpha: 1.0).cgColor)
ctx.fill(stripeRect)

// Add a glossy shine
let shinePath = CGPath(ellipseIn: CGRect(x: rect.minX + 50, y: rect.maxY - 250, width: 100, height: 200), transform: nil)
ctx.addPath(shinePath)
ctx.setFillColor(NSColor(white: 1.0, alpha: 0.2).cgColor)
ctx.fillPath()

ctx.restoreGState()

image.unlockFocus()

// Save to PNG
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    let url = URL(fileURLWithPath: "AppIcon-1024.png")
    try? pngData.write(to: url)
}
