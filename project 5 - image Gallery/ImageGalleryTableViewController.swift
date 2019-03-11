//
//  imageGalleryTableTableViewController.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController {
    //20% of ram Cache
    let cache = URLCache(memoryCapacity: Int(ProcessInfo.processInfo.physicalMemory * 20 / 100), diskCapacity: 200 * (1024 * 1024), diskPath: "Cache")
    var gallariesModel: GalleriesModel {
        get {
            let myGallaries = galleries.map {
                Gallery(imagesUrl: galleryToUrlMap[$0]!, name: $0)
            }
            let myRecentlyDeletedGallaries = recentlyDeleted.map {
                Gallery(imagesUrl: galleryToUrlMap[$0]!, name: $0)
            }
            return GalleriesModel(galleries: myGallaries, deletedGalleries: myRecentlyDeletedGallaries)
        }
        set(newModel) {
            galleryToUrlMap = [String:[URL]]()
            if newModel.myGalleries != nil  {
                galleries = newModel.myGalleries!.map{
                    $0.name
                }
                galleryToUrlMap = (newModel.myGalleries?.reduce(into: [:]){$0[$1.name] = $1.imagesUrl}) ?? [String:[URL]]()
            }
            
            if newModel.myDeletedGalleries != nil  {
                recentlyDeleted = newModel.myDeletedGalleries!.map{
                    $0.name
                }
                for gallery in newModel.myDeletedGalleries! {
                    galleryToUrlMap[gallery.name] = gallery.imagesUrl
                }
            }
        }
    }
    
    
    var galleries = [String]()
    var recentlyDeleted = [String]()
    var galleryToUrlMap = [String : [URL]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       let model =  GalleriesModel()
        gallariesModel = model
    }
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? galleries.count : recentlyDeleted.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        // a gallery cell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "galleriesCell", for: indexPath)
            (cell as! ImageGalleryTableViewCell).nameOfGalleryText.text = galleries[indexPath.row]
            (cell as! ImageGalleryTableViewCell).delegate = self
        }
            // a deleted gallery cell
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "deletedGalleriesCell", for: indexPath)
            cell.textLabel?.text = recentlyDeleted[indexPath.row]
        }
        return cell
    }
    
    
    @IBAction func touchAddGallery(_ sender: UIBarButtonItem) {
        let nameOfNewGallery = "untitled".madeUnique(withRespectTo: galleries)
        galleries += [nameOfNewGallery]
        galleryToUrlMap[nameOfNewGallery] = [URL]()
        gallariesModel.saveModel()
        tableView.insertRows(at: [IndexPath(row: galleries.count - 1, section: 0)], with: .fade)
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
                if let cell = sender as? UITableViewCell, let _ = tableView.indexPath(for: cell), let gallery = (segue.destination as? ImageGalleryCollectionViewController) {
                    let galleryTitle = (cell as! ImageGalleryTableViewCell).nameOfGalleryText.text
                    gallery.navigationItem.title = galleryTitle
                    gallery.delegate = self
                    gallery.cache = cache
                    // if there are previous stored photos in the gallery
                    // we want to make sure we show them after segueing
                    if galleryToUrlMap[galleryTitle!] != nil {
                        gallery.imagesUrl = galleryToUrlMap[galleryTitle!]!
                    }
                }
            default: break
            }
        }
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //if we are deleting from the regular section,
            // we move the gallery to recently deleted
            if indexPath.section == 0 {
                recentlyDeleted.append(galleries.remove(at: indexPath.row))
                tableView.reloadData()
            }
                //else, we delete the gallery permenantly
            else {
                let nameOfGalleryToDelete = tableView.cellForRow(at: indexPath)?.textLabel?.text
                recentlyDeleted.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                galleryToUrlMap.removeValue(forKey: nameOfGalleryToDelete!)
            }
        }
    }
    
    //supporting swipe in the other direction to undelete from recently delted
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let action  = UIContextualAction(style: .normal, title: "Undelete", handler: { action,tableView,completionHandler  in
                self.galleries.append(self.recentlyDeleted.remove(at: indexPath.row))
                self.tableView.reloadData()
            } )
            return UISwipeActionsConfiguration(actions: [action])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    
    
    
}
extension ImageGalleryTableViewController: ImageGalleryCollectionViewControllerDelegate {
    func addUrl(url: URL, galleryName: String) {
        if galleryToUrlMap[galleryName] != nil {
            galleryToUrlMap[galleryName]?.append(url)
        } else {
            galleryToUrlMap[galleryName] = [url]
        }
        gallariesModel.saveModel()
    }
    func deleteUrl(index: Int, galleryName: String) {
        if galleryToUrlMap[galleryName] != nil {
            galleryToUrlMap[galleryName]?.remove(at: index)
        }
        gallariesModel.saveModel()
    }
}
extension ImageGalleryTableViewController: ImageGalleryTabelViewCellDelegate {
    func changeName(formerName: String, newName: String) {
        if let formerIndex = galleries.firstIndex(of: formerName) {            let urlArray = galleryToUrlMap[formerName]
            galleryToUrlMap.removeValue(forKey: formerName)
            galleryToUrlMap[newName] = urlArray
            galleries[formerIndex] = newName
        }
        gallariesModel.saveModel()
    }
}
