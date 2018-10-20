//
//  NoteDetailsViewController.swift
//  Everpobre
//
//  Created by Manuel Sagra de Diego on 9/10/18.
//  Copyright © 2018 Ibermutuamur. All rights reserved.
//

import UIKit
import CoreData
import MapKit

protocol NoteDetailsViewControllerDelegate: class {
    func didChangeNote()
}

class NoteDetailsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var creationDateLabel: UILabel!
    @IBOutlet weak var lastSeenDateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tagTextField: UITextField!
    
    // MARK: - Properties
    enum Action {
        case new(Notebook)
        case edit(Note)
    }
    
    let managedContext: NSManagedObjectContext
    let action: Action
    
    var coordinate: CLLocationCoordinate2D?
    var tagId: Int16?
    weak var delegate: NoteDetailsViewControllerDelegate?
    
    // MARK: - Initialization
    init(action: Action, managedContext: NSManagedObjectContext) {
        self.action = action
        self.managedContext = managedContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tagPicker = UIPickerView()
        tagTextField.inputView = tagPicker
        tagPicker.dataSource = self
        tagPicker.delegate = self
        
        configure()
    }
    
    // MARK: - Helper Methods
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
        if let tag = action.note?.tag, tag != 0 {
            tagTextField.text = Tag(rawValue: tag)?.description
        }
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
            if let tag = tagId {
                note.tag = tag
            }
            
            if let image = imageView.image, let data = image.pngData() {
                note.image = NSData(data: data)
            }
            
            if let coordinate = coordinate {
                if let location = note.location {
                    location.longitude = coordinate.longitude
                    location.latitude = coordinate.latitude
                } else {
                    note.location = Location(context: managedContext)
                    note.location?.longitude = coordinate.longitude
                    note.location?.latitude = coordinate.latitude
                }
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
    
    // MARK: - Image picking
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
    
    // MARK: - Maps
    @IBAction func openMap(_ sender: Any) {
        var location: Location?
        switch(action) {
        case .edit(let note):
            location = note.location
            
        case .new:
            location = nil
        }
        let mapViewController = NoteMapViewController(location: location)
        mapViewController.delegate = self
        
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    // MARK: - Tags
    @IBAction func tagClick(_ sender: Any) {
        print("TAG")
    }
}

// MARK: - Custom Action
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

// MARK: - Image Resizing
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

// MARK: - Location change
extension NoteDetailsViewController: NoteMapViewControllerDelegate {
    func didChangeLocation(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

// MARK: - Tag Picker
extension NoteDetailsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Tag.allCases.count
    }    
}

extension NoteDetailsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Tag.allCases[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tagTextField.text = Tag.allCases[row].description
        tagId = Tag.allCases[row].rawValue
    }
}
