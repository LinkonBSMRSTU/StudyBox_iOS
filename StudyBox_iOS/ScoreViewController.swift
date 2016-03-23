//
//  ScoreViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class ScoreViewController: StudyBoxViewController {
    
    
    @IBOutlet weak var circularProgressView: UIView!
    @IBOutlet weak var congratulationsBigLabel: UILabel!
    @IBOutlet weak var congratulationsSmallLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var deckListButton: UIButton!
    @IBOutlet weak var runTestButton: UIButton!
    
    var testLogicSource:Test?
    var testScoreFraction:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        congratulationsBigLabel.font = UIFont.sbFont(size: sbFontSizeSuperLarge, bold: true)
        congratulationsSmallLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
        
        deckListButton.backgroundColor = UIColor.sb_Raspberry()
        deckListButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        deckListButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        deckListButton.layer.cornerRadius = 10
        
        runTestButton.backgroundColor = UIColor.sb_Raspberry()
        runTestButton.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1), forState: UIControlState.Normal)
        runTestButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        runTestButton.layer.cornerRadius = 10
        
        completeData()
    }
    
    override func viewDidAppear(animated: Bool) {
        animateProgressView()
    }
    
    func completeData() {
        if let testLogic = testLogicSource {
            let cardsResult = testLogic.cardsAnsweredAndPossible()
            
            self.testScoreFraction = Double(cardsResult.0) / Double(cardsResult.1)
            let testScorePercentage = Int(testScoreFraction*100)
            
            scoreLabel.font = UIFont.sbFont(size: sbFontSizeLarge, bold: true)
            scoreLabel.text = "\(cardsResult.0) / \(cardsResult.1)\n\(testScorePercentage) %"
            
            switch testLogic.testType {
            case .Learn:
                runTestButton.enabled = false
            default:
                break
            }
        }
    }
    
    ///Animating the circular progress view to testPercentage value
    func animateProgressView() {
        let progressViewFrame = circularProgressView.bounds
        let progress = KDCircularProgress(frame: progressViewFrame)
        progress.startAngle = -90
        progress.angle = 0
        progress.progressThickness = 0.25
        progress.trackThickness = 0.25
        progress.clockwise = true
        progress.glowMode = .NoGlow
        progress.center = view.center
        progress.trackColor = UIColor.sb_DarkBlue().colorWithAlphaComponent(0.3)
        progress.roundedCorners = true
        progress.setColors(UIColor.sb_DarkBlue())
        view.addSubview(progress)
        
        //Convert float to degree angle
        let percentageAngle = Int(self.testScoreFraction*360)

        //Delay the animation by 1 second
        let triggerTime = (Int64(NSEC_PER_SEC) * 1)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            progress.animateToAngle(percentageAngle, duration: 1, completion: nil)
        })
        
        
    }
    
    @IBAction func deckListButtonAction(sender: UIButton) {
        // TODO refactor for Drawer menu options
        DrawerViewController.sharedSbDrawerViewControllerChooseMenuOption(atIndex: 1)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "RepeatTest" {
            if let flashcards = testLogicSource?.notPassedInTestDeck where flashcards.count == 0 {
                presentAlertController(withTitle: "Błąd", message: "Brak fiszek do powtórzenia", buttonText: "Ok")
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RepeatTest", let destinationViewController = segue.destinationViewController as? TestViewController, let flashcards = testLogicSource?.notPassedInTestDeck {
            
            destinationViewController.testLogicSource = Test(deck: flashcards, testType: .Test(uint(flashcards.count)))
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}
