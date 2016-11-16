//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Andy Wong on 11/9/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!

    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self

        store.fetchRecentPhotos() {
            (photosResult) in

            let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
            let allPhotos = try! self.store.fetchMainQueuePhotos(predicate: nil, sortDescriptors: [sortByDateTaken])

            OperationQueue.main.addOperation {
                self.photoDataSource.photos = allPhotos
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()

        super.viewWillTransition(to: size, with: coordinator)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[indexPath.row]

        store.fetchImageForPhoto(photo) { result in
            OperationQueue.main.addOperation {
                let photoIndex = self.photoDataSource.photos.index(of: photo)!
                let photoIndexPath = IndexPath(row: photoIndex, section: 0)

                if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                    cell.updateWithImage(photo.image)
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let spacing = layout.minimumInteritemSpacing * 3 + layout.sectionInset.left + layout.sectionInset.right
        let size = (collectionView.bounds.width - spacing) / 4

        return CGSize(width: size, height: size)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhoto" {
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.row]

                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        }
    }
}
