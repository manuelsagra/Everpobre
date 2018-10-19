//
//  NotebookListViewController.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 8/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit
import CoreData

class NotebookListViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    // MARK: - Properties
    var coreDataStack: CoreDataStack!
    private var fetchedResultsController: NSFetchedResultsController<Notebook>!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        reloadView()
    }
    
    // MARK: - Core Data
    private func getFetchedResultsController(with predicate: NSPredicate = NSPredicate(value: true)) -> NSFetchedResultsController<Notebook> {
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.predicate = predicate
        
        let sort = NSSortDescriptor(key: #keyPath(Notebook.name), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        fetchRequest.fetchBatchSize = 20
        
        return NSFetchedResultsController(fetchRequest: fetchRequest,
                                          managedObjectContext: coreDataStack.managedContext,
                                          sectionNameKeyPath: #keyPath(Notebook.creationDate),
                                          cacheName: nil)
    }
    
    private func setNewFetchResultsController(_ newfrc: NSFetchedResultsController<Notebook>) {
        let oldfrc = fetchedResultsController
        if (newfrc != oldfrc) {
            fetchedResultsController = newfrc
            newfrc.delegate = self
            do {
                try fetchedResultsController.performFetch()
                tableView.reloadData()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helper methods
    private func configureSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Buscar Notebook"
        
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
    
    private func showAll() {
        setNewFetchResultsController(getFetchedResultsController())
    }
    
    private func reloadView() {
        showAll()
        
        populateTotalLabel()
    }
    
    private func populateTotalLabel() {
        totalLabel.text = "\(fetchedResultsController.fetchedObjects?.count ?? 0)"
    }
    
    @IBAction func addNotebook(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Nuevo Notebook", message: "Nombre", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Grabar", style: .default) { [unowned self] action in
            guard
                let textField = alert.textFields?.first,
                let nameToSave = textField.text
                else { return }
            
            let notebook = Notebook(context: self.coreDataStack.managedContext)
            notebook.name = nameToSave
            notebook.creationDate = NSDate()
            
            do {
                try self.coreDataStack.managedContext.save()
            } catch let error as NSError {
                print("TODO Error handling \(error.localizedDescription)")
            }
            
            self.reloadView()
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - TableView
extension NotebookListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 1 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotebookListCell", for: indexPath) as! NotebookListCell
        let notebook = fetchedResultsController.object(at: indexPath)
        cell.configure(with: notebook)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        coreDataStack.managedContext.delete(fetchedResultsController.object(at: indexPath))
        
        do {
            try self.coreDataStack.managedContext.save()
        } catch let error as NSError {
            print("TODO Error handling \(error.localizedDescription)")
        }
        
        self.reloadView()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
}

extension NotebookListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notebook = fetchedResultsController.object(at: indexPath)
        let tabBarVC = NotesTabBarController(notebook: notebook, coreDataStack: coreDataStack)
        self.navigationController?.pushViewController(tabBarVC, animated: true)
    }
}

// MARK: - Search
extension NotebookListViewController:UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            showFilteredResults(with: text)
        } else {
            reloadView()
        }
    }
    
    private func showFilteredResults(with filter: String) {
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", filter)
        
        setNewFetchResultsController(getFetchedResultsController(with: predicate))
        
        populateTotalLabel()
    }
}

// MARK: - FetchedResultsControllerDelegate
extension NotebookListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
            
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
