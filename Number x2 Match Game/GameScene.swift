//
//  GameScene.swift
//  Number x2 Match Game
//
//  Created by Lev Vlasov on 2025-04-03.
//


import SpriteKit

struct GameConfig {
    static let gridSize: Int = 5
    static let cellSize: CGFloat = 60
    static let cellSpacing: CGFloat = 10
    static let cellCornerRadius: CGFloat = 8
    static let fontSize: CGFloat = 24
    static let fontSizeLarge: CGFloat = 20
    static let defaultFontColor: UIColor = .white
    
    // Яркие неоновые цвета
    static let backgroundColors: [Int: UIColor] = [
        2: UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0),    // Ярко-красный
        4: UIColor(red: 0.2, green: 1.0, blue: 0.2, alpha: 1.0),    // Ярко-зеленый
        8: UIColor(red: 0.8, green: 0.2, blue: 1.0, alpha: 1.0),    // Неоново-фиолетовый
        16: UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0),   // Ярко-оранжевый
        32: UIColor(red: 1.0, green: 1.0, blue: 0.2, alpha: 1.0),   // Неоново-желтый
        64: UIColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0),   // Ярко-розовый
        128: UIColor(red: 0.2, green: 1.0, blue: 0.8, alpha: 1.0)   // Неоново-бирюзовый
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
}

// Класс для узлов остался без изменений
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
        self.fontName = "Helvetica-Bold"
        self.fontColor = GameConfig.defaultFontColor
        self.horizontalAlignmentMode = .center
        self.verticalAlignmentMode = .center
        self.name = "number"
        self.fontSize = validValue >= 1000 ? GameConfig.fontSizeLarge : GameConfig.fontSize

        background = SKShapeNode(rectOf: CGSize(width: GameConfig.cellSize, height: GameConfig.cellSize),
                                cornerRadius: GameConfig.cellCornerRadius)
        updateBackgroundColor(value: validValue)
        background.strokeColor = .clear
        background.zPosition = -1
        self.addChild(background)

        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: GameConfig.cellSize, height: GameConfig.cellSize))
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

class GameScene: SKScene {
    let gridSize = GameConfig.gridSize
    var grid: [[NumberNode?]] = []
    var selectedNodes: [NumberNode] = []
    var connectingLine: SKShapeNode?
    var currentTouchLocation: CGPoint?
    var isAnimating = false
    var isProcessingMerge = false
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = .black // Темный фон для контраста
        setupGrid()
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
        emitter.particleScale = 0.2
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
    }

    func nodeAtPoint(_ point: CGPoint) -> NumberNode? {
        let nodes = self.nodes(at: point)
        for node in nodes {
            if let numberNode = node as? NumberNode {
                let nodeFrame = CGRect(
                    x: numberNode.position.x - 25,
                    y: numberNode.position.y - 25,
                    width: 50,
                    height: 50
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
    
    // Слияние с эффектами
    func mergeSelectedNodes() {
        guard let firstNode = selectedNodes.first,
              let value = Int(firstNode.text ?? "") else { return }
              
        if isProcessingMerge { return }
        isProcessingMerge = true

        let allSameValue = selectedNodes.allSatisfy { $0.text == firstNode.text }
        if !allSameValue { return }

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

        for node in selectedNodes.dropFirst() {
            let nodeColor = GameConfig.backgroundColors[value] ?? .gray
            let explodeAction = SKAction.group([
                SKAction.scale(to: 1.5, duration: 0.15),
                SKAction.fadeOut(withDuration: 0.15)
            ])
            
            node.run(explodeAction) {
                for _ in 0..<GameConfig.particleCount/2 {
                    let fragment = SKSpriteNode(color: nodeColor, size: CGSize(width: 5, height: 5))
                    fragment.position = node.position
                    self.addChild(fragment)
                    
                    let angle = CGFloat.random(in: 0...(2 * .pi))
                    let distance = CGFloat.random(in: 50...100)
                    let destination = CGPoint(
                        x: node.position.x + cos(angle) * distance,
                        y: node.position.y + sin(angle) * distance
                    )
                    
                    self.createParticleTrail(from: node.position, color: nodeColor)
                    let move = SKAction.move(to: destination, duration: 0.3)
                    let fade = SKAction.fadeOut(withDuration: 0.3)
                    fragment.run(SKAction.group([move, fade])) {
                        fragment.removeFromParent()
                    }
                }
                node.removeFromParent()
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
}
