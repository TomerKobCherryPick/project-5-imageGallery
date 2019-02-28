//
//  ViewController.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 27/02/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class galleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var imagesUrl: [URL] =
        [URL(string: "https://i.dietdoctor.com/wp-content/uploads/2018/07/starchyfoods.jpg?auto=compress%2Cformat&w=800&h=388&fit=crop")!,
         URL(string: "https://www.hindustantimes.com/rf/image_size_960x540/HT/p2/2018/05/28/Pictures/_c618b53a-6262-11e8-a998-12ee0acfa260.jpg")!,
         URL(string: "https://www.sparkpeople.com/news/genericpictures/bigpictures/carbtruth_header.png")!]
    var imagesSize = [Int:CGSize]()
    
    var flowLayout: UICollectionViewFlowLayout? {
        return imageGalleryCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }

    @IBOutlet weak var imageGalleryCollectionView: UICollectionView! {
        didSet {
            imageGalleryCollectionView.dataSource = self
            imageGalleryCollectionView.delegate = self
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
                        self.imagesSize[indexPath.row] = self.calulateSize(originalImage: UIImage(data: imageData))
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
            let width = CGFloat(300)
            let height = aspectRatio * width
            return CGSize(width: width, height: height)
        } else {
              return CGSize(width: 300, height: 300)
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return imagesSize[indexPath.row] != nil ? imagesSize[indexPath.row]! : CGSize(width: 300, height: 300)
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
