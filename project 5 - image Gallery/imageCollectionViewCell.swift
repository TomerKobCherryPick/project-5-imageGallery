//
//  imageCollectionViewCell.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class imageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            if imageView.image == nil {
                indicator?.startAnimating()
            } else {
                indicator?.stopAnimating()
            }
        }
    }
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
}
