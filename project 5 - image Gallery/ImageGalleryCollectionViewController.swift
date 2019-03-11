//
//  ViewController.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var cache: URLCache?
    weak var delegate: ImageGalleryCollectionViewControllerDelegate?
    @IBOutlet weak var urlTextField: UITextField! {
        didSet {
            urlTextField.delegate = self
        }
    }
    var imagesUrl = [URL]()
    var imagesSize = [URL:CGSize]()
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
        if let url =  urlTextField?.text {
            if let validUrl = URL(string: url) {
                if !imagesUrl.contains(validUrl) {
                    urlTextField.text = ""
                    //adding the image to the model
                    DispatchQueue.global(qos: .userInteractive).sync {
                        imagesUrl.append(validUrl)
                    }
                    //adding the image to the collection view
                    DispatchQueue.main.async {[weak self] in
                        self?.imageGalleryCollectionView.insertItems(at: [IndexPath(row: self!.imagesUrl.count - 1, section: 0)])
                    }
                    //updating the tableview controller that we added a url
                    delegate?.addUrl(url: validUrl, galleryName: navigationItem.title!)
                } else {
                    urlTextField.text = "image already in the gallery"
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageFromUrl", for: indexPath)
        if let imageCollectionViewCell = cell as? ImageCollectionViewCell {
            imageCollectionViewCell.delegate = self
            if imageCollectionViewCell.indexOfUrl != indexPath.row {
                imageCollectionViewCell.indexOfUrl = indexPath.row
                self.updateCell(fromURL: self.imagesUrl[imageCollectionViewCell.indexOfUrl!], toCell: imageCollectionViewCell, indexPath: indexPath)
            } else {
                DispatchQueue.main.async {
                    self.flowLayout?.invalidateLayout()
                }
            }
        }
        return cell
    }
    
    private func updateCell(fromURL url: URL, toCell cell: ImageCollectionViewCell, indexPath: IndexPath){
        //show the user that the images are being fetched
        DispatchQueue.main.async {[weak cell] in
            cell?.imageView.image = nil
            cell?.indicator.startAnimating()
        }
        DispatchQueue.global(qos: .userInitiated).async {[weak cell] in
            let request = URLRequest(url: url)
            //if the image data is in the cache then we load the image To the cell
            if let imageData = self.cache?.cachedResponse(for: request)?.data, let imageToLoad = UIImage(data: imageData) {
                self.loadImageToCell(fromURL: url, toCell: cell, image: imageToLoad)
            }
                //else, we need to fetch the image
            else {
                URLSession.shared.dataTask(with: request, completionHandler: {[weak self] (data, response, error) in
                    if let imageData = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let imageToLoad = UIImage(data: imageData) {
                        //if we got the image and it is valid then we cahce it and load image to cell
                        let cachedData = CachedURLResponse(response: response, data: imageData)
                        self?.cache?.storeCachedResponse(cachedData, for: request)
                        self?.loadImageToCell(fromURL: url, toCell: cell, image: imageToLoad)
                    } else {
                        //else ,we romve it from the data, andf let the user know it is an invalid url
                        if let index = self?.imagesUrl.lastIndex(of: url) {
                            self?.imagesUrl.remove(at: index)
                        }
                        DispatchQueue.main.async {
                            self?.urlTextField.text = "invalid url, try a different one"
                            self?.imageGalleryCollectionView.deleteItems(at: [indexPath])
                        }
                    }
                }).resume()
            }
            
        }
        
        
    }
    //once image was found update the layout and the view for the cell, and update the model
    func loadImageToCell(fromURL url: URL, toCell cell: ImageCollectionViewCell?, image: UIImage) {
        DispatchQueue.main.async {[weak cell] in
            if url == self.imagesUrl[cell!.indexOfUrl!] {
                cell?.indicator.stopAnimating()
                self.imagesSize[url] =  self.calculateSize(originalSize: image.size)
                self.flowLayout?.invalidateLayout()
                cell?.imageView.image = image
            }
        }
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
        let imageCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
        if let indexOfUrl = imageCollectionViewCell?.indexOfUrl {
            let url = imagesUrl[indexOfUrl]
            let size = imagesSize[url]
            return calculateSize(originalSize: size)
        }
        return CGSize(width: cellWidth, height: 100)
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
                let url = imagesUrl.remove(at: index)
                imagesSize[url] = nil
                indexOfImageToDelete = nil
                delegate?.deleteUrl(index: index, galleryName: navigationItem.title!)
                imageGalleryCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                let itemsToUpdate = imageGalleryCollectionView.numberOfItems(inSection: 0)
                for itemIndex in index..<itemsToUpdate {
                    let cell = imageGalleryCollectionView.cellForItem(at: IndexPath(row: itemIndex, section: 0)) as? ImageCollectionViewCell
                    cell?.indexOfUrl = cell!.indexOfUrl! - 1
                }
            }
        }
    }
    
    
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
