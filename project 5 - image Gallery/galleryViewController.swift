//
//  ViewController.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class galleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    weak var delegate: galleryViewControllerDelegate?
    @IBOutlet weak var urlTextField: UITextField!
    var imagesUrl = [URL]()
    var imagesSize = [Int:CGSize]()
    var cellWidth:CGFloat = 300
    var flowLayout: UICollectionViewFlowLayout? {
        return imageGalleryCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    
    @IBOutlet weak var imageGalleryCollectionView: UICollectionView! {
        didSet {
            imageGalleryCollectionView.dataSource = self
            imageGalleryCollectionView.delegate = self
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureToScaleCells))
            imageGalleryCollectionView.addGestureRecognizer(pinchGestureRecognizer)
        }
        
    }
    @objc func pinchGestureToScaleCells(_ recognizer: UIPinchGestureRecognizer) {
        var newWidth = cellWidth * recognizer.scale
        if newWidth > imageGalleryCollectionView.contentSize.width {
            newWidth = imageGalleryCollectionView.contentSize.width
        } else if newWidth < CGFloat(100){
            newWidth =  CGFloat(100)
        }
        cellWidth = newWidth
        DispatchQueue.main.async {
            self.flowLayout?.invalidateLayout()
        }
    }
    @IBAction func touchAddImage(_ sender: Any) {
        if let url =  urlTextField?.text  {
            if let validUrl = URL(string: url){
                imagesUrl.append(validUrl)
                imageGalleryCollectionView.insertItems(at: [IndexPath(row: imagesUrl.count - 1, section: 0)])
                delegate?.addUrl(url: validUrl, galleryName: navigationItem.title!)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageFromUrl", for: indexPath)
        if let imageCollectionViewCell = cell as? imageCollectionViewCell {
            //show the user that the images are being fetched
            DispatchQueue.main.async {
                imageCollectionViewCell.imageView.image = nil
                imageCollectionViewCell.indicator.startAnimating()
            }
            let url = imagesUrl[indexPath.row]
            //start fetching the images
            DispatchQueue.global(qos: .userInitiated).async {[weak imageCollectionViewCell] in
                let urlContents = try? Data(contentsOf: url)
                if imageCollectionViewCell != nil {
                    if let imageData = urlContents {
                        self.imagesSize[indexPath.row] =  UIImage(data: imageData)?.size
                        //once image was found update the layout and the view for the cell
                        DispatchQueue.main.async {
                            self.flowLayout?.invalidateLayout()
                            imageCollectionViewCell?.indicator.stopAnimating()
                            imageCollectionViewCell?.imageView.image = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
        return cell
    }
    private func calulateSize(originalImage: UIImage?) ->  CGSize{
        if let originalSize = originalImage?.size {
            let aspectRatio = originalSize.height / originalSize.width
            let height = aspectRatio * cellWidth
            return CGSize(width: cellWidth, height: height)
        } else {
            return CGSize(width: cellWidth, height: 300)
        }
        
    }
    private func calulateSize(originalSize: CGSize?) ->  CGSize{
        if originalSize != nil {
            let aspectRatio = originalSize!.height / originalSize!.width
            let height = aspectRatio * cellWidth
            return CGSize(width: cellWidth, height: height)
        } else {
            return CGSize(width: cellWidth, height: 300)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return imagesSize[indexPath.row] != nil ? calulateSize(originalSize: imagesSize[indexPath.row]) : CGSize(width: cellWidth, height: 300)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
