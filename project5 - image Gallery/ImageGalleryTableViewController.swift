//
//  imageGalleryTableTableViewController.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    // datasource with some sample data,
    // so the app won't start without galleries
    @IBOutlet var galleriesTableView: UITableView!
    var tableOfGalleriesModel: TableOfGalleriesModel? {
        get {
            let myGalleries = indexToGalleryName
            let myDeletedGalleries = indexToDeletedGalleryName
            return TableOfGalleriesModel(galleries: myGalleries, recentlyDeleted: myDeletedGalleries)
        }
        set(newModel){
            if newModel != nil {
                galleriesNames  = newModel!.myGalleries.reduce(into: [:]){$0[$1.value] = true}
                let deletedGalleriesWithDirUrl = newModel!.myGalleries.reduce(into: [:]){$0[$1.value] = true}
                for pair in deletedGalleriesWithDirUrl {
                    galleriesNames[pair.key] = pair.value
                }
                indexToGalleryName = newModel!.myGalleries
                indexToDeletedGalleryName = newModel!.recentlyDeletedGalleries
                
            }
        }
    }
    var indexToDeletedGalleryName = [Int: String]()
    var indexToGalleryName = [Int: String]()
    var galleriesNames = [String: Bool]()
    /*
     var galleries = ["carbs", "guitars", "gallery1","carbs2"]*/
    // var recentlyDeleted = ["gallery2"]
    /* var galleryToUrlMap = [
     "carbs" : [URL(string: "https://i.dietdoctor.com/wp-content/uploads/2018/07/starchyfoods.jpg?auto=compress%2Cformat&w=800&h=388&fit=crop")!,
     URL(string: "https://www.hindustantimes.com/rf/image_size_960x540/HT/p2/2018/05/28/Pictures/_c618b53a-6262-11e8-a998-12ee0acfa260.jpg")!,
     URL(string: "https://sweetsimplevegan.com/wp-content/uploads/2018/05/Homemade_Pita_Bread_Sweet_Simple_Vegan-copy.jpg")!,
     URL(string: "https://www.tasteofhome.com/wp-content/uploads/2018/01/exps32480_MRR153791D09_18_6b-2.jpg")!,
     URL(string: "https://5.imimg.com/data5/TB/IF/MY-41399105/potato-500x500.jpg")!,
     URL(string: "https://d3awvtnmmsvyot.cloudfront.net/api/file/6fTZjAw9Tjqf4XrddmRQ")!]
     
     , "guitars" : [URL(string: "https://images.reverb.com/image/upload/s--dfW9xmtS--/a_exif,c_limit,e_unsharp_mask:80,f_auto,fl_progressive,g_south,h_620,q_90,w_620/v1489275409/sicf27nru9awzyaxucig.jpg")!,
     URL(string: "https://i.ytimg.com/vi/SRsciUOWkOc/maxresdefault.jpg")!]
     ]*/
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? indexToGalleryName.count : indexToDeletedGalleryName.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        // a gallery cell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "galleriesCell", for: indexPath)
            (cell as! ImageGalleryTableViewCell).nameOfGalleryText.text = indexToGalleryName[indexPath.row]
            (cell as! ImageGalleryTableViewCell).delegate = self
        }
            // a deleted gallery cell
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "deletedGalleriesCell", for: indexPath)
            cell.textLabel?.text = indexToDeletedGalleryName[indexPath.row]
        }
        return cell
    }
    
    
    @IBAction func touchAddGallery(_ sender: UIBarButtonItem) {
        let nameOfGalleryToAdd = "untitled".madeUnique(withRespectTo: galleriesNames.map{$0.key})
        //Mark - make an actual new Gallery
        let newGallery = Gallery(imagesUrl: [Gallery.urlWithSize](), settings: Gallery.galleryInfo(index: 0,name: nameOfGalleryToAdd))
        let isSaveSucseeded = saveGallery(gallery: newGallery)
        if isSaveSucseeded {
            tableView.insertRows(at: [IndexPath(row: indexToGalleryName.count - 1, section: 0)], with: .fade)
            galleriesNames[nameOfGalleryToAdd] = true
        }
        
    }
    func saveGallery(gallery: Gallery) -> Bool{
        if let json = gallery.json {
            #if DEBUG
            if let jsonString = String(data: json, encoding: .utf8) {
                print("saved json: \(jsonString)")
            }
            #endif
            if let urlToWrite = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(gallery.settings.name + ".json") {
                do {
                    try json.write(to: urlToWrite)
                    indexToGalleryName[indexToGalleryName.count] = gallery.settings.name
                    galleriesNames[gallery.settings.name] = true
                    print("addeded successfully!")
                    return true
                } catch let error {
                    print("couldn't save: \(error)")
                }
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // return header only for the Recently Deleted section
        if section == 1 {
            return "Recently Deleted"
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showGallery":
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell), let gallery = (segue.destination as? ImageGalleryCollectionViewController) {
                    if let nameOfGalleryToOpen = indexToGalleryName[indexPath.row] {
                       gallery.galleryModel = loadGallery(nameOfGalleryToLoad: nameOfGalleryToOpen)
                    }
                }
            default: break
            }
        }
    }
    
    func loadGallery(nameOfGalleryToLoad: String) -> Gallery? {
        if let urlToLoad = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(nameOfGalleryToLoad + ".json") {
            if let jsonData = try? Data(contentsOf: urlToLoad) {
                #if DEBUG
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("loaded json: \(jsonString)")
                }
                #endif
                return Gallery(json: jsonData)
            }
        }
        return nil
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //if we are deleting from the regular section,
            // we move the gallery to recently deleted
            if indexPath.section == 0 {
                let nameOfGalleryToDelete = indexToGalleryName[indexPath.row]!
                indexToGalleryName[indexPath.row] = nil
                indexToDeletedGalleryName[indexToDeletedGalleryName.count] = nameOfGalleryToDelete
                tableView.reloadData()
            }
                //else, we delete the gallery permenantly
            else {
                let nameOfGalleryToDelete = indexToDeletedGalleryName[indexPath.row]!
                //DELETE THE ACTUAL DATA FROM DISK
                let isDeleteSucceeded = deleteGalleryFromDisk(name: nameOfGalleryToDelete, index: indexPath.row)
                if isDeleteSucceeded {
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    func deleteGalleryFromDisk(name: String, index: Int) -> Bool {
        if let urlToDelete = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name + ".json") {
            do {
                try FileManager.default.removeItem(at: urlToDelete)
                galleriesNames[name] = nil
                indexToDeletedGalleryName[index] = nil
                return true
            } catch let error {
                print("couldn't delete File: \(error)")
            }
        }
        return false
    }
    
    //supporting swipe in the other direction to undelete from recently delted
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let action  = UIContextualAction(style: .normal, title: "Undelete", handler: { action,tableView,completionHandler  in
                let galleryNameToUndelete = self.indexToDeletedGalleryName[indexPath.row]
                self.indexToDeletedGalleryName[indexPath.row] = nil
                self.indexToGalleryName[self.indexToGalleryName.count] = galleryNameToUndelete
                self.tableView.reloadData()
            } )
            return UISwipeActionsConfiguration(actions: [action])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
}
extension ImageGalleryTableViewController: ImageGalleryTabelViewCellDelegate {
    func changeName(for cell: ImageGalleryTableViewCell, formerName: String, newName: String) {
        let indexOfCell = galleriesTableView.indexPath(for: cell)!.row
        // MARK - change to actualNameInThe system
        var gallery = loadGallery(nameOfGalleryToLoad: formerName)
        gallery!.settings.name = newName
        if gallery != nil {
            if saveGallery(gallery: gallery!){
                deleteGalleryFromDisk(name: formerName, index: indexOfCell)
            }
          
        }
        
    }
}
