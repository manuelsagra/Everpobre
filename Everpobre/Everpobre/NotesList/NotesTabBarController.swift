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
        var results: [Note] = []
        do {
            results = try self.coreDataStack.managedContext.fetch(self.notesFetchRequest(from: self.notebook))
            
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        
        var csv = ""
        for note in results {
            csv = "\(csv)\(note.csv())\n"
        }
        
        let activityView = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
        self.present(activityView, animated: true)
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
