#!/usr/bin/env swift
// TapKey App Icon Generator
// Usage: swift GenerateTapKeyIcon.swift

import Cocoa

let size = 1024

// Create bitmap context
guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
      let context = CGContext(
          data: nil,
          width: size,
          height: size,
          bitsPerComponent: 8,
          bytesPerRow: 0,
          space: colorSpace,
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      ) else {
    print("Failed to create context")
    exit(1)
}

let rect = CGRect(x: 0, y: 0, width: size, height: size)

// Background gradient (indigo to purple)
let gradientColors = [
    CGColor(srgbRed: 0.388, green: 0.400, blue: 0.945, alpha: 1.0), // #6366F1
    CGColor(srgbRed: 0.545, green: 0.361, blue: 0.965, alpha: 1.0), // #8B5CF6
    CGColor(srgbRed: 0.463, green: 0.290, blue: 0.635, alpha: 1.0), // #764BA2
]
let gradient = CGGradient(
    colorsSpace: colorSpace,
    colors: gradientColors as CFArray,
    locations: [0.0, 0.5, 1.0]
)!

// Draw gradient background
context.drawLinearGradient(
    gradient,
    start: CGPoint(x: 0, y: Double(size)),
    end: CGPoint(x: Double(size), y: 0),
    options: []
)

// Add subtle glow circle in top-right
context.saveGState()
let glowGradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [
        CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.12),
        CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.0)
    ] as CFArray,
    locations: [0.0, 1.0]
)!
context.drawRadialGradient(
    glowGradient,
    startCenter: CGPoint(x: Double(size) * 0.7, y: Double(size) * 0.7),
    startRadius: 0,
    endCenter: CGPoint(x: Double(size) * 0.7, y: Double(size) * 0.7),
    endRadius: Double(size) * 0.5,
    options: []
)
context.restoreGState()

// Draw key icon
let keyCenter = CGPoint(x: Double(size) * 0.5, y: Double(size) * 0.5)
let keyColor = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.95)
context.setFillColor(keyColor)
context.setStrokeColor(keyColor)

// Key head (circle with hole)
let headRadius: Double = 180
let headCenter = CGPoint(x: keyCenter.x - 60, y: keyCenter.y + 100)

// Outer circle
let outerPath = CGMutablePath()
outerPath.addEllipse(in: CGRect(
    x: headCenter.x - headRadius,
    y: headCenter.y - headRadius,
    width: headRadius * 2,
    height: headRadius * 2
))
// Inner hole
let holeRadius: Double = 80
let holePath = CGMutablePath()
holePath.addEllipse(in: CGRect(
    x: headCenter.x - holeRadius,
    y: headCenter.y - holeRadius,
    width: holeRadius * 2,
    height: holeRadius * 2
))

context.addPath(outerPath)
context.addPath(holePath)
context.drawPath(using: .eoFill)

// Key shaft
let shaftWidth: Double = 68
let shaftStartX = headCenter.x + headRadius * 0.7
let shaftStartY = headCenter.y
let shaftEndX = keyCenter.x + 320
let shaftEndY = headCenter.y - 280

let shaftPath = CGMutablePath()
// Angled shaft (45 degrees)
let angle = atan2(shaftEndY - shaftStartY, shaftEndX - shaftStartX)
let dx = Double(sin(Double(angle))) * shaftWidth / 2
let dy = Double(cos(Double(angle))) * shaftWidth / 2

shaftPath.move(to: CGPoint(x: shaftStartX - dx, y: shaftStartY + dy))
shaftPath.addLine(to: CGPoint(x: shaftEndX - dx, y: shaftEndY + dy))
shaftPath.addLine(to: CGPoint(x: shaftEndX + dx, y: shaftEndY - dy))
shaftPath.addLine(to: CGPoint(x: shaftStartX + dx, y: shaftStartY - dy))
shaftPath.closeSubpath()

context.addPath(shaftPath)
context.fillPath()

// Key teeth (3 teeth)
let teethCount = 3
for i in 0..<teethCount {
    let t = 0.4 + Double(i) * 0.2
    let toothX = shaftStartX + (shaftEndX - shaftStartX) * t
    let toothY = shaftStartY + (shaftEndY - shaftStartY) * t
    
    // Perpendicular direction for teeth
    let perpX = -Double(sin(Double(angle) + .pi / 2)) * 55
    let perpY = Double(cos(Double(angle) + .pi / 2)) * 55
    
    let toothWidth: Double = 36
    let toothPath = CGMutablePath()
    toothPath.addRect(CGRect(
        x: toothX + perpX - toothWidth/2,
        y: toothY + perpY - toothWidth/2,
        width: toothWidth,
        height: toothWidth * 1.5
    ))
    
    context.addPath(toothPath)
    context.fillPath()
}

// Add small shield overlay in bottom-right of key head
let shieldSize: Double = 100
let shieldX = headCenter.x + 20
let shieldY = headCenter.y - 60

context.saveGState()
context.setFillColor(CGColor(srgbRed: 0.388, green: 0.400, blue: 0.945, alpha: 0.6))

let shieldPath = CGMutablePath()
shieldPath.move(to: CGPoint(x: shieldX, y: shieldY + shieldSize * 0.5))
shieldPath.addLine(to: CGPoint(x: shieldX - shieldSize * 0.4, y: shieldY + shieldSize * 0.2))
shieldPath.addLine(to: CGPoint(x: shieldX - shieldSize * 0.4, y: shieldY - shieldSize * 0.15))
shieldPath.addQuadCurve(
    to: CGPoint(x: shieldX, y: shieldY - shieldSize * 0.5),
    control: CGPoint(x: shieldX - shieldSize * 0.2, y: shieldY - shieldSize * 0.4)
)
shieldPath.addQuadCurve(
    to: CGPoint(x: shieldX + shieldSize * 0.4, y: shieldY - shieldSize * 0.15),
    control: CGPoint(x: shieldX + shieldSize * 0.2, y: shieldY - shieldSize * 0.4)
)
shieldPath.addLine(to: CGPoint(x: shieldX + shieldSize * 0.4, y: shieldY + shieldSize * 0.2))
shieldPath.closeSubpath()

context.addPath(shieldPath)
context.fillPath()
context.restoreGState()

// Generate image
guard let cgImage = context.makeImage() else {
    print("Failed to create image")
    exit(1)
}

let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
    print("Failed to create PNG")
    exit(1)
}

// Save
let outputPath = "TapKey/TapKey/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
let url = URL(fileURLWithPath: outputPath)
try! pngData.write(to: url)
print("✅ App icon saved to \(outputPath)")

// Update Contents.json
let contentsJson = """
{
  "images" : [
    {
      "filename" : "AppIcon.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""

let contentsPath = "TapKey/TapKey/Assets.xcassets/AppIcon.appiconset/Contents.json"
try! contentsJson.write(toFile: contentsPath, atomically: true, encoding: .utf8)
print("✅ Contents.json updated")
