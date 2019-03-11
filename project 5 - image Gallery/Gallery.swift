//
//  Gallery.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 10/03/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import Foundation

struct Gallery: Codable {
    var imagesUrl: [URL]
    var name: String
    
    
    init(imagesUrl: [URL], name: String) {
        self.imagesUrl = imagesUrl
        self.name = name
    }
    
}
