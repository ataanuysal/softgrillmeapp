import AppKit
import ImageIO
import UniformTypeIdentifiers

// GrillMe:Code uygulama ikonu.
//
// Karanlık bir editör yüzeyinde parlayan </> işareti ve yanında imleç.
// iOS ikonları saydamlık taşıyamaz; köşe yuvarlatmayı sistem uygular, bu
// yüzden burada düz ve tam kare bir yüzey çizilir.

guard CommandLine.arguments.count == 2 else {
  fatalError("Kullanım: swift generate-app-icon.swift <çıktı.png>")
}

let pixelSize = 1024.0
let canvas = NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize)
// Tasarım 240 pt üzerinden ölçüldü; bütün değerler o orana göre büyütülür.
let scale = pixelSize / 240.0

func color(_ hex: UInt32, alpha: CGFloat = 1) -> NSColor {
  NSColor(
    srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
    green: CGFloat((hex >> 8) & 0xFF) / 255,
    blue: CGFloat(hex & 0xFF) / 255,
    alpha: alpha
  )
}

let surfaceDark = color(0x0D0E11)
let surfaceLight = color(0x1B2733)
let accent = color(0x007ACC)
let chevron = color(0x569CD6)
let slash = color(0x4EC9B0)

guard
  let bitmapContext = CGContext(
    data: nil,
    width: Int(pixelSize),
    height: Int(pixelSize),
    bitsPerComponent: 8,
    bytesPerRow: Int(pixelSize) * 4,
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
context.cgContext.setShouldAntialias(true)

// Editör yüzeyi: sol üstten gelen yumuşak ışık.
surfaceDark.setFill()
canvas.fill()
NSGradient(colors: [surfaceLight, surfaceDark])?
  .draw(
    fromCenter: NSPoint(x: pixelSize * 0.3, y: pixelSize * 0.8),
    radius: 0,
    toCenter: NSPoint(x: pixelSize * 0.3, y: pixelSize * 0.8),
    radius: pixelSize * 0.84,
    options: []
  )

// Sağ alta doğru inen mavi parlama.
NSGradient(colors: [NSColor.clear, accent.withAlphaComponent(0.14)])?
  .draw(in: canvas, angle: -45)

// Editörün üst kenarındaki kesik çizgi: kod satırı dokusu.
let stripY = pixelSize - 26 * scale
color(0xFFFFFF, alpha: 0.04).setFill()
var dashX = 0.0
while dashX < pixelSize {
  NSRect(x: dashX + 16 * scale, y: stripY, width: 1 * scale, height: 3 * scale).fill()
  dashX += 17 * scale
}

let glyphFont = NSFont.monospacedSystemFont(ofSize: 78 * scale, weight: .heavy)
let mark = NSMutableAttributedString()
for (character, glyphColor) in [("<", chevron), ("/", slash), (">", chevron)] {
  mark.append(
    NSAttributedString(
      string: character,
      attributes: [
        .font: glyphFont,
        .foregroundColor: glyphColor,
        .kern: 6 * scale,
      ]
    )
  )
}

let cursorWidth = 9 * scale
let cursorHeight = 74 * scale
let cursorGap = 6 * scale
let markSize = mark.size()
let groupWidth = markSize.width + cursorGap + cursorWidth
let groupOriginX = (pixelSize - groupWidth) / 2
let markOriginY = (pixelSize - markSize.height) / 2

// İşaret ve imleç kendi renklerinde hafifçe parlar.
func withGlow(_ glowColor: NSColor, radius: CGFloat, _ draw: () -> Void) {
  NSGraphicsContext.saveGraphicsState()
  let glow = NSShadow()
  glow.shadowColor = glowColor
  glow.shadowBlurRadius = radius
  glow.shadowOffset = .zero
  glow.set()
  draw()
  NSGraphicsContext.restoreGraphicsState()
}

withGlow(chevron.withAlphaComponent(0.5), radius: 30 * scale) {
  mark.draw(at: NSPoint(x: groupOriginX, y: markOriginY))
}

withGlow(accent.withAlphaComponent(0.9), radius: 22 * scale) {
  accent.setFill()
  NSBezierPath(
    roundedRect: NSRect(
      x: groupOriginX + markSize.width + cursorGap,
      y: (pixelSize - cursorHeight) / 2,
      width: cursorWidth,
      height: cursorHeight
    ),
    xRadius: 3 * scale,
    yRadius: 3 * scale
  ).fill()
}

// Alt kenardaki marka etiketi.
let label = NSAttributedString(
  string: "GRILLME",
  attributes: [
    .font: NSFont.monospacedSystemFont(ofSize: 13 * scale, weight: .bold),
    .foregroundColor: color(0xFFFFFF, alpha: 0.42),
    .kern: 5 * scale,
  ]
)
let labelSize = label.size()
label.draw(at: NSPoint(x: (pixelSize - labelSize.width) / 2, y: 26 * scale))

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
