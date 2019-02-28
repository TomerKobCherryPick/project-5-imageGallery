//
//  imageGalleryTableTableViewController.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class imageGalleryTableTableViewController: UITableViewController {
    var galleries = ["carbs", "guitars", "gallery1"]
    var recentlyDeleted = ["gallery2"]
    var galleryToUrlMap = [
        "carbs" : [URL(string: "https://i.dietdoctor.com/wp-content/uploads/2018/07/starchyfoods.jpg?auto=compress%2Cformat&w=800&h=388&fit=crop")!,
                   URL(string: "https://www.hindustantimes.com/rf/image_size_960x540/HT/p2/2018/05/28/Pictures/_c618b53a-6262-11e8-a998-12ee0acfa260.jpg")!,
                   URL(string: "https://www.sparkpeople.com/news/genericpictures/bigpictures/carbtruth_header.png")!]
        
        , "guitars" : [URL(string: "https://images.reverb.com/image/upload/s--dfW9xmtS--/a_exif,c_limit,e_unsharp_mask:80,f_auto,fl_progressive,g_south,h_620,q_90,w_620/v1489275409/sicf27nru9awzyaxucig.jpg")!,
                       URL(string: "https://i.ytimg.com/vi/SRsciUOWkOc/maxresdefault.jpg")!]
        
    ]
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? galleries.count : recentlyDeleted.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell: UITableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "galleriesCell", for: indexPath)
            cell.textLabel?.text = galleries[indexPath.row]
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "deletedGalleriesCell", for: indexPath)
            cell.textLabel?.text = recentlyDeleted[indexPath.row]
        }
        return cell
    }
    
    @IBAction func touchAddGallery(_ sender: UIBarButtonItem) {
        galleries += ["untitled"]
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Recently Deleted"
        }
        return nil
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showGallery":
                if let cell = sender as? UITableViewCell, let _ = tableView.indexPath(for: cell) {
                    let galleryTitle = cell.textLabel?.text
                    segue.destination.navigationItem.title = galleryTitle
                    if let gallery = (segue.destination as? galleryViewController) {
                        gallery.delegate = self
                        if galleryToUrlMap[galleryTitle!] != nil {
                            gallery.imagesUrl = galleryToUrlMap[galleryTitle!]!
                        }
                    }
                }
            default: break
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                recentlyDeleted.append(galleries.remove(at: indexPath.row))
                tableView.reloadData()
            } else {
                let nameOfGalleryToDelete = tableView.cellForRow(at: indexPath)?.textLabel?.text
                recentlyDeleted.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                galleryToUrlMap.removeValue(forKey: nameOfGalleryToDelete!)
            }
            // Delete the row from the data source
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
        let action  = UIContextualAction(style: .normal, title: "Undelete", handler: {action,tableView,completionHandler  in
            self.galleries.append(self.recentlyDeleted.remove(at: indexPath.row))
            self.tableView.reloadData()
        } )
        return UISwipeActionsConfiguration(actions: [action])
        } else {
            return UISwipeActionsConfiguration(actions: [])
        }
    }
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension imageGalleryTableTableViewController: galleryViewControllerDelegate {
    func addUrl(url: URL, galleryName: String) {
        if galleryToUrlMap[galleryName] != nil {
            galleryToUrlMap[galleryName]?.append(url)
        } else {
            galleryToUrlMap[galleryName] = [url]
        }
    }
    
    
    
    
}
