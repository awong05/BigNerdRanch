//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Andy Wong on 11/9/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var store: PhotoStore!

    override func viewDidLoad() {
        super.viewDidLoad()

        store.fetchRecentPhotos() {
            (photosResult) in

            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) recent photos.")

                if let firstPhoto = photos.first {
                    self.store.fetchImageForPhoto(firstPhoto) {
                        (imageResult) in

                        switch imageResult {
                        case let .success(image):
                            OperationQueue.main.addOperation {
                                self.imageView.image = image
                            }
                        case let .failure(error):
                            print("Error downloading image: \(error)")
                        }
                    }
                }
            case let .failure(error):
                print("Error fetching recent photos: \(error)")
            }
        }
    }
}
