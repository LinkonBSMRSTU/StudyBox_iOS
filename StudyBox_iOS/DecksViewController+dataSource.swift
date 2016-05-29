//
//  DecksViewController+dataSource.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 29.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import SVProgressHUD

extension DecksViewController {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        if searchController.active {
            return decksSource.isEmpty ? CGSize(width: collectionView.frame.width, height: view.frame.height + topItemOffset) : CGSize.zero
        }
        return CGSize.zero
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                                 atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            guard let emptyView = collectionView
                .dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "EmptyView", forIndexPath: indexPath) as? EmptyCollectionReusableView else {
                    fatalError("Incorrect supplementary view type")
            }
            emptyView.messageLabel.text = "Nie znaleziono talii o podanej nazwie"
            return emptyView
        default:
            fatalError("Unexpected collection element")
            
        }
    }
    
    enum DummySearchingCellStates {
        case Pre
        case Current
        case Post
        
    }
    
    func dummySearchingCellState(row: Int) -> DummySearchingCellStates {
        if !searchController.active && !UIApplication.isUserLoggedIn, let collectionView = collectionView {
            let cellsInRow = Int(DecksViewController.numberOfCellsInRow(collectionView.frame.width, cellSize: Utils.DeckViewLayout.CellSquareSize)) - 1
            if  row == cellsInRow || decksSource.isEmpty || (row < cellsInRow && row == decksSource.count) {
                return .Current
            } else if row > cellsInRow {
                return .Post
            }
        }
        return .Pre
    }
    
    // Calculate number of decks. If no decks, return 0
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if UIApplication.isUserLoggedIn || searchController.active {
            return decksSource.count
        }
        return decksSource.count + 1
    }
    
    // Populate cells with decks data. Change cells style
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let view = collectionView.dequeueReusableCellWithReuseIdentifier(Utils.UIIds.DecksViewCellID, forIndexPath: indexPath)
        if let cell = view as? DecksViewCell{
            
            // setup UI reagardless of cell type
            defer {
                cell.deckNameLabel.numberOfLines = 0
                // adding line breaks
                cell.deckNameLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell.deckNameLabel.preferredMaxLayoutWidth = cell.bounds.size.width
                if let font = UIFont.sbFont(size: sbFontSizeLarge, bold: false) {
                    cell.deckNameLabel.adjustFontSizeToHeight(font, max: sbFontSizeLarge, min: sbFontSizeSmall)
                }
                
            }
            cell.layoutIfNeeded()
            
            var srcIndex = indexPath.row
            
            cell.contentView.backgroundColor = UIColor.sb_Graphite()
            switch dummySearchingCellState(indexPath.row) {
            case .Current:
                cell.contentView.backgroundColor = UIColor.sb_White()
                cell.setupBorderLayer()
                cell.deckNameLabel.textColor = UIColor.sb_Graphite()
                cell.deckNameLabel.text = "Przesuń w górę aby wyszukać więcej talii"
                
                return cell
            case .Post:
                srcIndex -= 1
            default:
                break
            }
            cell.deckNameLabel.textColor = UIColor.whiteColor()
            
            var deckName = decksSource[srcIndex].name
            if deckName.isEmpty {
                deckName = Utils.DeckViewLayout.DeckWithoutTitle
            }
            cell.deckNameLabel.text = deckName
            cell.removeBorderLayer()
            return cell
        }
        return view
    }
    
    // When cell tapped, change to test
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var srcIndex = indexPath.row
        switch dummySearchingCellState(indexPath.row) {
        case .Current:
            collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.contentInset.top), animated: true)
            return
        case .Post:
            srcIndex -= 1
        default:
            break
        }
        
        SVProgressHUD.show()
        let deck = decksSource[srcIndex]
        searchBar.resignFirstResponder()
        let resetSearchUI = {
            self.searchController.active = false
        }
        
        dataManager.flashcards(deck.serverID) {
            switch $0 {
            case .Success(let flashcards):
                guard !flashcards.isEmpty else {
                    SVProgressHUD.showInfoWithStatus("Talia nie ma fiszek.")
                    return
                }
                
                let amountFlashcardsNotHidden = flashcards.reduce(0) { ret, flashcard in flashcard.hidden ? ret : ret + 1}
                
                guard amountFlashcardsNotHidden != 0 else {
                    SVProgressHUD.showInfoWithStatus("Talia ma ukryte wszystkie fiszki.")
                    return
                }
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Test czy nauka?", message: "Wybierz tryb, który chcesz uruchomić", preferredStyle: .Alert)
                
                let testButton = UIAlertAction(title: "Test", style: .Default){ (alert: UIAlertAction!) -> Void in
                    let alertAmount = UIAlertController(title: "Jaka ilość fiszek?", message: "Wybierz ilość fiszek w teście", preferredStyle: .Alert)
                    
                    let amounts = [ 1, 5, 10, 15, 20 ]
                    
                    for amount in amounts {
                        if amount < amountFlashcardsNotHidden {
                            alertAmount.addAction(UIAlertAction(title: String(amount), style: .Default) { act in
                                resetSearchUI()
                                self.performSegueWithIdentifier("StartTest",
                                    sender: Test(flashcards: flashcards, testType: .Test(UInt32(amount)), deck: deck))
                                })
                        } else {
                            break
                        }
                    }
                    alertAmount.addAction(UIAlertAction(title: "Wszystkie (" + String(amountFlashcardsNotHidden) + ")", style: .Default) { act in
                        resetSearchUI()
                        self.performSegueWithIdentifier("StartTest",
                            sender: Test(flashcards: flashcards, testType: .Test(UInt32(amountFlashcardsNotHidden)), deck: deck))
                        })
                    alertAmount.addAction(UIAlertAction(title: "Anuluj", style: UIAlertActionStyle.Cancel, handler: nil))
                    
                    self.presentViewController(alertAmount, animated: true, completion:nil)
                }
                let studyButton = UIAlertAction(title: "Nauka", style: .Default) { (alert: UIAlertAction!) -> Void in
                    resetSearchUI()
                    self.performSegueWithIdentifier("StartTest", sender: Test(flashcards: flashcards, testType: .Learn, deck: deck))
                }
                
                alert.addAction(testButton)
                alert.addAction(studyButton)
                alert.addAction(UIAlertAction(title: "Anuluj", style: UIAlertActionStyle.Cancel, handler: nil))
                
                self.presentViewController(alert, animated: true, completion:nil)
                
            case .Error(_):
                SVProgressHUD.showErrorWithStatus("Nie udało się pobrać danych.")
            }
        }
    }
}
