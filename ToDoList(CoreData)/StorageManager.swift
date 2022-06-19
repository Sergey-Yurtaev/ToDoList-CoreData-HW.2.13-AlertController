//
//  StorageManager.swift
//  ToDoList(CoreData)
//
//  Created by Sergey Yurtaev on 04.06.2022.
//

import CoreData
class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ToDoList_CoreData_")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}
    
    // MARK: - Public Methods
    func save(taskName newTask: String, completion: (Task) -> Void) {// что бы увидел Task, нужно перезагрузть Хcode
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return } // описание сущности. ссылка на модель Task
        guard let task = NSManagedObject(entity: entityDescription, insertInto: persistentContainer.viewContext) as? Task else { return } // на основании полученного описания сущности, создаем экземпляр модели
        task.name = newTask // передали свойство (оно еще не сохранилось)
        // Любой объект живет в конкретном контексте(контекстов может быть несколько). (создание, модификация, удаление и тд...) происходят в контексте и хранятся оперативной памяти, пока не явно не сохраним
        completion(task)
        saveContext() //сохраняем контекст на устройстве
    }
    
    func fetchData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()  // создаем объект запроса (запрос к базе)
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)   // берем данные по этому запросу и передаем в массив
        } catch let error {
            print("Failed to fetch data", error)
            return []
        }
    }
    
    func edit(_ task: Task, newName: String) {
        task.name = newName
        saveContext()
    }
    
    func deletle(_ task: Task) {
        persistentContainer.viewContext.delete(task)
        saveContext()
    }
    
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
    
    deinit {
        print("StorageManager has been dealocated")
    }
}
