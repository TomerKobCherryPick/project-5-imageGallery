//
//  ImageGalleryTableViewCell.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 03/03/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class ImageGalleryTableViewCell: UITableViewCell, UITextFieldDelegate {
    private var formerName: String?
    weak var delegate: ImageGalleryTabelViewCellDelegate?
    private var allowedToEditName = false {
        didSet {
            if allowedToEditName == true {
                nameOfGalleryText.becomeFirstResponder()
            } else {
                nameOfGalleryText.resignFirstResponder()
            }
        }
    }
    @IBOutlet weak var nameOfGalleryText: UITextField! {
        didSet {
            nameOfGalleryText.adjustsFontSizeToFitWidth = true
            nameOfGalleryText.delegate = self
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToEdit))
            tapGestureRecognizer.numberOfTapsRequired = 2
            nameOfGalleryText.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @objc private func tapToEdit (_ recognizer: UITapGestureRecognizer) {
        if allowedToEditName == false {
            allowedToEditName = true
            formerName = nameOfGalleryText.text
        } else {
            allowedToEditName = false
        }
    }
    
    @IBAction private func textFieldEditingChanged(_ sender: UITextField) {
        if formerName != nil {
            delegate?.changeName(formerName: formerName!, newName: nameOfGalleryText.text!)
        }
    }
     func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return allowedToEditName == true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

