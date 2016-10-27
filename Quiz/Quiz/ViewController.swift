//
//  ViewController.swift
//  Quiz
//
//  Created by Andy Wong on 10/16/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var currentQuestionLabel: UILabel!
    @IBOutlet var currentQuestionLabelCenterXConstraint: NSLayoutConstraint!

    @IBOutlet var nextQuestionLabel: UILabel!
    @IBOutlet var nextQuestionLabelCenterXConstraint: NSLayoutConstraint!

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
        nextQuestionLabel.text = question
        answerLabel.text = "???"

        animateLabelTransitions()
    }

    @IBAction func showAnswer(sender: AnyObject) {
        let answer: String = answers[currentQuestionIndex]
        answerLabel.text = answer
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        currentQuestionLabel.text = questions[currentQuestionIndex]

        updateOffScreenLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nextQuestionLabel.alpha = 0
    }

    func animateLabelTransitions() {
        view.layoutIfNeeded()

        let screenWidth = view.frame.width
        self.nextQuestionLabelCenterXConstraint.constant = 0
        self.currentQuestionLabelCenterXConstraint.constant += screenWidth

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
                           self.currentQuestionLabel.alpha = 0
                           self.nextQuestionLabel.alpha = 1

                          self.view.layoutIfNeeded()
                       },
                       completion: { _ in
                           swap(&self.currentQuestionLabel,
                                &self.nextQuestionLabel)
                           swap(&self.currentQuestionLabelCenterXConstraint,
                                &self.nextQuestionLabelCenterXConstraint)

                          self.updateOffScreenLabel()
                       })
    }

    func updateOffScreenLabel() {
        let screenWidth = view.frame.width
        nextQuestionLabelCenterXConstraint.constant = -screenWidth
    }
}
