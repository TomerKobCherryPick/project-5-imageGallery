//
//  imageCollectionViewCell.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    var isSelectedToBeDeleted = false {
        didSet {
            DispatchQueue.main.async {
                self.imageView.alpha =  self.isSelectedToBeDeleted == true ? 0.4 : 1
            }
        }
    }
    weak var delegate: ImageCollectionViewCellDelegate?
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var indexOfUrl: Int?
    var url: URL?
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            if gestureRecognizers == nil || gestureRecognizers?.count == 0 {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteImage))
            self.addGestureRecognizer(gesture)
            }
        }
    }
    
    @objc func deleteImage(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .ended {
            delegate?.selectImageToDelete(index: indexOfUrl!)
        }
    }
    
   
}
