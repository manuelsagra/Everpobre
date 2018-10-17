//
//  NoteDetailsViewController.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 9/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit
import CoreData

protocol NoteDetailsViewControllerDelegate: class {
    func didChangeNote()
}

class NoteDetailsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var lastSeenDateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    enum Action {
        case new(Notebook)
        case edit(Note)
    }
    
    let managedContext: NSManagedObjectContext
    let action: Action
    
    weak var delegate: NoteDetailsViewControllerDelegate?
    
    init(action: Action, managedContext: NSManagedObjectContext) {
        self.action = action
        self.managedContext = managedContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        switch action {
        case .new:
            let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
            self.navigationItem.rightBarButtonItem = saveButtonItem
            
            let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSaveNote))
            self.navigationItem.leftBarButtonItem = cancelButtonItem
            configureValues()
            
        case .edit:
            let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
            self.navigationItem.rightBarButtonItem = saveButtonItem
            
            configureValues()
        }
        
    }
    
    private func configureValues() {
        title = action.title
        
        titleTextField.text = action.note?.title
        //tagsLabel.text = note.tags?.joined(separator: ", ")
        creationDateLabel.text = (action.note?.creationDate as Date?)?.toLocaleString() ?? "---"
        lastSeenDateLabel.text = (action.note?.lastSeenDate as Date?)?.toLocaleString() ?? "---"
        textView.text = action.note?.text ?? "Introduzca texto"
        if let imageData = action.note?.image, imageData.length > 0 {
            imageView.image = UIImage(data: imageData as Data)
        }
    }

    @objc private func saveNote() {
        func addProperties(to note: Note) {
            note.title = titleTextField.text
            note.text = textView.text
            
            if let image = imageView.image, let data = image.pngData() {
                note.image = NSData(data: data)
            }
        }
        
        switch action {
        case .edit(let note):
            note.lastSeenDate = NSDate()
            addProperties(to: note)
            
            do {
                try managedContext.save()
                delegate?.didChangeNote()
            } catch let error as NSError {
                print("TODO Error handling \(error.localizedDescription)")
            }
            
            navigationController?.popViewController(animated: true)

        case .new(let notebook):
            let note = Note(context: managedContext)
            addProperties(to: note)
            note.creationDate = NSDate()
            note.notebook = notebook
            
            if let notes = notebook.notes?.mutableCopy() as? NSMutableOrderedSet {
                notes.add(note)
                notebook.notes = notes
            }
            
            do {
                try managedContext.save()
                delegate?.didChangeNote()
            } catch let error as NSError {
                print("TODO Error handling \(error.localizedDescription)")
            }
            
            dismiss(animated: true, completion: nil)
        }      
        
    }
    
    @objc private func cancelSaveNote() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickImage(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    private func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "Hacer foto", style: .default, handler: { _ in self.takePhotoWithCamera() })
        let chooseFromLibrary = UIAlertAction(title: "Escoger de biblioteca", style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibrary)

        present(alertController, animated: true, completion: nil)
    }
    
    private func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
}

private extension NoteDetailsViewController.Action {
    var note: Note? {
        guard case let .edit(note) = self else { return nil }
        return note
    }
    
    var title: String {
        switch self {
        case .edit:
            return "Nota"
            
        case .new:
            return "Nueva nota"
        }
    }
}

extension NoteDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        let rawImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        let imageResizeTo = CGSize(width: self.imageView.bounds.width * UIScreen.main.scale, height: self.imageView.bounds.height * UIScreen.main.scale)
        
        DispatchQueue.global(qos: .default).async {
            let image = rawImage?.resizedImageWithContentMode(.scaleAspectFill, bounds: imageResizeTo, interpolationQuality: .high)
            
            DispatchQueue.main.async {
                if let image = image {
                    self.imageView.image = image
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
}
