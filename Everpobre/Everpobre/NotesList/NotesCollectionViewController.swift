//
//  NotesCollectionViewController.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 11/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit
import CoreData

class NotesCollectionViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    let notebook: Notebook
    let coreDataStack: CoreDataStack
    var fetchedResultsController: NSFetchedResultsController<Note>
    
    let transition = Animator()

    // MARK: - Initialization
    init(notebook: Notebook, coreDataStack: CoreDataStack, fetchedResultsController: NSFetchedResultsController<Note>!) {
        self.notebook = notebook
        self.coreDataStack = coreDataStack
        self.fetchedResultsController = fetchedResultsController
        
        super.init(nibName: nil, bundle: nil)
        
        title = "Lista"
        tabBarItem.image = UIImage(named: "list")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()       
        
        let nib = UINib(nibName: "NotesCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "NotesCollectionViewCell")
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - CollectionView
extension NotesCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchedResultsController.fetchedObjects?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath) as! NotesCollectionViewCell
        
        cell.configure(with: fetchedResultsController.object(at: indexPath))
        return cell
    }
}

extension NotesCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        let noteView = NoteDetailsViewController(action: .edit(note), managedContext: coreDataStack.managedContext)
        noteView.delegate = tabBarController as! NotesTabBarController
        self.navigationController?.pushViewController(noteView, animated: true)
    }
}

extension NotesCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 180)
    }
}

// MARK: - Animation
extension NotesCollectionViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
}
