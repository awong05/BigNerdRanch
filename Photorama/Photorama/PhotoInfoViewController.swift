//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Andy Wong on 11/12/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var viewCounter: UILabel!

    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            photo.numberOfViews += 1
            try store.coreDataStack.saveChanges()
        } catch {
            print("Failed to increment view tracker.")
        }

        viewCounter.text = "\(photo.numberOfViews) Views"
        
        store.fetchImageForPhoto(photo) { result in
            switch result {
            case let .success(image):
                OperationQueue.main.addOperation {
                    self.imageView.image = image
                }
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTags" {
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
    
            tagController.store = store
            tagController.photo = photo
        }
    }
}
