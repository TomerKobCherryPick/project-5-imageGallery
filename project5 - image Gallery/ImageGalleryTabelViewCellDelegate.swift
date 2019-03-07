//
//  ImageGalleryTabelViewCellDelegate.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 03/03/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import Foundation
protocol ImageGalleryTabelViewCellDelegate: class {
    func changeName(for cell: ImageGalleryTableViewCell, formerName: String, newName:String)
}
