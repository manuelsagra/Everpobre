//
//  NoteListViewController.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 8/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit
import CoreData

class NoteListViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let notebook: Notebook
    let managedContext: NSManagedObjectContext

    var notes: [Note] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(notebook: Notebook, managedContext: NSManagedObjectContext) {
        self.notebook = notebook
        self.notes = (notebook.notes?.array as? [Note]) ?? []
        self.managedContext = managedContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notas"
        
        let addBUttonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        navigationItem.rightBarButtonItem = addBUttonItem
        
        setupTableView()
    }
    
    @objc private func addNote() {
        let newNoteVC = NoteDetailsViewController(action: .new(notebook), managedContext: managedContext)
        let navVC = UINavigationController(rootViewController: newNoteVC)
        newNoteVC.delegate = self
        present(navVC, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

extension NoteListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "NoteCell")
        
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        
        return cell
    }
}

extension NoteListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        let view = NoteDetailsViewController(action: .edit(note), managedContext: managedContext)
        view.delegate = self
        self.navigationController?.pushViewController(view, animated: true)
    }
}

extension NoteListViewController: NoteDetailsViewControllerDelegate {
    func didChangeNote() {
        self.notes = (notebook.notes?.array as? [Note]) ?? []
    }
}
