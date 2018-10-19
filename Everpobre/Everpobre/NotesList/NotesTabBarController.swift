//
//  NotesTabBarController.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 19/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit
import CoreData

class NotesTabBarController: UITabBarController {
    // MARK: - Properties
    let notebook: Notebook
    let coreDataStack: CoreDataStack
    var notes: [Note] = [] {
        didSet {
            noteListVC?.update(with: notes)
            mapVC?.update(with: notes)
        }
    }
    
    var noteListVC: NotesCollectionViewController?
    var mapVC: NotesMapViewController?
    
    // MARK: - Initialization
    init(notebook: Notebook, coreDataStack: CoreDataStack) {
        self.notebook = notebook
        self.coreDataStack = coreDataStack
        super.init(nibName: nil, bundle: nil)
        
        title = "Notas"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteListVC = NotesCollectionViewController(notebook: notebook, coreDataStack: coreDataStack)
        mapVC = NotesMapViewController(notebook: notebook, coreDataStack: coreDataStack)
        
        viewControllers = [
            noteListVC!,
            mapVC!
        ]
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        
        let exportButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportNotes))
        navigationItem.rightBarButtonItems = [addButtonItem, exportButtonItem]
    }
    
    // MARK: - Helper methods
    @objc private func addNote() {
        let newNoteVC = NoteDetailsViewController(action: .new(notebook), managedContext: coreDataStack.managedContext)
        let navVC = UINavigationController(rootViewController: newNoteVC)
        newNoteVC.delegate = self
        present(navVC, animated: true, completion: nil)
    }
    
    @objc private func exportNotes() {
        coreDataStack.storeContainer.performBackgroundTask { [unowned self] context in
            var results: [Note] = []
            do {
                results = try self.coreDataStack.managedContext.fetch(self.notesFetchRequest(from: self.notebook))
                
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
            
            let exportPath = NSTemporaryDirectory() + "export.csv"
            let exportURL = URL(fileURLWithPath: exportPath)
            FileManager.default.createFile(atPath: exportPath, contents: Data(), attributes: nil)
            
            let fileHandle: FileHandle?
            do {
                fileHandle = try FileHandle(forWritingTo: exportURL)
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
                fileHandle = nil
            }
            
            if let fileHandle = fileHandle {
                for note in results {
                    fileHandle.seekToEndOfFile()
                    guard let csv = note.csv().data(using: .utf8, allowLossyConversion: false) else { break }
                    fileHandle.write(csv)
                    fileHandle.write("\n".data(using: .utf8)!)
                }
                
                fileHandle.closeFile()
                
                DispatchQueue.main.async {
                    let message = "Las notas se han exportado en \(exportPath)"
                    let alertController = UIAlertController(
                        title: "Exportación",
                        message: message,
                        preferredStyle: .alert
                    )
                    let dismissAction = UIAlertAction(title: "Aceptar", style: .default)
                    alertController.addAction(dismissAction)
                    
                    self.present(alertController, animated: true)
                }
            } else {
                print("Error al exportar")
            }
        }
    }
    
    // Unneeded really, just for demostration purproses
    private func notesFetchRequest(from notebook: Notebook) -> NSFetchRequest<Note> {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.fetchBatchSize = 50
        fetchRequest.predicate = NSPredicate(format: "notebook == %@", notebook)
        fetchRequest.sortDescriptors = [NSSortDescriptor(
            key: "creationDate",
            ascending: true
            )]
        
        return fetchRequest
    }
}

// MARK: - NoteDetailsViewControllerDelegate
extension NotesTabBarController: NoteDetailsViewControllerDelegate {
    func didChangeNote() {
        self.notes = (notebook.notes?.array as? [Note]) ?? []
    }
}
