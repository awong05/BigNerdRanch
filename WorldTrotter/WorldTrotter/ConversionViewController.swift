//
//  ConversionViewController.swift
//  WorldTrotter
//
//  Created by Andy Wong on 10/23/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ConversionViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var celsiusLabel: UILabel!
    @IBOutlet var textField: UITextField!

    private var fahrenheitValue: Double? {
        didSet {
            updateCelsiusLabel()
        }
    }

    private var celsiusValue: Double? {
        if let value = fahrenheitValue {
            return (value - 32) * (5/9)
        } else {
            return nil
        }
    }

    private let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 1
        return nf
    }()

    private let invalidCharacterSet = CharacterSet.init(charactersIn: "1234567890,.").inverted

    @IBAction func fahrenheitFieldEditingChanged(textField: UITextField) {
        if let text = textField.text, let number = numberFormatter.number(from: text) {
            fahrenheitValue = number.doubleValue
        } else {
            fahrenheitValue = nil
        }
    }

    @IBAction func dismissKeyboard(sender: AnyObject) {
        textField.resignFirstResponder()
    }

    func updateCelsiusLabel() {
        if let value = celsiusValue {
            celsiusLabel.text = numberFormatter.string(from: value as NSNumber)
        } else {
            celsiusLabel.text = "???"
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentLocale = Locale.current
        let decimalSeparator = currentLocale.decimalSeparator!

        let existingTextHasDecimalSeparator = textField.text?.range(of: decimalSeparator)
        let replacementTextHasDecimalSeparator = string.range(of: decimalSeparator)
        let replacementTextHasInvalidCharacters = string.rangeOfCharacter(from: invalidCharacterSet)

        if replacementTextHasInvalidCharacters != nil || existingTextHasDecimalSeparator != nil && replacementTextHasDecimalSeparator != nil {
            return false
        } else {
            return true
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let dateComponents = Calendar.current.dateComponents([.hour], from: Date())
        if let hour = dateComponents.hour, hour > 17 || hour < 6 {
            view.backgroundColor = UIColor.darkGray
        }
    }
}
