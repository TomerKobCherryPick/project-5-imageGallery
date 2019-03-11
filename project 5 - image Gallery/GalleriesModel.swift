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
    init() {
        // if couldn't load from disk,
        // we set the data with some sample data,
        // so the app won't start without galleries
        if (!loadModelFromDisk()) {
            myGalleries = [
                Gallery(imagesUrl:
                    [URL(string: "https://i.dietdoctor.com/wp-content/uploads/2018/07/starchyfoods.jpg?auto=compress%2Cformat&w=800&h=388&fit=crop")!,
                     URL(string: "https://www.hindustantimes.com/rf/image_size_960x540/HT/p2/2018/05/28/Pictures/_c618b53a-6262-11e8-a998-12ee0acfa260.jpg")!,
                     URL(string: "https://sweetsimplevegan.com/wp-content/uploads/2018/05/Homemade_Pita_Bread_Sweet_Simple_Vegan-copy.jpg")!,
                     URL(string: "https://www.tasteofhome.com/wp-content/uploads/2018/01/exps32480_MRR153791D09_18_6b-2.jpg")!,
                     URL(string: "https://5.imimg.com/data5/TB/IF/MY-41399105/potato-500x500.jpg")!,
                     URL(string: "https://d3awvtnmmsvyot.cloudfront.net/api/file/6fTZjAw9Tjqf4XrddmRQ")!], name: "carbs"),
                Gallery(imagesUrl: [URL(string: "https://images.reverb.com/image/upload/s--dfW9xmtS--/a_exif,c_limit,e_unsharp_mask:80,f_auto,fl_progressive,g_south,h_620,q_90,w_620/v1489275409/sicf27nru9awzyaxucig.jpg")!,
                                    URL(string: "https://i.ytimg.com/vi/SRsciUOWkOc/maxresdefault.jpg")!], name: "guitars")
            ]
            myDeletedGalleries = [Gallery]()
            
        }
    }
    
    init(galleries: [Gallery], deletedGalleries:  [Gallery]) {
        myGalleries = galleries
        myDeletedGalleries = deletedGalleries
    }
    
    func saveModel() -> Bool {
        if let json = json {
            if let urlToWrite = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("imageGallery.json") {
                do {
                    try json.write(to: urlToWrite)
                    #if DEBUG
                    if let jsonString = String(data: json, encoding: .utf8) {
                        print("saved json: \(jsonString)")
                    }
                    #endif
                    return true
                } catch let error {
                    #if DEBUG
                    print("couldn't save: \(error)")
                    #endif
                }
            }
        }
        return false
    }
    
    mutating func loadModelFromDisk() -> Bool {
        if let urlToLoad = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("imageGallery.json") {
            if let jsonData = try? Data(contentsOf: urlToLoad) {
                #if DEBUG
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("loaded json: \(jsonString)")
                }
                #endif
                if let galleryToLoad =  GalleriesModel(json: jsonData) {
                    self = galleryToLoad
                    return true
                }
            }
        }
        return false
    }
    
    
    
    
}
