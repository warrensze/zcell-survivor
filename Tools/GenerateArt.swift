import AppKit

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assets = root.appendingPathComponent("ZCellSurvivor/Assets.xcassets")

func save(_ image: NSImage, named name: String) throws {
    let url = assets.appendingPathComponent("\(name).imageset/\(name).png")
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "GenerateArt", code: 1)
    }
    try png.write(to: url)
}

func image(size: CGSize, draw: (CGRect) -> Void) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    draw(CGRect(origin: .zero, size: size))
    image.unlockFocus()
    return image
}

func oval(_ rect: CGRect, fill: NSColor, stroke: NSColor = .clear, line: CGFloat = 0) {
    fill.setFill()
    stroke.setStroke()
    let path = NSBezierPath(ovalIn: rect)
    path.lineWidth = line
    path.fill()
    if line > 0 { path.stroke() }
}

func rounded(_ rect: CGRect, radius: CGFloat, fill: NSColor, stroke: NSColor = .clear, line: CGFloat = 0) {
    fill.setFill()
    stroke.setStroke()
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    path.lineWidth = line
    path.fill()
    if line > 0 { path.stroke() }
}

func line(from: CGPoint, to: CGPoint, color: NSColor, width: CGFloat) {
    color.setStroke()
    let path = NSBezierPath()
    path.move(to: from)
    path.line(to: to)
    path.lineWidth = width
    path.lineCapStyle = .round
    path.stroke()
}

func polygon(_ points: [CGPoint], fill: NSColor, stroke: NSColor = .clear, lineWidth: CGFloat = 0) {
    guard let first = points.first else { return }
    let path = NSBezierPath()
    path.move(to: first)
    for point in points.dropFirst() {
        path.line(to: point)
    }
    path.close()
    fill.setFill()
    stroke.setStroke()
    path.lineWidth = lineWidth
    path.fill()
    if lineWidth > 0 { path.stroke() }
}

func drawHero(in rect: CGRect) {
    oval(rect.insetBy(dx: rect.width * 0.14, dy: rect.height * 0.16), fill: NSColor(calibratedRed: 0.95, green: 0.09, blue: 0.18, alpha: 1), stroke: .white.withAlphaComponent(0.75), line: rect.width * 0.035)
    oval(CGRect(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.58, width: rect.width * 0.16, height: rect.height * 0.16), fill: .white.withAlphaComponent(0.9))
    oval(CGRect(x: rect.minX + rect.width * 0.56, y: rect.minY + rect.height * 0.48, width: rect.width * 0.12, height: rect.height * 0.12), fill: .white.withAlphaComponent(0.78))
    drawCapsule(in: CGRect(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.22, width: rect.width * 0.24, height: rect.height * 0.58), angle: -28)
    oval(CGRect(x: rect.minX + rect.width * 0.13, y: rect.minY + rect.height * 0.28, width: rect.width * 0.16, height: rect.height * 0.16), fill: NSColor(calibratedRed: 0.98, green: 0.16, blue: 0.18, alpha: 1))
}

func drawCapsule(in rect: CGRect, angle: CGFloat = 0) {
    let context = NSGraphicsContext.current!.cgContext
    context.saveGState()
    context.translateBy(x: rect.midX, y: rect.midY)
    context.rotate(by: angle * .pi / 180)
    context.translateBy(x: -rect.midX, y: -rect.midY)
    rounded(rect, radius: min(rect.width, rect.height) / 2, fill: NSColor(calibratedRed: 0.14, green: 0.45, blue: 1.0, alpha: 1), stroke: .white.withAlphaComponent(0.88), line: rect.width * 0.08)
    rounded(CGRect(x: rect.minX, y: rect.midY, width: rect.width, height: rect.height / 2), radius: rect.width / 2, fill: .white.withAlphaComponent(0.92))
    line(from: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.midY), to: CGPoint(x: rect.maxX - rect.width * 0.12, y: rect.midY), color: .white.withAlphaComponent(0.55), width: rect.width * 0.05)
    context.restoreGState()
}

func drawVirus(in rect: CGRect, boss: Bool) {
    let core = rect.insetBy(dx: rect.width * 0.18, dy: rect.height * 0.18)
    let fill = boss ? NSColor(calibratedRed: 0.76, green: 0.12, blue: 0.17, alpha: 1) : NSColor(calibratedRed: 0.98, green: 0.31, blue: 0.24, alpha: 1)
    for i in 0..<12 {
        let angle = CGFloat(i) / 12 * .pi * 2
        let start = CGPoint(x: rect.midX + cos(angle) * rect.width * 0.28, y: rect.midY + sin(angle) * rect.height * 0.28)
        let end = CGPoint(x: rect.midX + cos(angle) * rect.width * 0.42, y: rect.midY + sin(angle) * rect.height * 0.42)
        line(from: start, to: end, color: fill.withAlphaComponent(0.88), width: boss ? 10 : 6)
        oval(CGRect(x: end.x - (boss ? 9 : 6), y: end.y - (boss ? 9 : 6), width: boss ? 18 : 12, height: boss ? 18 : 12), fill: fill)
    }
    oval(core, fill: fill, stroke: .white.withAlphaComponent(0.65), line: boss ? 7 : 4)
    oval(CGRect(x: core.minX + core.width * 0.26, y: core.minY + core.height * 0.58, width: core.width * 0.16, height: core.height * 0.16), fill: .white)
    oval(CGRect(x: core.minX + core.width * 0.58, y: core.minY + core.height * 0.50, width: core.width * 0.14, height: core.height * 0.14), fill: .white.withAlphaComponent(0.82))
    if boss {
        polygon([
            CGPoint(x: rect.midX - 45, y: rect.maxY - 38),
            CGPoint(x: rect.midX - 20, y: rect.maxY - 75),
            CGPoint(x: rect.midX + 20, y: rect.maxY - 75),
            CGPoint(x: rect.midX + 45, y: rect.maxY - 38),
            CGPoint(x: rect.midX, y: rect.maxY - 56)
        ], fill: NSColor(calibratedRed: 1, green: 0.79, blue: 0.16, alpha: 1), stroke: .white.withAlphaComponent(0.7), lineWidth: 3)
    }
}

func drawGem(in rect: CGRect) {
    polygon([
        CGPoint(x: rect.midX, y: rect.maxY - 18),
        CGPoint(x: rect.maxX - 22, y: rect.midY + 20),
        CGPoint(x: rect.midX, y: rect.minY + 12),
        CGPoint(x: rect.minX + 22, y: rect.midY + 20)
    ], fill: NSColor(calibratedRed: 0.58, green: 0.23, blue: 1, alpha: 1), stroke: .white.withAlphaComponent(0.85), lineWidth: 5)
    line(from: CGPoint(x: rect.midX, y: rect.maxY - 18), to: CGPoint(x: rect.midX, y: rect.minY + 12), color: .white.withAlphaComponent(0.3), width: 3)
}

func drawChest(in rect: CGRect) {
    rounded(CGRect(x: rect.minX + 20, y: rect.minY + 32, width: rect.width - 40, height: rect.height - 72), radius: 18, fill: NSColor(calibratedRed: 0.93, green: 0.47, blue: 0.18, alpha: 1), stroke: .white.withAlphaComponent(0.75), line: 5)
    rounded(CGRect(x: rect.minX + 26, y: rect.midY + 4, width: rect.width - 52, height: 50), radius: 14, fill: NSColor(calibratedRed: 1.0, green: 0.74, blue: 0.24, alpha: 1), stroke: .clear)
    rounded(CGRect(x: rect.midX - 18, y: rect.midY - 14, width: 36, height: 38), radius: 8, fill: NSColor(calibratedRed: 0.20, green: 0.35, blue: 0.62, alpha: 1), stroke: .white.withAlphaComponent(0.65), line: 3)
}

func drawCoin(in rect: CGRect) {
    oval(rect.insetBy(dx: 18, dy: 18), fill: NSColor(calibratedRed: 1.0, green: 0.72, blue: 0.18, alpha: 1), stroke: .white.withAlphaComponent(0.82), line: 6)
    oval(rect.insetBy(dx: 35, dy: 35), fill: NSColor(calibratedRed: 0.96, green: 0.55, blue: 0.12, alpha: 1), stroke: NSColor(calibratedRed: 1.0, green: 0.89, blue: 0.40, alpha: 1), line: 4)
}

func drawTicket(in rect: CGRect) {
    rounded(rect.insetBy(dx: 18, dy: 38), radius: 14, fill: NSColor(calibratedRed: 1.0, green: 0.72, blue: 0.22, alpha: 1), stroke: .white.withAlphaComponent(0.85), line: 5)
    line(from: CGPoint(x: rect.midX, y: rect.minY + 45), to: CGPoint(x: rect.midX, y: rect.maxY - 45), color: .white.withAlphaComponent(0.45), width: 4)
}

func drawHubScene(in rect: CGRect) {
    let sky = NSGradient(colors: [NSColor(calibratedRed: 0.36, green: 0.74, blue: 0.96, alpha: 1), NSColor(calibratedRed: 0.84, green: 0.94, blue: 0.78, alpha: 1)])!
    sky.draw(in: rect, angle: -90)
    oval(CGRect(x: rect.minX + 58, y: rect.maxY - 116, width: 190, height: 72), fill: .white.withAlphaComponent(0.55))
    oval(CGRect(x: rect.maxX - 230, y: rect.maxY - 155, width: 210, height: 78), fill: .white.withAlphaComponent(0.45))
    rounded(CGRect(x: 0, y: 0, width: rect.width, height: rect.height * 0.30), radius: 0, fill: NSColor(calibratedRed: 0.55, green: 0.82, blue: 0.48, alpha: 1))
    for x in stride(from: rect.minX + 60, through: rect.maxX - 40, by: 110) {
        rounded(CGRect(x: x + 24, y: rect.height * 0.27, width: 20, height: 90), radius: 8, fill: NSColor(calibratedRed: 0.50, green: 0.29, blue: 0.22, alpha: 1))
        oval(CGRect(x: x - 8, y: rect.height * 0.39, width: 88, height: 88), fill: NSColor(calibratedRed: 0.95, green: 0.46, blue: 0.34, alpha: 1))
        oval(CGRect(x: x + 28, y: rect.height * 0.43, width: 80, height: 80), fill: NSColor(calibratedRed: 1.0, green: 0.55, blue: 0.37, alpha: 1))
    }
    drawHero(in: CGRect(x: rect.midX - 105, y: rect.height * 0.18, width: 210, height: 210))
    drawChest(in: CGRect(x: rect.maxX - 155, y: 24, width: 110, height: 110))
}

func drawArena(in rect: CGRect) {
    let bg = NSGradient(colors: [NSColor(calibratedRed: 0.10, green: 0.60, blue: 0.91, alpha: 1), NSColor(calibratedRed: 0.20, green: 0.72, blue: 0.96, alpha: 1)])!
    bg.draw(in: rect, angle: -90)
    for i in 0..<42 {
        let x = CGFloat((i * 73) % Int(rect.width))
        let y = CGFloat((i * 151) % Int(rect.height))
        let size = CGFloat(22 + (i % 6) * 15)
        oval(CGRect(x: x, y: y, width: size, height: size), fill: .clear, stroke: .white.withAlphaComponent(0.18), line: 3)
    }
    for i in 0..<18 {
        let x = CGFloat((i * 97 + 20) % Int(rect.width))
        let y = CGFloat((i * 61 + 80) % Int(rect.height))
        rounded(CGRect(x: x, y: y, width: 80, height: 32), radius: 16, fill: .white.withAlphaComponent(0.10))
    }
}

try save(image(size: CGSize(width: 256, height: 256)) { drawHero(in: $0) }, named: "HeroCell")
try save(image(size: CGSize(width: 192, height: 192)) { drawVirus(in: $0, boss: false) }, named: "VirusEnemy")
try save(image(size: CGSize(width: 256, height: 256)) { drawVirus(in: $0, boss: true) }, named: "BossVirus")
try save(image(size: CGSize(width: 160, height: 160)) { drawCapsule(in: $0.insetBy(dx: 45, dy: 20), angle: -28) }, named: "CapsuleShot")
try save(image(size: CGSize(width: 180, height: 180)) { drawChest(in: $0) }, named: "ChestIcon")
try save(image(size: CGSize(width: 128, height: 128)) { drawCoin(in: $0) }, named: "CoinIcon")
try save(image(size: CGSize(width: 128, height: 128)) { drawGem(in: $0) }, named: "GemIcon")
try save(image(size: CGSize(width: 128, height: 128)) { drawTicket(in: $0) }, named: "TicketIcon")
try save(image(size: CGSize(width: 900, height: 620)) { drawHubScene(in: $0) }, named: "BattleHubScene")
try save(image(size: CGSize(width: 900, height: 1600)) { drawArena(in: $0) }, named: "MicroArena")
try save(image(size: CGSize(width: 160, height: 160)) { rect in
    line(from: CGPoint(x: 42, y: 42), to: CGPoint(x: 106, y: 106), color: NSColor(calibratedRed: 0.30, green: 0.72, blue: 0.92, alpha: 1), width: 20)
    rounded(CGRect(x: 80, y: 88, width: 58, height: 38), radius: 8, fill: NSColor(calibratedRed: 0.96, green: 0.32, blue: 0.32, alpha: 1), stroke: .white.withAlphaComponent(0.75), line: 4)
}, named: "ArtifactHammer")
try save(image(size: CGSize(width: 160, height: 160)) { rect in
    oval(rect.insetBy(dx: 30, dy: 30), fill: .clear, stroke: NSColor(calibratedRed: 0.56, green: 0.25, blue: 1.0, alpha: 1), line: 16)
    oval(rect.insetBy(dx: 58, dy: 58), fill: NSColor(calibratedRed: 0.24, green: 0.77, blue: 0.90, alpha: 1), stroke: .white.withAlphaComponent(0.8), line: 4)
}, named: "WeaponOrb")

print("Generated original game art assets.")
