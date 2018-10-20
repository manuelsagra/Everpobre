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
    var fetchedResultsController: NSFetchedResultsController<Note>!
    
    var notesListVC: NotesCollectionViewController?
    var notesMapVC: NotesMapViewController?
    
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
    
    // MARK: - Core Data
    func getFetchedResultsController(with predicate: NSPredicate) -> NSFetchedResultsController<Note> {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        fetchRequest.predicate = predicate
        
        let sort = NSSortDescriptor(key: #keyPath(Note.title), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        fetchRequest.fetchBatchSize = 20
        
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: coreDataStack.managedContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }
    
    func setNewFetchResultsController(_ newfrc: NSFetchedResultsController<Note>) {
        let oldfrc = fetchedResultsController
        if (newfrc != oldfrc) {
            fetchedResultsController = newfrc
            do {
                try fetchedResultsController.performFetch()
                
                // List
                notesListVC?.fetchedResultsController = newfrc
                if let collectionView = notesListVC?.collectionView {
                    collectionView.reloadData()
                }
                
                // Map
                notesMapVC?.fetchedResultsController = newfrc
                notesMapVC?.updateAnnotations()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAll()
        
        notesListVC = NotesCollectionViewController(notebook: notebook, coreDataStack: coreDataStack, fetchedResultsController: fetchedResultsController)
        notesMapVC = NotesMapViewController(notebook: notebook, coreDataStack: coreDataStack, fetchedResultsController: fetchedResultsController)
        
        viewControllers = [
            notesListVC!,
            notesMapVC!
        ]
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        
        let exportButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportNotes))
        navigationItem.rightBarButtonItems = [addButtonItem, exportButtonItem]
        
        configureSearchController()
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
            results = try self.coreDataStack.managedContext.fetch(getFetchedResultsController(with: NSPredicate(format: "notebook == %@", notebook)).fetchRequest)
            
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
    
    private func configureSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Buscar nota"
        
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func showAll() {
        setNewFetchResultsController(getFetchedResultsController(with: NSPredicate(format: "notebook == %@", notebook)))
    }
}

// MARK: - NoteDetailsViewControllerDelegate
extension NotesTabBarController: NoteDetailsViewControllerDelegate {
    func didChangeNote() {
        showAll()
    }
}

// MARK: - Search
extension NotesTabBarController:UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            showFilteredResults(with: text)
        } else {
            showAll()
        }
    }
    
    private func showFilteredResults(with filter: String) {
        // Tag lookup (Naive and slow)
        var tag: Int16 = -1
        let possibleTags = filter.split(separator: " ")
        for possibleTag in possibleTags {
            for enumTag in Tag.allCases {
                if (String(possibleTag) == enumTag.description) {
                    tag = enumTag.rawValue
                }
            }
        }
        
        let predicate = NSPredicate(format: "notebook == %@ AND (title CONTAINS[c] %@ OR tag == %i)", notebook, filter, tag)
        
        setNewFetchResultsController(getFetchedResultsController(with: predicate))
    }
}
