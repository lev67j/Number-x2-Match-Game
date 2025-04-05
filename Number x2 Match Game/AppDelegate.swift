//
//  AppDelegate.swift
//  Number x2 Match Game
//
//  Created by Lev Vlasov on 2025-04-03.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Создаем окно
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Создаем GameViewController
        let gameViewController = GameViewController()
        
        // Передаем контекст Core Data
        gameViewController.managedObjectContext = persistentContainer.viewContext
        
        // Устанавливаем корневой контроллер
        window?.rootViewController = gameViewController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GameModel") // Укажите имя вашей модели
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
