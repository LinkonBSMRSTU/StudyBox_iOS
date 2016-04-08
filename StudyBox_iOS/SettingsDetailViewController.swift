//
//  SettingsDetailViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 05.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

enum settingsDetailVCType {
    case Frequency
    case DecksForWatch
}

class SettingsDetailViewController: StudyBoxViewController, UITableViewDataSource, UITableViewDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let pickerCellID = "pickerCell"
    let checkmarkCellID = "checkmarkCell"
    let switchCellID = "switchCell"
    
    var mode:settingsDetailVCType!
    lazy private var dataManager:DataManager? = { return UIApplication.appDelegate().dataManager }()
    ///Array that holds all user's decks
    var userDecksArray: [Deck]?
    ///Array that holds
    var decksToSynchronize: [(Deck,Bool)]?
    //var notificationsEnabled:Bool
    
    @IBOutlet weak var detailTableView: UITableView!
    
    override func viewDidLoad() {
        
        if let mode = self.mode {
            switch mode {
            case .DecksForWatch:
                self.title = "Wybór talii"
                userDecksArray = dataManager?.decks(true)
            //copyUserDecksToSync()
            case .Frequency:
                self.title = "Powiadomienia"
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell!
        
        if let mode = self.mode {
            switch mode {
            case .Frequency:
                switch (indexPath.section, indexPath.row){
                case (0,0): cell = tableView.dequeueReusableCellWithIdentifier(switchCellID, forIndexPath: indexPath)
                case (0,1): cell = tableView.dequeueReusableCellWithIdentifier(pickerCellID, forIndexPath: indexPath)
                default: break
                }
                cell.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
                
            case .DecksForWatch:
                cell = tableView.dequeueReusableCellWithIdentifier(checkmarkCellID, forIndexPath: indexPath)
                switch indexPath.section {
                case 0:
                    cell.textLabel?.text = "Zaznacz/Odznacz wszystkie"
                case 1:
                    if let deckName = userDecksArray?[indexPath.row].name {
                        cell.textLabel?.text = deckName.isEmpty ? Utils.DeckViewLayout.DeckWithoutTitle : deckName
                    }
                default: break
                }
                cell.textLabel?.font = UIFont.sbFont(size: sbFontSizeLarge, bold: false)
                //TODO: set checkmark based on NSUserDefaults
                
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath)
        var selectAllState: UITableViewCellAccessoryType = .None
        
        if indexPath == NSIndexPath(forRow: 0, inSection: 0) {
            //We tap `select/deselect all`
            if let selectAllCell = tableView.cellForRowAtIndexPath(indexPath), let mode = self.mode where mode == .DecksForWatch
            {
                changeSelectionForCell(selectAllCell)
                selectAllState = selectAllCell.accessoryType
            }
            
            //Change selection to all cells in section 1
            if let deck = userDecksArray {
                for row in 0..<deck.count {
                    if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 1))
                    {
                        changeSelectionForCell(cell, toState: selectAllState)
                    }
                }
            }
            
        } else {
            //We didn't tap the `select/deselect all` row, so change only selected row
            if let selectedCell = cell, let mode = self.mode where mode == .DecksForWatch {
                changeSelectionForCell(selectedCell)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func copyUserDecksToSync() {
        
        //TODO: Do this loop only if it's the first time the user chooses decks, set a flag in NSUserDefaults
        //        if let userDecksArray = userDecksArray, var decksToSynchronize = decksToSynchronize {
        //            for i in 0...userDecksArray.count {
        //                decksToSynchronize[i] = (userDecksArray[i],false)
        //            }
        //            self.decksToSynchronize! = decksToSynchronize
        //        }
    }
    
    func changeSelectionForCell(cell:UITableViewCell) {
        if cell.accessoryType == .None {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
    }
    
    func changeSelectionForCell(cell:UITableViewCell, toState: UITableViewCellAccessoryType) {
        cell.accessoryType = toState
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            //TODO: Register notification and/or send selected decks to NSUD
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        if let mode = self.mode {
            switch mode {
            case .Frequency: rows = 2
            case .DecksForWatch:
                switch section {
                case 0: rows = 1
                case 1:
                    if let deck = userDecksArray {
                        rows = deck.count
                    }
                default: break
                }
            }
        }
        return rows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height = tableView.rowHeight
        
        if let mode = self.mode {
            switch mode {
            case .Frequency:
                switch (indexPath.section, indexPath.row){
                case (0,0): height = CGFloat(44) //height of switch cell
                case (0,1): height = CGFloat(140) //height of pickerView
                default: break
                }
            case .DecksForWatch: height = CGFloat(44) //height of checkmarkCell
            }
        }
        return height
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sections = 0
        if let mode = self.mode {
            switch mode {
            case .Frequency: sections = 1
            case .DecksForWatch: sections = 2
            }
        }
        return sections
    }
}
