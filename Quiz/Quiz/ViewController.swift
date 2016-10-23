//
//  ViewController.swift
//  Quiz
//
//  Created by Andy Wong on 10/16/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerLabel: UILabel!

    private let questions = ["From what is cognac made?", "What is 7+7?", "What is the capital of Vermont?"]
    private let answers = ["Grapes", "14", "Montpelier"]
    private var currentQuestionIndex = 0

    @IBAction func showNextQuestion(sender: AnyObject) {
        currentQuestionIndex += 1
        if currentQuestionIndex == questions.count {
            currentQuestionIndex = 0
        }

        let question: String = questions[currentQuestionIndex]
        questionLabel.text = question
        answerLabel.text = "???"
    }

    @IBAction func showAnswer(sender: AnyObject) {
        let answer: String = answers[currentQuestionIndex]
        answerLabel.text = answer
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = questions[currentQuestionIndex]
    }
}
