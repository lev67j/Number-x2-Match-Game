//
//  GameViewController.swift
//  Number x2 Match Game
//
//  Created by Lev Vlasov on 2025-04-03.
//

import UIKit
import SpriteKit
import CoreData


import UIKit
import SpriteKit
import CoreData

class GameViewController: UIViewController {
    var managedObjectContext: NSManagedObjectContext!
    
    override func loadView() {
        // Создаем SKView вручную
        self.view = SKView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Теперь self.view точно SKView
        if let view = self.view as? SKView {
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            scene.managedObjectContext = managedObjectContext
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    // Отключаем автоповорот, если нужно
    override var shouldAutorotate: Bool {
        return false
    }
    
    // Указываем поддерживаемые ориентации
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // Скрываем статус-бар
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
