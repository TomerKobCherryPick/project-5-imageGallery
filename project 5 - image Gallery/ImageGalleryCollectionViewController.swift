//
//  ViewController.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    weak var delegate: ImageGalleryCollectionViewControllerDelegate?
    @IBOutlet weak var urlTextField: UITextField! {
        didSet {
            urlTextField.delegate = self
        }
    }
    var imagesUrl = [URL]()
    var imagesSize = [Int:CGSize]()
    var cellWidth:CGFloat = 300
    var flowLayout: UICollectionViewFlowLayout? {
        return imageGalleryCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    var indexOfImageToDelete: Int?
    @IBOutlet weak var imageGalleryCollectionView: UICollectionView! {
        didSet {
            imageGalleryCollectionView.dataSource = self
            imageGalleryCollectionView.delegate = self
            //gesture to zoom
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureToScaleCells))
            imageGalleryCollectionView.addGestureRecognizer(pinchGestureRecognizer)
        }
        
    }
    
    @objc func pinchGestureToScaleCells(_ recognizer: UIPinchGestureRecognizer) {
        var newWidth = cellWidth * recognizer.scale
        // zoom as long as the width is not larger than the collectionView's width
        if newWidth > imageGalleryCollectionView.contentSize.width {
            newWidth = imageGalleryCollectionView.contentSize.width
        }
            // and not amaller than some constant(100)
        else if newWidth < CGFloat(100){
            newWidth =  CGFloat(100)
        }
        cellWidth = newWidth
        DispatchQueue.main.async {
            self.flowLayout?.invalidateLayout()
        }
    }
    @IBAction func touchAddImage(_ sender: Any) {
        if let url =  urlTextField?.text  {
            if let validUrl = URL(string: url) {
                urlTextField.text = ""
                //adding the image to the model
                DispatchQueue.global(qos: .userInteractive).sync {
                    imagesUrl.append(validUrl)
                }
                //adding the image to the collection view
                DispatchQueue.main.async {
                    self.imageGalleryCollectionView.insertItems(at: [IndexPath(row: self.imagesUrl.count - 1, section: 0)])
                }
                //updating the tableview controller that we added a url
                delegate?.addUrl(url: validUrl, galleryName: navigationItem.title!)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageFromUrl", for: indexPath)
        if let imageCollectionViewCell = cell as? ImageCollectionViewCell {
            imageCollectionViewCell.indexOfUrl = indexPath.row
            imageCollectionViewCell.delegate = self
            //show the user that the images are being fetched
            DispatchQueue.main.async {
                imageCollectionViewCell.imageView.image = nil
                imageCollectionViewCell.indicator.startAnimating()
            }
            //start fetching the images
            DispatchQueue.global(qos: .userInitiated).async {[weak imageCollectionViewCell] in
                let url = self.imagesUrl[indexPath.row]
                let urlContents = try? Data(contentsOf: url)
                if imageCollectionViewCell != nil {
                    if let imageData = urlContents {
                        self.imagesSize[indexPath.row] =  UIImage(data: imageData)?.size
                        //once image was found update the layout and the view for the cell
                        if imageCollectionViewCell?.indexOfUrl == indexPath.row {
                            DispatchQueue.main.async {
                                imageCollectionViewCell?.imageView.image = UIImage(data: imageData)
                                imageCollectionViewCell?.indicator.stopAnimating()
                                self.flowLayout?.invalidateLayout()
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    private func calculateSize(originalSize: CGSize?) ->  CGSize {
        if originalSize != nil {
            let aspectRatio = originalSize!.height / originalSize!.width
            let height = aspectRatio * cellWidth
            return CGSize(width: cellWidth, height: height)
        } else {
            return CGSize(width: cellWidth, height: 100)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return calculateSize(originalSize: imagesSize[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "fullScreenImage":
                let image = (sender as? ImageCollectionViewCell)?.imageView.image
                if let destination = (segue.destination.view as? FullScreenScrollableImageView) {
                    destination.imageView.image = image
                    destination.imageView.sizeToFit()
                    destination.scrollview.contentSize = destination.imageView.frame.size
                    destination.scrollViewWidth.constant = destination.scrollview.contentSize.width
                    destination.scrollViewHeight.constant = destination.scrollview.contentSize.height
                }
            default: break
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // adding a button for deletion on the navigationBar
        let trashButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(deletePhotoInGallery))
        navigationItem.rightBarButtonItem = trashButton
    }
    
    @objc func deletePhotoInGallery() {
        //if index is valid and in range we can delete an image
        if let index = indexOfImageToDelete, index < imagesUrl.count {
            DispatchQueue.global(qos: .userInteractive).sync {
                (self.imageGalleryCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as?ImageCollectionViewCell)?.isSelectedToBeDeleted = false
                imagesUrl.remove(at: index)
                imagesSize[index] = nil
                indexOfImageToDelete = nil
                delegate?.deleteUrl(index: index, galleryName: navigationItem.title!)
                DispatchQueue.main.async {
                   // self.imageGalleryCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                    self.imageGalleryCollectionView.reloadData()
                }
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension ImageGalleryCollectionViewController: ImageCollectionViewCellDelegate {
    func selectImageToDelete(index: Int) {
        let isImageAtIndexSelected: Bool
        if index == indexOfImageToDelete {
            indexOfImageToDelete = nil
            isImageAtIndexSelected = false
        } else {
            if let oldIndex = indexOfImageToDelete {
                (self.imageGalleryCollectionView.cellForItem(at: IndexPath(row: oldIndex, section: 0)) as? ImageCollectionViewCell)?.isSelectedToBeDeleted = false
            }
            indexOfImageToDelete = index
            isImageAtIndexSelected = true
        }
        (self.imageGalleryCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageCollectionViewCell)?.isSelectedToBeDeleted = isImageAtIndexSelected
    }
    
    
}
extension ImageGalleryCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
