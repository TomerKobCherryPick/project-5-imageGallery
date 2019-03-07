//
//  GalleriesModel.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 07/03/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import Foundation

struct GalleriesModel: Codable {
    var myGalleries: [Gallery]?
    var myDeletedGalleries:  [Gallery]?
    
    init(galleries: [Gallery], deletedGalleries:  [Gallery]) {
        myGalleries = galleries
        myDeletedGalleries = deletedGalleries
    }
    
    struct Gallery: Codable {
        var imagesUrlWithSize: [urlWithSize]
        var name: String
        
        struct urlWithSize: Codable {
            var url: URL
            var height: Double?
            var width: Double?
        }
        
        init(imagesUrl: [urlWithSize], name: String) {
            self.imagesUrlWithSize = imagesUrl
            self.name = name
        }
        
        init(imagesUrl: [URL], name: String) {
           self.imagesUrlWithSize = imagesUrl.map {
               urlWithSize(url: $0, height: nil, width: nil)
            }
            self.name = name
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
   
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(GalleriesModel.self, from: json){
            self = newValue
        } else {
            return nil
        }
    }
    
}
