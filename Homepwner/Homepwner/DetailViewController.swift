//
//  DetailViewController.swift
//  Homepwner
//
//  Created by Andy Wong on 11/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var nameField: ItemTextField!
    @IBOutlet var serialNumberField: ItemTextField!
    @IBOutlet var valueField: ItemTextField!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var imageView: UIImageView!

    var item: Item! {
        didSet {
            navigationItem.title = item.name
        }
    }
    var imageStore: ImageStore!
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera

            let overlayView = OverlayView(frame: CGRect(x: 138, y: 244, width: 100, height: 100))
            overlayView.backgroundColor = .clear
            imagePicker.cameraOverlayView = overlayView
        } else {
            imagePicker.sourceType = .photoLibrary
        }

        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func removePicture(_ sender: UIBarButtonItem) {
        imageStore.deleteImageForKey(item.itemKey)
        imageView.image = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = item.name
        serialNumberField.text = item.serialNumber
        valueField.text = numberFormatter.string(from: item.valueInDollars as NSNumber)
        dateLabel.text = dateFormatter.string(from: item.dateCreated)

        let key = item.itemKey

        let imageToDisplay = imageStore.imageForKey(key)
        imageView.image = imageToDisplay
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)

        item.name = nameField.text ?? ""
        item.serialNumber = serialNumberField.text

        if let valueText = valueField.text, let value = numberFormatter.number(from: valueText) {
            item.valueInDollars = value.intValue
        } else {
            item.valueInDollars = 0
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage

        imageStore.setImage(image, forKey: item.itemKey)
        imageView.image = image

        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeDate" {
            let datePickerViewController = segue.destination as! DatePickerViewController
            datePickerViewController.item = item
        }
    }
}
