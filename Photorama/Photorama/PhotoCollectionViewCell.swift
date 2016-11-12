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
