//
//  GameScene.swift
//  Number x2 Match Game
//
//  Created by Lev Vlasov on 2025-04-03.
//


import SpriteKit

struct GameConfig {
    // Сетка
    static let gridSize: Int = 5

    // Размеры и отступы
    static let cellSize: CGFloat = 60
    static let cellSpacing: CGFloat = 10
    static let cellCornerRadius: CGFloat = 8

    // Шрифты
    static let fontSize: CGFloat = 24
    static let fontSizeLarge: CGFloat = 20

    // Цвета
    static let defaultFontColor: UIColor = .white
    static let backgroundColors: [Int: UIColor] = [
        2: .red,
        4: .green,
        8: .purple,
        16: .orange,
        32: .yellow,
        64: .systemPink,
        128: .systemTeal
    ]

    // Анимации
    static let newNodeAppearDuration: TimeInterval = 0.1
    static let newNodeMoveDuration: TimeInterval = 0.2
    static let dropMoveDuration: TimeInterval = 0.2
    static let mergeScaleDuration: TimeInterval = 0.1
    static let mergeMoveDuration: TimeInterval = 0.1

    // Линии
    static let connectingLineWidth: CGFloat = 8
    static let connectingLineColor: UIColor = .white
}


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

        // Настройка размера шрифта
        self.fontSize = validValue >= 1000 ? GameConfig.fontSizeLarge : GameConfig.fontSize

        // Фон
        background = SKShapeNode(rectOf: CGSize(width: GameConfig.cellSize, height: GameConfig.cellSize),
                                 cornerRadius: GameConfig.cellCornerRadius)
        updateBackgroundColor(value: validValue)
        background.strokeColor = .clear
        background.zPosition = -1
        self.addChild(background)

        // Физика
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
    
    // MARK: - Touch Handling
    
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
    
    // MARK: - Line Drawing
    
    func updateConnectingLine() {
        removeConnectingLine()
        
        if selectedNodes.isEmpty { return }
        
        let path = CGMutablePath()
        let firstNode = selectedNodes.first!
        path.move(to: firstNode.position)
        
        for i in 1..<selectedNodes.count {
            path.addLine(to: selectedNodes[i].position)
        }
        
        if let touchLocation = currentTouchLocation, selectedNodes.count > 0 {
            path.addLine(to: touchLocation)
        }
        
        let line = SKShapeNode(path: path)
        line.strokeColor = GameConfig.connectingLineColor
        line.lineWidth = GameConfig.connectingLineWidth
        line.zPosition = 1
        addChild(line)
        connectingLine = line
    }
    
    func removeConnectingLine() {
        connectingLine?.removeFromParent()
        connectingLine = nil
    }
    
    // MARK: - Merging Logic
    
    func mergeSelectedNodes() {
        guard let firstNode = selectedNodes.first,
              let value = Int(firstNode.text ?? "") else { return }

        if isProcessingMerge { return }  // Предотвращаем дублирование
        isProcessingMerge = true

        let allSameValue = selectedNodes.allSatisfy { $0.text == firstNode.text }
        if !allSameValue { return }

        let newValue = value * 2
        firstNode.updateValue(newValue)

        let mergeAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: GameConfig.mergeScaleDuration),
            SKAction.scale(to: 0.0, duration: GameConfig.mergeScaleDuration),
            SKAction.removeFromParent()
        ])

        for (index, node) in selectedNodes.dropFirst().enumerated() {
            if index == 0 {
                let moveAction = SKAction.move(to: firstNode.position, duration: GameConfig.mergeMoveDuration)
                let scaleAndRemove = SKAction.sequence([
                    moveAction,
                    SKAction.scale(to: 1.2, duration: 0.1),
                    SKAction.scale(to: 0.0, duration: 0.1),
                    SKAction.removeFromParent()
                ])
                node.run(scaleAndRemove)
            } else {
                node.run(mergeAction)
            }
            grid[node.row][node.col] = nil
        }

        grid[firstNode.row][firstNode.col] = firstNode

        dropNodes() // сразу запускаем падение и появление новых

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
    
    func getNeighbors(row: Int, col: Int) -> [NumberNode] {
        var neighbors: [NumberNode] = []
        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        
        for (dx, dy) in directions {
            let newRow = row + dx
            let newCol = col + dy
            if newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize {
                if let node = grid[newRow][newCol] {
                    neighbors.append(node)
                }
            }
        }
        return neighbors
    }
    
    // New function to count the number of possible connections on the field
    func countConnections() -> Int {
        var connectionCount = 0
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
                        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
                        
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
                        connectionCount += 1
                    }
                }
            }
        }
        return connectionCount
    }
    
    func addNewNodesWithAnimation() {
        let cellSize = GameConfig.cellSize
        let spacing = GameConfig.cellSpacing
        let startX = (size.width - (CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing)) / 2
        let startY = (size.height - (CGFloat(gridSize) * cellSize + CGFloat(gridSize - 1) * spacing)) / 2
        
        // Находим минимальное значение на поле
        var minValue = Int.max
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if let node = grid[row][col], let value = Int(node.text ?? "0"), value > 0 {
                    minValue = min(minValue, value)
                }
            }
        }
        if minValue == Int.max { minValue = 2 }
        
        // Формируем массив разрешённых значений: от minValue до 5 удвоений (всего 6 чисел)
        let allowedValues: [Int] = [minValue, minValue * 2, minValue * 4, minValue * 8, minValue * 16, minValue * 32]
        
        // Добавляем новые узлы в пустые места
        for col in 0..<gridSize {
            var emptyRows: [Int] = []
            for row in (0..<gridSize).reversed() {
                if grid[row][col] == nil {
                    emptyRows.append(row)
                }
            }
            
            for (index, emptyRow) in emptyRows.enumerated() {
                // Выбираем новое значение из разрешённого диапазона
                let newValue = allowedValues.randomElement() ?? 2
                
                let node = NumberNode(value: newValue, row: emptyRow, col: col)
                
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
                
                let moveAction = SKAction.move(to: targetPosition, duration: GameConfig.newNodeMoveDuration)
                let appearAction = SKAction.scale(to: 1.0, duration: GameConfig.newNodeAppearDuration)
                
                let sequence = SKAction.sequence([
                    appearAction,
                    moveAction
                ])
                
                node.run(sequence) {
                    self.grid[emptyRow][col] = node
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


