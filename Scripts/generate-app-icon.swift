import AppKit
import ImageIO
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 2 else {
  fatalError("Kullanım: swift generate-app-icon.swift <çıktı.png>")
}

let pixelSize = 1024
let canvas = NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize)
guard
  let bitmapContext = CGContext(
    data: nil,
    width: pixelSize,
    height: pixelSize,
    bitsPerComponent: 8,
    bytesPerRow: pixelSize * 4,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
  )
else {
  fatalError("İkon çizim yüzeyi oluşturulamadı.")
}

let context = NSGraphicsContext(cgContext: bitmapContext, flipped: false)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
context.imageInterpolation = .high
context.cgContext.setAllowsAntialiasing(true)
context.cgContext.setShouldAntialias(true)

let background = NSGradient(colors: [
  NSColor(red: 0.035, green: 0.043, blue: 0.082, alpha: 1),
  NSColor(red: 0.105, green: 0.112, blue: 0.225, alpha: 1),
])!
background.draw(in: canvas, angle: -45)

NSColor(red: 0.32, green: 0.27, blue: 0.82, alpha: 0.14).setFill()
NSBezierPath(ovalIn: NSRect(x: 520, y: 520, width: 620, height: 620)).fill()

let markRect = NSRect(x: 202, y: 202, width: 620, height: 620)
let shadow = NSShadow()
shadow.shadowColor = NSColor.black.withAlphaComponent(0.32)
shadow.shadowBlurRadius = 46
shadow.shadowOffset = NSSize(width: 0, height: -20)
shadow.set()

NSColor(red: 0.32, green: 0.94, blue: 0.69, alpha: 1).setFill()
NSBezierPath(roundedRect: markRect, xRadius: 150, yRadius: 150).fill()

NSGraphicsContext.saveGraphicsState()
NSShadow().set()
let codeColor = NSColor(red: 0.035, green: 0.043, blue: 0.082, alpha: 1)
codeColor.setStroke()

func drawStroke(_ points: [NSPoint]) {
  let path = NSBezierPath()
  path.lineWidth = 58
  path.lineCapStyle = .round
  path.lineJoinStyle = .round
  path.move(to: points[0])
  for point in points.dropFirst() {
    path.line(to: point)
  }
  path.stroke()
}

drawStroke([
  NSPoint(x: 410, y: 650),
  NSPoint(x: 315, y: 512),
  NSPoint(x: 410, y: 374),
])
drawStroke([
  NSPoint(x: 614, y: 650),
  NSPoint(x: 709, y: 512),
  NSPoint(x: 614, y: 374),
])
drawStroke([
  NSPoint(x: 564, y: 685),
  NSPoint(x: 460, y: 339),
])
NSGraphicsContext.restoreGraphicsState()
NSGraphicsContext.restoreGraphicsState()

guard let image = bitmapContext.makeImage() else {
  fatalError("İkon görseli üretilemedi.")
}
let outputURL = URL(fileURLWithPath: CommandLine.arguments[1]) as CFURL
guard
  let destination = CGImageDestinationCreateWithURL(
    outputURL,
    UTType.png.identifier as CFString,
    1,
    nil
  )
else {
  fatalError("PNG hedefi oluşturulamadı.")
}
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else {
  fatalError("PNG verisi yazılamadı.")
}
