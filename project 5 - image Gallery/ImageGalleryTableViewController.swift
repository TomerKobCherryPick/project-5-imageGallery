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
    var galleries = ["carbs", "guitars", "gallery1","carbs2"]
    var recentlyDeleted = ["gallery2"]
    var galleryToUrlMap = [
        "carbs" : [URL(string: "https://i.dietdoctor.com/wp-content/uploads/2018/07/starchyfoods.jpg?auto=compress%2Cformat&w=800&h=388&fit=crop")!,
                   URL(string: "https://www.hindustantimes.com/rf/image_size_960x540/HT/p2/2018/05/28/Pictures/_c618b53a-6262-11e8-a998-12ee0acfa260.jpg")!,
                   URL(string: "https://sweetsimplevegan.com/wp-content/uploads/2018/05/Homemade_Pita_Bread_Sweet_Simple_Vegan-copy.jpg")!,
                   URL(string: "https://www.tasteofhome.com/wp-content/uploads/2018/01/exps32480_MRR153791D09_18_6b-2.jpg")!,
                   URL(string: "https://5.imimg.com/data5/TB/IF/MY-41399105/potato-500x500.jpg")!,
                   URL(string: "https://d3awvtnmmsvyot.cloudfront.net/api/file/6fTZjAw9Tjqf4XrddmRQ")!]
        
        , "guitars" : [URL(string: "https://images.reverb.com/image/upload/s--dfW9xmtS--/a_exif,c_limit,e_unsharp_mask:80,f_auto,fl_progressive,g_south,h_620,q_90,w_620/v1489275409/sicf27nru9awzyaxucig.jpg")!,
                       URL(string: "https://i.ytimg.com/vi/SRsciUOWkOc/maxresdefault.jpg")!]
    ]
    
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
        galleries += ["untitled".madeUnique(withRespectTo: galleries)]
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
    }
    func deleteUrl(index: Int, galleryName: String) {
        if galleryToUrlMap[galleryName] != nil {
            galleryToUrlMap[galleryName]?.remove(at: index)
        }
    }
}
extension ImageGalleryTableViewController: ImageGalleryTabelViewCellDelegate {
    func changeName(formerName: String, newName: String) {
        if let formerIndex = galleries.firstIndex(of: formerName) {
            let urlArray = galleryToUrlMap[formerName]
            galleryToUrlMap.removeValue(forKey: formerName)
            galleryToUrlMap[newName] = urlArray
            galleries[formerIndex] = newName
        }
    }
}
