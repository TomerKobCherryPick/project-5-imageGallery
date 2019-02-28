//
//  galleryViewControllerDelegate.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 28/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import Foundation
protocol galleryViewControllerDelegate: class {
    func addUrl(url: URL, galleryName: String)
}
