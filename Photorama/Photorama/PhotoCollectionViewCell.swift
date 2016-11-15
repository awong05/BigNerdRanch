//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Andy Wong on 11/10/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        updateWithImage(nil)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        updateWithImage(nil)
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if layoutAttributes.indexPath.item % 2 == 0 {
            layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        } else {
            layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        }
    }

    func updateWithImage(_ image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
}
