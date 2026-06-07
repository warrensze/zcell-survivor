import SpriteKit

#if os(iOS)
import UIKit
#else
import AppKit
#endif

@MainActor
final class GameScene: SKScene {
    weak var coordinator: RunCoordinator?

    private var loadout = RunLoadout(
        playerLevel: 1,
        attack: 100,
        fireRate: 0.55,
        moveSpeed: 240,
        projectileCount: 1,
        pierce: 0,
        chapterName: "Sneeze Sector"
    )

    private var player = SKSpriteNode(imageNamed: "HeroCell")
    private var targetPoint = CGPoint.zero
    private var playerHealth = 100.0
    private let maxPlayerHealth = 100.0

    private var enemies: [Enemy] = []
    private var projectiles: [Projectile] = []
    private var elapsed = 0.0
    private var lastUpdateTime = 0.0
    private var spawnTimer = 0.0
    private var fireTimer = 0.0
    private var enemiesDefeated = 0
    private var nextUpgradeAt = 12
    private var bossSpawned = false
    private var runFinished = false
    private var waitingForUpgrade = false

    func configure(loadout: RunLoadout) {
        self.loadout = loadout
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.10, green: 0.62, blue: 0.92, alpha: 1)
        targetPoint = CGPoint(x: size.width / 2, y: size.height * 0.42)
        addBackgroundDetails()
        addPlayer()
        spawnEnemy(isBoss: false)
        updateHUD()
    }

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTarget(from: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTarget(from: touches)
    }
    #else
    override func mouseDown(with event: NSEvent) {
        updateTarget(from: event)
    }

    override func mouseDragged(with event: NSEvent) {
        updateTarget(from: event)
    }
    #endif

    override func update(_ currentTime: TimeInterval) {
        guard !runFinished, !waitingForUpgrade else { return }
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let dt = min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime
        elapsed += dt
        spawnTimer -= dt
        fireTimer -= dt

        movePlayer(dt: dt)
        spawnIfNeeded()
        fireIfNeeded()
        moveEnemies(dt: dt)
        moveProjectiles(dt: dt)
        checkCollisions()
        checkMilestones()
        updateHUD()
    }

    func applyUpgrade(_ card: UpgradeCard) {
        switch card.effect {
        case .damage:
            loadout.attack += card.amount
        case .fireRate:
            loadout.fireRate = max(0.18, loadout.fireRate - card.amount)
        case .projectileCount:
            loadout.projectileCount += Int(card.amount)
        case .pierce:
            loadout.pierce += Int(card.amount)
        case .speed:
            loadout.moveSpeed += card.amount
        case .orbit:
            loadout.attack += card.amount * 0.75
            loadout.projectileCount += 1
        }

        waitingForUpgrade = false
        lastUpdateTime = 0
    }

    func finishRun(victory: Bool) {
        guard !runFinished else { return }
        runFinished = true
        let defeated = max(enemiesDefeated, victory ? 42 : enemiesDefeated)
        coordinator?.finish(
            RunResult(
                victory: victory,
                coinsEarned: defeated * 18 + (victory ? 1_000 : 250),
                gemsEarned: victory ? 18 : 4,
                enemiesDefeated: defeated,
                stageName: "Stage 1 \(loadout.chapterName)"
            )
        )
    }

    private func addBackgroundDetails() {
        let background = SKSpriteNode(imageNamed: "MicroArena")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -10
        background.size = coverSize(textureSize: background.texture?.size() ?? size, in: size)
        addChild(background)

        for index in 0..<24 {
            let radius = CGFloat(10 + (index % 5) * 9)
            let bubble = SKShapeNode(circleOfRadius: radius)
            bubble.strokeColor = .white.withAlphaComponent(0.20)
            bubble.lineWidth = 2
            bubble.fillColor = .clear
            bubble.position = CGPoint(
                x: CGFloat((index * 47) % Int(max(size.width, 1))),
                y: CGFloat((index * 91) % Int(max(size.height, 1)))
            )
            bubble.zPosition = -5
            addChild(bubble)
        }

        for index in 0..<12 {
            let capsule = SKShapeNode(rectOf: CGSize(width: 54, height: 24), cornerRadius: 12)
            capsule.fillColor = .white.withAlphaComponent(0.14)
            capsule.strokeColor = .clear
            capsule.position = CGPoint(
                x: CGFloat((index * 83 + 30) % Int(max(size.width, 1))),
                y: CGFloat((index * 67 + 90) % Int(max(size.height, 1)))
            )
            capsule.zRotation = CGFloat(index) * 0.3
            capsule.zPosition = -4
            addChild(capsule)
        }
    }

    private func addPlayer() {
        player.size = CGSize(width: 58, height: 58)
        player.position = targetPoint
        player.zPosition = 20
        addChild(player)

        let pointerPath = CGMutablePath()
        pointerPath.move(to: CGPoint(x: -9, y: -26))
        pointerPath.addLine(to: CGPoint(x: 0, y: -43))
        pointerPath.addLine(to: CGPoint(x: 9, y: -26))
        pointerPath.closeSubpath()
        let pointer = SKShapeNode(path: pointerPath)
        pointer.fillColor = SKColor.white.withAlphaComponent(0.65)
        pointer.strokeColor = SKColor.clear
        pointer.zPosition = 19
        player.addChild(pointer)
    }

    #if os(iOS)
    private func updateTarget(from touches: Set<UITouch>) {
        guard let location = touches.first?.location(in: self) else { return }
        targetPoint = CGPoint(
            x: min(max(location.x, 28), size.width - 28),
            y: min(max(location.y, 80), size.height - 80)
        )
    }
    #else
    private func updateTarget(from event: NSEvent) {
        let location = event.location(in: self)
        targetPoint = CGPoint(
            x: min(max(location.x, 28), size.width - 28),
            y: min(max(location.y, 80), size.height - 80)
        )
    }
    #endif

    private func movePlayer(dt: TimeInterval) {
        let vector = CGVector(dx: targetPoint.x - player.position.x, dy: targetPoint.y - player.position.y)
        let distance = hypot(vector.dx, vector.dy)
        guard distance > 2 else { return }

        let step = min(CGFloat(loadout.moveSpeed * dt), distance)
        player.position.x += vector.dx / distance * step
        player.position.y += vector.dy / distance * step
    }

    private func spawnIfNeeded() {
        if !bossSpawned, elapsed > 58 {
            bossSpawned = true
            spawnEnemy(isBoss: true)
        }

        guard spawnTimer <= 0 else { return }
        spawnTimer = max(0.18, 0.82 - elapsed * 0.006)
        let count = elapsed > 32 ? 3 : elapsed > 16 ? 2 : 1
        for _ in 0..<count {
            spawnEnemy(isBoss: false)
        }
    }

    private func spawnEnemy(isBoss: Bool) {
        let radius = isBoss ? CGFloat(42) : CGFloat.random(in: 15...25)
        let node = SKSpriteNode(imageNamed: isBoss ? "BossVirus" : "VirusEnemy")
        node.size = CGSize(width: radius * (isBoss ? 2.8 : 2.4), height: radius * (isBoss ? 2.8 : 2.4))
        node.zPosition = isBoss ? 16 : 12

        let side = Int.random(in: 0..<4)
        switch side {
        case 0:
            node.position = CGPoint(x: -radius, y: CGFloat.random(in: 90...(size.height - 90)))
        case 1:
            node.position = CGPoint(x: size.width + radius, y: CGFloat.random(in: 90...(size.height - 90)))
        case 2:
            node.position = CGPoint(x: CGFloat.random(in: 30...(size.width - 30)), y: size.height + radius)
        default:
            node.position = CGPoint(x: CGFloat.random(in: 30...(size.width - 30)), y: -radius)
        }

        addChild(node)
        enemies.append(
            Enemy(
                node: node,
                health: isBoss ? 4_500 : 150 + elapsed * 7,
                speed: isBoss ? 52 : Double.random(in: 68...112),
                radius: radius,
                isBoss: isBoss
            )
        )
    }

    private func fireIfNeeded() {
        guard fireTimer <= 0 else { return }
        fireTimer = loadout.fireRate

        let targets = enemies
            .sorted { distance($0.node.position, player.position) < distance($1.node.position, player.position) }
            .prefix(max(1, loadout.projectileCount))

        guard !targets.isEmpty else { return }

        for target in targets {
            let direction = normalizedVector(from: player.position, to: target.node.position)
            let projectileNode = SKSpriteNode(imageNamed: "CapsuleShot")
            projectileNode.size = CGSize(width: 28, height: 28)
            projectileNode.position = player.position
            projectileNode.zRotation = atan2(direction.dy, direction.dx) - .pi / 2
            projectileNode.zPosition = 18
            addChild(projectileNode)

            projectiles.append(
                Projectile(
                    node: projectileNode,
                    velocity: CGVector(dx: direction.dx * 480, dy: direction.dy * 480),
                    pierceLeft: loadout.pierce
                )
            )
        }
    }

    private func moveEnemies(dt: TimeInterval) {
        for index in enemies.indices {
            let node = enemies[index].node
            let direction = normalizedVector(from: node.position, to: player.position)
            node.position.x += direction.dx * CGFloat(enemies[index].speed * dt)
            node.position.y += direction.dy * CGFloat(enemies[index].speed * dt)

            if distance(node.position, player.position) < enemies[index].radius + 22 {
                playerHealth -= enemies[index].isBoss ? 24 * dt : 9 * dt
                player.setScale(1.0 + CGFloat.random(in: 0...0.025))
                if playerHealth <= 0 {
                    finishRun(victory: false)
                }
            }
        }
    }

    private func moveProjectiles(dt: TimeInterval) {
        for index in projectiles.indices.reversed() {
            let projectile = projectiles[index]
            projectile.node.position.x += projectile.velocity.dx * CGFloat(dt)
            projectile.node.position.y += projectile.velocity.dy * CGFloat(dt)

            if projectile.node.position.x < -40 ||
                projectile.node.position.x > size.width + 40 ||
                projectile.node.position.y < -40 ||
                projectile.node.position.y > size.height + 40 {
                projectile.node.removeFromParent()
                projectiles.remove(at: index)
            }
        }
    }

    private func checkCollisions() {
        for projectileIndex in projectiles.indices.reversed() {
            guard projectileIndex < projectiles.count else { continue }
            var projectileRemoved = false

            for enemyIndex in enemies.indices.reversed() {
                guard enemyIndex < enemies.count, projectileIndex < projectiles.count else { continue }
                let hitDistance = enemies[enemyIndex].radius + 8
                guard distance(projectiles[projectileIndex].node.position, enemies[enemyIndex].node.position) < hitDistance else {
                    continue
                }

                enemies[enemyIndex].health -= loadout.attack
                showDamage(Int(loadout.attack), at: enemies[enemyIndex].node.position)

                if enemies[enemyIndex].health <= 0 {
                    let wasBoss = enemies[enemyIndex].isBoss
                    enemies[enemyIndex].node.removeFromParent()
                    enemies.remove(at: enemyIndex)
                    enemiesDefeated += wasBoss ? 10 : 1
                    if wasBoss {
                        finishRun(victory: true)
                    }
                }

                if projectiles[projectileIndex].pierceLeft > 0 {
                    projectiles[projectileIndex].pierceLeft -= 1
                } else {
                    projectiles[projectileIndex].node.removeFromParent()
                    projectiles.remove(at: projectileIndex)
                    projectileRemoved = true
                }

                if projectileRemoved {
                    break
                }
            }
        }
    }

    private func checkMilestones() {
        if enemiesDefeated >= nextUpgradeAt {
            nextUpgradeAt += 14
            waitingForUpgrade = true
            coordinator?.showUpgradeChoices(Self.randomUpgrades())
        }
    }

    private func showDamage(_ amount: Int, at position: CGPoint) {
        let label = SKLabelNode(text: compactDamage(amount))
        label.fontName = "AvenirNext-Heavy"
        label.fontSize = 22
        label.fontColor = .white
        label.position = position
        label.zPosition = 30
        addChild(label)

        label.run(.sequence([
            .group([
                .moveBy(x: 0, y: 42, duration: 0.55),
                .fadeOut(withDuration: 0.55)
            ]),
            .removeFromParent()
        ]))
    }

    private func updateHUD() {
        coordinator?.updateHUD(
            RunHUD(
                stageTitle: "Stage \(max(1, loadout.playerLevel / 6)) \(loadout.chapterName)",
                health: max(0, playerHealth / maxPlayerHealth),
                enemiesDefeated: enemiesDefeated,
                elapsed: Int(elapsed)
            )
        )
    }

    private static func randomUpgrades() -> [UpgradeCard] {
        let deck = [
            UpgradeCard(title: "Capsule Power", detail: "Damage +45", rarity: .common, symbol: "capsule.fill", effect: .damage, amount: 45),
            UpgradeCard(title: "Quick Pulse", detail: "Fire rate improves", rarity: .common, symbol: "timer", effect: .fireRate, amount: 0.08),
            UpgradeCard(title: "Extra Capsule", detail: "Shoot one more target", rarity: .rare, symbol: "plus.circle.fill", effect: .projectileCount, amount: 1),
            UpgradeCard(title: "Deep Pierce", detail: "Shots pass through one extra enemy", rarity: .rare, symbol: "arrow.up.forward.circle.fill", effect: .pierce, amount: 1),
            UpgradeCard(title: "Skyfall Spark", detail: "Large damage boost", rarity: .epic, symbol: "sparkles", effect: .damage, amount: 110),
            UpgradeCard(title: "Tide Orbit", detail: "Gain damage and an extra shot", rarity: .epic, symbol: "moonphase.waning.crescent", effect: .orbit, amount: 90),
            UpgradeCard(title: "Antibody Rush", detail: "Move faster", rarity: .common, symbol: "hare.fill", effect: .speed, amount: 55),
            UpgradeCard(title: "Serum Nova", detail: "Massive power spike", rarity: .legendary, symbol: "star.circle.fill", effect: .damage, amount: 220)
        ]

        var choices: [UpgradeCard] = []
        while choices.count < 3 {
            let roll = Double.random(in: 0...1)
            let rarity: Rarity = if roll > 0.94 {
                .legendary
            } else if roll > 0.72 {
                .epic
            } else if roll > 0.38 {
                .rare
            } else {
                .common
            }

            let pool = deck.filter { $0.rarity == rarity }
            if let card = pool.randomElement(), !choices.contains(where: { $0.title == card.title }) {
                choices.append(card)
            }
        }
        return choices
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }

    private func normalizedVector(from start: CGPoint, to end: CGPoint) -> CGVector {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = max(hypot(dx, dy), 0.001)
        return CGVector(dx: dx / length, dy: dy / length)
    }

    private func coverSize(textureSize: CGSize, in containerSize: CGSize) -> CGSize {
        guard textureSize.width > 0, textureSize.height > 0 else { return containerSize }
        let scale = max(containerSize.width / textureSize.width, containerSize.height / textureSize.height)
        return CGSize(width: textureSize.width * scale, height: textureSize.height * scale)
    }

    private func compactDamage(_ value: Int) -> String {
        if value >= 1_000 {
            return String(format: "%.1fK", Double(value) / 1_000)
        }
        return "\(value)"
    }
}

private struct Enemy {
    var node: SKSpriteNode
    var health: Double
    var speed: Double
    var radius: CGFloat
    var isBoss: Bool
}

private struct Projectile {
    var node: SKSpriteNode
    var velocity: CGVector
    var pierceLeft: Int
}
