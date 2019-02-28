//
//  imageGalleryTableTableViewController.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class imageGalleryTableTableViewController: UITableViewController {
    var galleries = ["gallery1", "gallery3"]
    var recentlyDeleted = ["gallery2"]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "galleriesCell", for: indexPath)
        cell.textLabel?.text =  indexPath.section == 0 ? galleries[indexPath.row] : recentlyDeleted[indexPath.row]
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
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    segue.destination.navigationItem.title = cell.textLabel?.text
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
                recentlyDeleted.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
          
            // Delete the row from the data source
           
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
