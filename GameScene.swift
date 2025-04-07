//
//  GameScene.swift
//  Number x2 Match Game
//
//  Created by Lev Vlasov on 2025-04-03.
//

import SpriteKit
import CoreData

struct GameConfig {
    static let gridSize: Int = 5
    static let cellSize: CGFloat = 65
    static let cellSpacing: CGFloat = 10
    static let fontSize: CGFloat = 30 // Устанавливаем тот же размер, что у счета
    static let fontSizeLarge: CGFloat = 20 // Для больших чисел (например, 1000+)
    static let defaultFontColor: UIColor = .white
    
    static let backgroundColors: [Int: UIColor] = [
        2: UIColor(red: 194/255, green: 122/255, blue: 195/255, alpha: 1.0), // #c27ac3 purple
        4: UIColor(red: 255/255, green: 161/255, blue: 197/255, alpha: 1.0), // #ffa1c5 pink
        8: UIColor(red: 144/255, green: 224/255, blue: 239/255, alpha: 1.0), // #90e0ef blue
        16: UIColor(red: 252/255, green: 219/255, blue: 109/255, alpha: 1.0), // #fcdb6d yellow
        32: UIColor(red: 172/255, green: 221/255, blue: 147/255, alpha: 1.0), // #acdd93 green
        64: UIColor(red: 255/255, green: 170/255, blue: 110/255, alpha: 1.0), // #ffaa6e orange
        128: UIColor(red: 128/255, green: 14/255, blue: 19/255, alpha: 1.0), // #800e13 red
        256: UIColor(red: 204/255, green: 153/255, blue: 255/255, alpha: 1.0), // Светло-фиолетовый (оставляем)
        512: UIColor(red: 2/255, green: 62/255, blue: 138/255, alpha: 1.0), // #023e8a blue (новый)
        1024: UIColor(red: 202/255, green: 240/255, blue: 248/255, alpha: 1.0), // #caf0f8 sky
        2048: UIColor(red: 255/255, green: 85/255, blue: 161/255, alpha: 1.0), // #ff55a1 pink (новый)
        4096: UIColor(red: 255/255, green: 68/255, blue: 204/255, alpha: 1.0), // #ff44cc neon pink
        8192: UIColor(red: 153/255, green: 153/255, blue: 255/255, alpha: 1.0), // Светло-синий (оставляем)
        16384: UIColor(red: 250/255, green: 207/255, blue: 67/255, alpha: 1.0), // #facf43 yellow
        32768: UIColor(red: 173/255, green: 40/255, blue: 49/255, alpha: 1.0), // #ad2831 red
        65536: UIColor(red: 255/255, green: 130/255, blue: 55/255, alpha: 1.0), // #ff8237 orange
        131072: UIColor(red: 72/255, green: 202/255, blue: 228/255, alpha: 1.0), // #48cae4 blue
        262144: UIColor(red: 147/255, green: 199/255, blue: 119/255, alpha: 1.0), // #93c777 green
        524288: UIColor(red: 95/255, green: 61/255, blue: 140/255, alpha: 1.0), // #5f3d8c purple
        1048576: UIColor(red: 253/255, green: 235/255, blue: 158/255, alpha: 1.0), // #fdeb9e yellow
        2097152: UIColor(red: 255/255, green: 126/255, blue: 179/255, alpha: 1.0), // #ff7eb3 pink
        4194304: UIColor(red: 0/255, green: 119/255, blue: 182/255, alpha: 1.0), // #0077b6 blue
        8388608: UIColor(red: 255/255, green: 170/255, blue: 110/255, alpha: 1.0), // #ffaa6e orange
        16777216: UIColor(red: 56/255, green: 4/255, blue: 14/255, alpha: 1.0), // #38040e red
        33554432: UIColor(red: 172/255, green: 221/255, blue: 147/255, alpha: 1.0), // #acdd93 green
        67108864: UIColor(red: 252/255, green: 219/255, blue: 109/255, alpha: 1.0), // #fcdb6d yellow
        134217728: UIColor(red: 255/255, green: 193/255, blue: 216/255, alpha: 1.0), // #ffc1d8 pink
        268435456: UIColor(red: 49/255, green: 38/255, blue: 113/255, alpha: 1.0), // #312671 purple
        536870912: UIColor(red: 173/255, green: 232/255, blue: 244/255, alpha: 1.0), // #ade8f4 blue
        1073741824: UIColor(red: 37/255, green: 9/255, blue: 2/255, alpha: 1.0) // #250902 red
    ]
    
    // Анимации
    static let newNodeAppearDuration: TimeInterval = 0.1
    static let newNodeMoveDuration: TimeInterval = 0.2
    static let dropMoveDuration: TimeInterval = 0.2
    static let mergeScaleDuration: TimeInterval = 0.1
    static let mergeMoveDuration: TimeInterval = 0.1
    static let explosionDuration: TimeInterval = 0.3
    static let particleCount: Int = 20
    static let connectingLineWidth: CGFloat = 8
    static let connectingLineColor: UIColor = .white
    static let lineExplosionColor: UIColor = .white
    static let trailLength: CGFloat = 30.0
    
    // Новые параметры для UI
    static let scoreFontSize: CGFloat = 40
    static let bestScoreFontSize: CGFloat = 24
    static let gameOverFontSize: CGFloat = 48
    
    // Параметры для эффекта разлома
    static let fragmentScatterDuration: TimeInterval = 0.2
    static let fragmentFallDuration: TimeInterval = 0.5
    static let fragmentExplosionScale: CGFloat = 0.5
    static let fragmentScatterDistance: CGFloat = 50.0
}

// Класс для узлов (обновляем шрифт и размер текста)
class NumberNode: SKLabelNode {
    var row: Int
    var col: Int
    private var background: SKShapeNode!

    init(value: Int, row: Int, col: Int) {
        self.row = row
        self.col = col
        super.init()

        let validValue = value > 0 ? value : 2
        self.text = "\(validValue)"
        self.fontName = "Futura-Bold"
        self.fontColor = GameConfig.defaultFontColor
        self.horizontalAlignmentMode = .center
        self.verticalAlignmentMode = .center
        self.name = "number"
        self.fontSize = validValue >= 1000 ? GameConfig.fontSizeLarge : GameConfig.fontSize // Используем тот же размер

        // Круг
        background = SKShapeNode(circleOfRadius: GameConfig.cellSize / 2)
        updateBackgroundColor(value: validValue)
        background.strokeColor = .clear
        background.zPosition = -1
        self.addChild(background)

        self.physicsBody = SKPhysicsBody(circleOfRadius: GameConfig.cellSize / 2)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
    }

    func updateBackgroundColor(value: Int) {
        let color = GameConfig.backgroundColors[value] ?? .gray
        background.fillColor = color
    }

    func updateValue(_ newValue: Int) {
        let validValue = newValue > 0 ? newValue : 2
        self.text = "\(validValue)"
        self.fontSize = validValue >= 1000 ? GameConfig.fontSizeLarge : GameConfig.fontSize
        updateBackgroundColor(value: validValue)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let gridSize = GameConfig.gridSize
    var grid: [[NumberNode?]] = []
    var selectedNodes: [NumberNode] = []
    var connectingLine: SKShapeNode?
    var currentTouchLocation: CGPoint?
    var isAnimating = false
    var isProcessingMerge = false
    
    // Переменные для счета
    var score: Int = 0
    var bestScore: Int = 0
    var scoreLabel: SKLabelNode!
    var bestScoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode?
    
    // Core Data контекст
    var managedObjectContext: NSManagedObjectContext!
    
    // Физические категории
    let fragmentCategory: UInt32 = 0x1 << 0
    let groundCategory: UInt32 = 0x1 << 1
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = .white
        
        // Настройка физического мира
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        // Добавляем "пол" для физического контакта
        let ground = SKNode()
        ground.position = CGPoint(x: size.width / 2, y: -GameConfig.cellSize)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 10))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = fragmentCategory
        ground.physicsBody?.collisionBitMask = 0
        addChild(ground)
        
        setupGrid()
        setupScoreLabels()
        loadBestScore()
        
        // Регистрируем уведомление для сохранения счета при выходе
        NotificationCenter.default.addObserver(self, selector: #selector(saveScoreOnExit), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    deinit {
        // Удаляем наблюдатель при уничтожении сцены
        NotificationCenter.default.removeObserver(self)
    }
    
    // Сохранение счета при выходе из приложения
    @objc func saveScoreOnExit() {
        saveBestScore()
    }
    
    // Настройка UI для счета
    func setupScoreLabels() {
        // Вычисляем верхнюю границу игрового поля
        let cellSize = GameConfig.cellSize
        let spacing = GameConfig.cellSpacing
        let totalHeight = CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing
        let startY = (size.height - totalHeight) / 2
        let topOfGrid = startY + totalHeight
        
        // Текущий счет (50px выше верхней границы поля)
        scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        let scoreText = "$\(score)"
        let attributedString = NSMutableAttributedString(string: scoreText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 1, length: scoreText.count - 1))
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: GameConfig.scoreFontSize)!, range: NSRange(location: 0, length: scoreText.count))
        scoreLabel.attributedText = attributedString
        scoreLabel.position = CGPoint(x: size.width / 2, y: topOfGrid + 50 + 40)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
        
        // Лучший счет (под текущим счетом)
        bestScoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        let bestScoreText = "Best: $\(bestScore)"
        let bestAttributedString = NSMutableAttributedString(string: bestScoreText)
        bestAttributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 5))
        bestAttributedString.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 5, length: 1))
        bestAttributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 6, length: bestScoreText.count - 6))
        bestAttributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: GameConfig.bestScoreFontSize)!, range: NSRange(location: 0, length: bestScoreText.count))
        bestScoreLabel.attributedText = bestAttributedString
        bestScoreLabel.position = CGPoint(x: size.width / 2, y: topOfGrid + 50)
        bestScoreLabel.zPosition = 10
        addChild(bestScoreLabel)
    }
    
    // Загрузка лучшего счета из Core Data
    func loadBestScore() {
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "GameScore")
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            if let gameScore = results.first {
                bestScore = gameScore.value(forKey: "bestScore") as? Int ?? 0
                let bestScoreText = "Best: $\(bestScore)"
                let bestAttributedString = NSMutableAttributedString(string: bestScoreText)
                bestAttributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 5))
                bestAttributedString.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 5, length: 1))
                bestAttributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 6, length: bestScoreText.count - 6))
                bestAttributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: GameConfig.bestScoreFontSize)!, range: NSRange(location: 0, length: bestScoreText.count))
                bestScoreLabel.attributedText = bestAttributedString
            }
        } catch {
            print("Ошибка загрузки лучшего счета: \(error)")
        }
    }
    
    // Сохранение лучшего счета в Core Data
    func saveBestScore() {
        if score > bestScore {
            bestScore = score
            let bestScoreText = "Best: $\(bestScore)"
            let bestAttributedString = NSMutableAttributedString(string: bestScoreText)
            bestAttributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: 5))
            bestAttributedString.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 5, length: 1))
            bestAttributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 6, length: bestScoreText.count - 6))
            bestAttributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: GameConfig.bestScoreFontSize)!, range: NSRange(location: 0, length: bestScoreText.count))
            bestScoreLabel.attributedText = bestAttributedString
            
            let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "GameScore")
            do {
                let results = try managedObjectContext.fetch(fetchRequest)
                if let gameScore = results.first {
                    gameScore.setValue(bestScore, forKey: "bestScore")
                } else {
                    let entity = NSEntityDescription.entity(forEntityName: "GameScore", in: managedObjectContext)!
                    let newScore = NSManagedObject(entity: entity, insertInto: managedObjectContext)
                    newScore.setValue(bestScore, forKey: "bestScore")
                }
                try managedObjectContext.save()
            } catch {
                print("Ошибка сохранения лучшего счета: \(error)")
            }
        }
    }
    
    func setupGrid() {
        grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
        
        let cellSize = GameConfig.cellSize
        let spacing = GameConfig.cellSpacing
        let totalWidth = CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing
        let totalHeight = CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing
        
        let startX = (size.width - totalWidth) / 2
        let startY = (size.height - totalHeight) / 2
        
        let initialValues = [2, 4, 8, 16, 32, 64, 128]
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let value = initialValues.randomElement() ?? 2
                let node = NumberNode(value: value, row: row, col: col)
                node.position = CGPoint(
                    x: startX + CGFloat(col) * (cellSize + spacing) + cellSize / 2,
                    y: startY + CGFloat(row) * (cellSize + spacing) + cellSize / 2
                )
                addChild(node)
                grid[row][col] = node
            }
        }
    }
    
    // Создание текстур программно
    func createSparkTexture() -> SKTexture {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(UIColor.white.cgColor)
        context.addEllipse(in: CGRect(origin: .zero, size: size))
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }
    
    func createTrailTexture() -> SKTexture {
        let size = CGSize(width: 20, height: 5)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }
    
    // Эффекты частиц
    private func createExplosion(at position: CGPoint, color: UIColor) {
        let emitter = SKEmitterNode()
        emitter.position = position
        emitter.particleTexture = createSparkTexture()
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = GameConfig.particleCount
        emitter.particleLifetime = 0.5
        emitter.emissionAngleRange = 360
        emitter.particleSpeed = 200
        emitter.particleScale = GameConfig.fragmentExplosionScale
        emitter.particleScaleRange = 0.1
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        
        addChild(emitter)
        
        let wait = SKAction.wait(forDuration: GameConfig.explosionDuration)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }
    
    private func createParticleTrail(from position: CGPoint, color: UIColor) {
        let emitter = SKEmitterNode()
        emitter.position = position
        emitter.particleTexture = createTrailTexture()
        emitter.particleBirthRate = 200
        emitter.particleLifetime = 0.3
        emitter.particleSpeed = 150
        emitter.emissionAngleRange = 360
        emitter.particleScale = 0.1
        emitter.particleColor = color
        emitter.particleColorBlendFactor = 1.0
        
        addChild(emitter)
        
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([fade, remove]))
    }
    
    // Создание текстур для разломанных частей
    func createFragmentTexture(color: UIColor, quadrant: Int) -> SKTexture {
        let size = CGSize(width: GameConfig.cellSize / 2, height: GameConfig.cellSize / 2)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(2.0)
        
        let path = CGMutablePath()
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = GameConfig.cellSize / 2
        
        switch quadrant {
        case 0: // Верхний левый
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: .pi, endAngle: 3 * .pi / 2, clockwise: false)
            path.closeSubpath()
        case 1: // Верхний правый
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: 3 * .pi / 2, endAngle: 0, clockwise: false)
            path.closeSubpath()
        case 2: // Нижний левый
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi, clockwise: false)
            path.closeSubpath()
        case 3: // Нижний правый
            path.move(to: center)
            path.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi / 2, clockwise: false)
            path.closeSubpath()
        default:
            break
        }
        
        context.addPath(path)
        context.fillPath()
        context.addPath(path)
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return SKTexture(image: image)
    }
    
    // Обработка касаний
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let node = nodeAtPoint(location) {
            selectedNodes.append(node)
            currentTouchLocation = node.position
            updateConnectingLine()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        currentTouchLocation = location
        
        if let node = nodeAtPoint(location) {
            if let index = selectedNodes.firstIndex(of: node) {
                selectedNodes = Array(selectedNodes[0...index])
                updateConnectingLine()
                return
            }
            
            if let firstNode = selectedNodes.first, node.text == firstNode.text {
                if isAdjacent(to: node) {
                    selectedNodes.append(node)
                }
            }
        }
        
        updateConnectingLine()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isAnimating { return }
        
        if selectedNodes.count >= 2 {
            mergeSelectedNodes()
        }
        clearSelection()
        removeConnectingLine()
        currentTouchLocation = nil
        
        // Проверка на конец игры
        if !canMakeMove() {
            endGame()
        }
    }

    func nodeAtPoint(_ point: CGPoint) -> NumberNode? {
        let nodes = self.nodes(at: point)
        for node in nodes {
            if let numberNode = node as? NumberNode {
                let nodeFrame = CGRect(
                    x: numberNode.position.x - 35,
                    y: numberNode.position.y - 35,
                    width: 70,
                    height: 70
                )
                if nodeFrame.contains(point) {
                    return numberNode
                }
            }
        }
        return nil
    }
    
    func isAdjacent(to node: NumberNode) -> Bool {
        guard let lastNode = selectedNodes.last else { return true }
        let rowDiff = abs(node.row - lastNode.row)
        let colDiff = abs(node.col - lastNode.col)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1) || (rowDiff == 1 && colDiff == 1)
    }
    
    func clearSelection() {
        selectedNodes.forEach { $0.fontColor = .white }
        selectedNodes.removeAll()
    }
    
    // Линия соединения с анимацией
    func updateConnectingLine() {
        removeConnectingLine()
        
        if selectedNodes.isEmpty { return }
        
        let path = CGMutablePath()
        let firstNode = selectedNodes.first!
        path.move(to: firstNode.position)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = GameConfig.lineExplosionColor
        line.lineWidth = GameConfig.connectingLineWidth
        line.zPosition = 1
        line.glowWidth = 4.0
        
        for i in 1..<selectedNodes.count {
            path.addLine(to: selectedNodes[i].position)
            let midPoint = CGPoint(
                x: (selectedNodes[i-1].position.x + selectedNodes[i].position.x) / 2,
                y: (selectedNodes[i-1].position.y + selectedNodes[i].position.y) / 2
            )
            createExplosion(at: midPoint, color: GameConfig.lineExplosionColor)
        }
        
        if let touchLocation = currentTouchLocation, selectedNodes.count > 0 {
            path.addLine(to: touchLocation)
        }
        
        line.path = path
        addChild(line)
        connectingLine = line
        
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        line.run(SKAction.repeatForever(pulse))
    }
    
    func removeConnectingLine() {
        connectingLine?.removeFromParent()
        connectingLine = nil
    }
    
    // Слияние с новым эффектом разлета и падения
    func mergeSelectedNodes() {
        guard let firstNode = selectedNodes.first,
              let value = Int(firstNode.text ?? "") else { return }
              
        if isProcessingMerge { return }
        isProcessingMerge = true

        let allSameValue = selectedNodes.allSatisfy { $0.text == firstNode.text }
        if !allSameValue { return }

        // Обновление счета
        let points = value * selectedNodes.count
        score += points
        let scoreText = "$\(score)"
        let attributedString = NSMutableAttributedString(string: scoreText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 0, length: 1))
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 1, length: scoreText.count - 1))
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: GameConfig.scoreFontSize)!, range: NSRange(location: 0, length: scoreText.count))
        scoreLabel.attributedText = attributedString

        let newValue = value * 2
        let targetColor = GameConfig.backgroundColors[newValue] ?? .gray
        
        if let line = connectingLine {
            let explodeLine = SKAction.sequence([
                SKAction.scale(to: 1.5, duration: 0.1),
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ])
            line.run(explodeLine)
            createExplosion(at: line.position, color: GameConfig.lineExplosionColor)
        }

        // Эффект разлома для каждого исчезающего круга
        for node in selectedNodes.dropFirst() {
            let nodeColor = GameConfig.backgroundColors[value] ?? .gray
            
            // Скрываем сам узел
            let fadeAction = SKAction.fadeOut(withDuration: 0.15)
            node.run(fadeAction) {
                node.removeFromParent()
            }
            
            // Создаем 4 части разлома
            for quadrant in 0..<4 {
                let fragment = SKSpriteNode(texture: self.createFragmentTexture(color: nodeColor, quadrant: quadrant))
                fragment.position = node.position
                
                // Смещаем каждую часть в зависимости от квадранта
                let offset: CGPoint
                switch quadrant {
                case 0: // Верхний левый
                    offset = CGPoint(x: -GameConfig.cellSize / 4, y: GameConfig.cellSize / 4)
                case 1: // Верхний правый
                    offset = CGPoint(x: GameConfig.cellSize / 4, y: GameConfig.cellSize / 4)
                case 2: // Нижний левый
                    offset = CGPoint(x: -GameConfig.cellSize / 4, y: -GameConfig.cellSize / 4)
                case 3: // Нижний правый
                    offset = CGPoint(x: GameConfig.cellSize / 4, y: -GameConfig.cellSize / 4)
                default:
                    offset = .zero
                }
                
                fragment.position = CGPoint(x: node.position.x + offset.x, y: node.position.y + offset.y)
                fragment.zPosition = 5
                
                // Добавляем физику для разлета и падения
                fragment.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: GameConfig.cellSize / 2, height: GameConfig.cellSize / 2))
                fragment.physicsBody?.isDynamic = true
                fragment.physicsBody?.categoryBitMask = fragmentCategory
                fragment.physicsBody?.contactTestBitMask = groundCategory
                fragment.physicsBody?.collisionBitMask = 0
                fragment.physicsBody?.mass = 0.1
                
                // Начальный импульс для разлета
                let angle = CGFloat.random(in: 0...(2 * .pi))
                let impulse = CGVector(dx: cos(angle) * GameConfig.fragmentScatterDistance, dy: sin(angle) * GameConfig.fragmentScatterDistance)
                fragment.physicsBody?.applyImpulse(impulse)
                
                // Добавляем вращение
                let rotateAction = SKAction.rotate(byAngle: CGFloat.random(in: -2...2), duration: GameConfig.fragmentFallDuration)
                fragment.run(rotateAction)
                
                addChild(fragment)
            }
            
            grid[node.row][node.col] = nil
        }
        
        firstNode.updateValue(newValue)
        let resultAction = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        firstNode.run(resultAction)
        createExplosion(at: firstNode.position, color: targetColor)
        
        grid[firstNode.row][firstNode.col] = firstNode
        
        dropNodes()
        clearSelection()
    }
    
    // Обработка контакта фрагментов с "полом"
    func didBegin(_ contact: SKPhysicsContact) {
        let fragment: SKSpriteNode
        if contact.bodyA.categoryBitMask == fragmentCategory {
            fragment = contact.bodyA.node as! SKSpriteNode
        } else {
            fragment = contact.bodyB.node as! SKSpriteNode
        }
        
        // Получаем цвет фрагмента
        let fragmentColor = fragment.texture != nil ? GameConfig.backgroundColors[Int(fragment.name ?? "0") ?? 0] ?? .gray : .gray
        
        // Создаем взрыв
        createExplosion(at: fragment.position, color: fragmentColor)
        fragment.removeFromParent()
    }
    
    func dropNodes() {
        for col in 0..<gridSize {
            var newColumn: [NumberNode?] = []
            var currentPositions: [CGPoint] = []
            var targetPositions: [CGPoint] = []
            
            for row in 0..<gridSize {
                if let node = grid[row][col] {
                    newColumn.append(node)
                    currentPositions.append(node.position)
                }
            }
            
            for row in 0..<gridSize {
                if row < newColumn.count {
                    if let node = newColumn[row] {
                        let targetRow = row
                        let cellSize = GameConfig.cellSize
                        let spacing = GameConfig.cellSpacing
                        let startX = (size.width - (CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing)) / 2
                        let targetY = (size.height - (CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing)) / 2 + CGFloat(targetRow) * (cellSize + spacing) + cellSize / 2
                        let targetX = startX + CGFloat(col) * (cellSize + spacing) + cellSize / 2
                        targetPositions.append(CGPoint(x: targetX, y: targetY))
                        grid[targetRow][col] = node
                        node.row = targetRow
                    }
                } else {
                    grid[row][col] = nil
                }
            }
            
            for (index, node) in newColumn.enumerated() {
                if let node = node,
                   index < currentPositions.count,
                   index < targetPositions.count {
                    let moveAction = SKAction.move(to: targetPositions[index], duration: GameConfig.dropMoveDuration)
                    node.run(moveAction)
                }
            }
        }
        
        addNewNodesWithAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateNodePositions()
            self.isProcessingMerge = false
            self.isAnimating = false
            
            // Проверка на конец игры после каждого хода
            if !self.canMakeMove() {
                self.endGame()
            }
        }
    }
    
    func addNewNodesWithAnimation() {
        let cellSize = GameConfig.cellSize
        let spacing = GameConfig.cellSpacing
        let startX = (size.width - (CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing)) / 2
        let startY = (size.height - (CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing)) / 2
        
        var minValue = Int.max
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if let node = grid[row][col], let value = Int(node.text ?? "0"), value > 0 {
                    minValue = min(minValue, value)
                }
            }
        }
        if minValue == Int.max { minValue = 2 }
        
        let allowedValues: [Int] = [minValue, minValue * 2, minValue * 4, minValue * 8, minValue * 16, minValue * 32]
        
        for col in 0..<gridSize {
            var emptyRows: [Int] = []
            for row in (0..<gridSize).reversed() {
                if grid[row][col] == nil {
                    emptyRows.append(row)
                }
            }
            
            for (index, emptyRow) in emptyRows.enumerated() {
                let newValue = allowedValues.randomElement() ?? 2
                let node = NumberNode(value: newValue, row: emptyRow, col: col)
                let nodeColor = GameConfig.backgroundColors[newValue] ?? .gray
                
                let startPosition = CGPoint(
                    x: startX + CGFloat(col) * (cellSize + spacing) + cellSize / 2,
                    y: startY + CGFloat(gridSize + index) * (cellSize + spacing) + cellSize / 2
                )
                let targetPosition = CGPoint(
                    x: startX + CGFloat(col) * (cellSize + spacing) + cellSize / 2,
                    y: startY + CGFloat(emptyRow) * (cellSize + spacing) + cellSize / 2
                )
                
                node.position = startPosition
                node.setScale(0.0)
                addChild(node)
                
                let appear = SKAction.group([
                    SKAction.scale(to: 1.2, duration: GameConfig.newNodeAppearDuration),
                    SKAction.move(to: targetPosition, duration: GameConfig.newNodeMoveDuration)
                ])
                let bounce = SKAction.scale(to: 1.0, duration: 0.1)
                
                node.run(SKAction.sequence([appear, bounce])) {
                    self.grid[emptyRow][col] = node
                    self.createExplosion(at: targetPosition, color: nodeColor)
                }
            }
        }
    }
    
    func updateNodePositions() {
        let cellSize = GameConfig.cellSize
        let spacing = GameConfig.cellSpacing
        let startX = (size.width - (CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing)) / 2
        let startY = (size.height - (CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing)) / 2
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if let node = grid[row][col] {
                    node.position = CGPoint(
                        x: startX + CGFloat(col) * (cellSize + spacing) + cellSize / 2,
                        y: startY + CGFloat(row) * (cellSize + spacing) + cellSize / 2
                    )
                }
            }
        }
    }
    
    // Проверка на возможность хода
    func canMakeMove() -> Bool {
        var visited: Set<String> = Set()
        
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if let node = grid[row][col], !visited.contains("\(row),\(col)") {
                    let value = node.text ?? "0"
                    var group: [NumberNode] = [node]
                    var toVisit: [(Int, Int)] = [(row, col)]
                    visited.insert("\(row),\(col)")
                    
                    while !toVisit.isEmpty {
                        let (currentRow, currentCol) = toVisit.removeFirst()
                        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (-1, 1), (1, -1), (1, 1)]
                        
                        for (dx, dy) in directions {
                            let newRow = currentRow + dx
                            let newCol = currentCol + dy
                            let key = "\(newRow),\(newCol)"
                            if newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize,
                               !visited.contains(key),
                               let neighbor = grid[newRow][newCol],
                               neighbor.text == value {
                                group.append(neighbor)
                                toVisit.append((newRow, newCol))
                                visited.insert(key)
                            }
                        }
                    }
                    
                    if group.count >= 2 {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    // Конец игры
    func endGame() {
        saveBestScore()
        
        // Показываем всплывашку "Game Over"
        gameOverLabel?.removeFromParent()
        gameOverLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        gameOverLabel?.text = "Game Over"
        gameOverLabel?.fontSize = GameConfig.gameOverFontSize
        gameOverLabel?.fontColor = .black
        gameOverLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOverLabel?.zPosition = 20
        gameOverLabel?.alpha = 0.0
        addChild(gameOverLabel!)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut])
        gameOverLabel?.run(sequence) {
            // Очистка сцены
            self.children.forEach { $0.removeFromParent() }
            self.grid.removeAll()
            self.score = 0
            let scoreText = "$\(self.score)"
            let attributedString = NSMutableAttributedString(string: scoreText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 0, length: 1))
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 1, length: scoreText.count - 1))
            attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: GameConfig.scoreFontSize)!, range: NSRange(location: 0, length: scoreText.count))
            self.scoreLabel.attributedText = attributedString
            
            // Перезапуск игры
            self.setupGrid()
            self.setupScoreLabels()
        }
    }
}
