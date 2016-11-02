//
//  ItemCell.swift
//  Homepwner
//
//  Created by Andy Wong on 11/1/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var serialNumberLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!

    func updateLabels() {
        let bodyFont = UIFont.preferredFont(forTextStyle: .body)
        nameLabel.font = bodyFont
        valueLabel.font = bodyFont

        let caption1Font = UIFont.preferredFont(forTextStyle: .caption1)
        serialNumberLabel.font = caption1Font
    }
}
