//
//  FullScreenScrollableImageView.swift
//  project 5 - image Gallery
//
//  Created by Tomer Kobrinsky on 03/03/2019.
//  Copyright © 2019 Tomer Kobrinsky. All rights reserved.
//

import UIKit

class FullScreenScrollableImageView: UIView , UIScrollViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollview: UIScrollView! {
        didSet {
            scrollview.minimumZoomScale = 1/20
            scrollview.maximumZoomScale = 1.2
            scrollview.delegate = self
        }
    }
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }

}
