//
//  DatePickerViewController.swift
//  Homepwner
//
//  Created by Andy Wong on 11/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    @IBOutlet var datePicker: UIDatePicker!

    var item: Item!

    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.date = item.dateCreated
    }

    @IBAction func dateChanged(_ sender: UIDatePicker) {
        item.dateCreated = datePicker.date
    }
}
