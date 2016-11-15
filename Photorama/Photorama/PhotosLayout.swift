//
//  PhotosLayout.swift
//  Photorama
//
//  Created by Andy Wong on 11/15/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PhotosLayout: UICollectionViewFlowLayout {
    fileprivate let photoWidth: CGFloat = 362
    fileprivate let photoHeight: CGFloat = 568
    fileprivate var numberOfPhotos = 0

    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(numberOfPhotos / 2) * collectionView!.bounds.width, height: collectionView!.bounds.height)
    }

    override func prepare() {
        super.prepare()

        numberOfPhotos = collectionView!.numberOfItems(inSection: 0)
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView?.isPagingEnabled = true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()

        for i in 0..<max(0, numberOfPhotos) {
            let indexPath = IndexPath(item: i, section: 0)

            if let attribute = layoutAttributesForItem(at: indexPath) {
                attributes.append(attribute)
            }
        }

        return attributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

        let frame = getFrame(collectionView!)
        attributes.frame = frame

        let ratio = getRatio(collectionView!, indexPath: indexPath)

        if ratio > 0 && indexPath.item % 2 == 1 || ratio < 0 && indexPath.item % 2 == 0 {
            if indexPath.row != 0 {
                return attributes
            }
        }

        let rotation = getRotation(indexPath, ratio: min(max(ratio, -1), 1))
        attributes.transform3D = rotation

        if indexPath.row == 0 {
            attributes.zIndex = Int.max
        }

        return attributes
    }

    func getFrame(_ collectionView: UICollectionView) -> CGRect {
        var frame = CGRect()

        frame.origin.x = collectionView.bounds.width / 2 - photoWidth / 2 + collectionView.contentOffset.x
        frame.origin.y = (collectionViewContentSize.height - photoHeight) / 2
        frame.size.width = photoWidth
        frame.size.height = photoHeight
        
        return frame
    }

    func getRatio(_ collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat {
        let page = CGFloat(indexPath.item - indexPath.item % 2) * 0.5
        var ratio: CGFloat = -0.5 + page - (collectionView.contentOffset.x / collectionView.bounds.width)

        if ratio > 0.5 {
            ratio = 0.5 + 0.1 * (ratio - 0.5)
        } else if ratio < -0.5 {
            ratio = -0.5 + 0.1 * (ratio + 0.5)
        }

        return ratio
    }

    func getAngle(_ indexPath: IndexPath, ratio: CGFloat) -> CGFloat {
        var angle = indexPath.item % 2 == 0 ? (1 - ratio) * CGFloat(-M_PI_2) : (1 + ratio) * CGFloat(M_PI_2)

        angle += CGFloat(indexPath.row % 2) / 1000

        return angle
    }

    func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000
        return transform
    }

    func getRotation(_ indexPath: IndexPath, ratio: CGFloat) -> CATransform3D {
        var transform = makePerspectiveTransform()
        let angle = getAngle(indexPath, ratio: ratio)
        transform = CATransform3DRotate(transform, angle, 0, 1, 0)
        return transform
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
