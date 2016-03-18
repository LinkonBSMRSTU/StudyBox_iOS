//
//  DataManagerTests.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import XCTest
@testable import StudyBox_iOS
class DataManagerTests: XCTestCase {
    
    func testDummyManager(){
        let manager = DataManager.managerWithDummyData()
        let decks = manager.decks(false)[0]
        let flashcards = try? manager.flashcards(forDeck: decks)
        XCTAssertNotNil(flashcards)
    }
    func testAddDeck(){
        let manager = DataManager()
        manager.addDeck("some name")
        
        let decks = manager.decks(false)
        
        XCTAssertEqual(decks.count, 1)
        
    }
    
    func testDeck(){
        let manager = DataManager()
        let deckId = manager.addDeck("some name")
        
        let deckById = manager.deck(withId: deckId)
        
        XCTAssertNotNil(deckById,"Receiving added deck by id, must not be nil")
        
        let newDeck = Deck(id: "xxxzzz", name: "new some name")
        
        let newDeckById = manager.deck(withId: newDeck.id)
        
        XCTAssertNil(newDeckById, "Manager does not contain newDeck so it must not be able to find it by id")
        
    }
    
    func testDecks(){
        let dummyManager = DataManager.managerWithDummyData()
        let decks = dummyManager.decks(false)
        
        XCTAssert(Bool(decks.count),"Manager must return valid decks")
        
    }
    
    func testAddFlashcard(){
        let manager = DataManager()
        let deckId = manager.addDeck("some name")
        
        try! manager.addFlashcard(forDeckWithId: deckId, question: "question", answer: "answer", tip: nil)
        
        let flashcards = try? manager.flashcards(forDeckWithId: deckId)
        
        XCTAssertNotNil(flashcards)
        
        XCTAssertEqual(flashcards!.count, 1)
    }
    
    
    func testFlashcards(){
        let dummyManager = DataManager.managerWithDummyData()
        let decks = dummyManager.decks(false)
        
        let deck = decks[0]
        let flashcards = try! dummyManager.flashcards(forDeck: deck)
        XCTAssert(Bool(flashcards.count),"Dummy manager must contain at least one flashcard")
        
        let newDeck = Deck(id: "x", name: deck.name)
        
        let newFlashcards = try? dummyManager.flashcards(forDeck: newDeck)
        
        XCTAssertNil(newFlashcards,"Manager must return nil if asked for Flashcards that refer to Deck, which it doesn't contain")

    }
    
    
    func testFlashcard(){
        let manager = DataManager()
        let deckId = manager.addDeck("some name")
        
        try! manager.addFlashcard(forDeckWithId: deckId, question: "question", answer: "answer", tip: nil)
        
        let flashcards = try! manager.flashcards(forDeckWithId: deckId)
        
        let flashcard = flashcards[0]
        
        let flashcardById = manager.flashcard(withId: flashcard.id)
        
        XCTAssertNotNil(flashcardById,"Receiving added flashcard by id, must not be nil")
        
        let newCard = Flashcard(id: "xxxxxz", deckId: "xxxx", question: "question", answer: "answer", tip: nil)
        
        let newCardById = manager.flashcard(withId: newCard.id)
        
        XCTAssertNil(newCardById, "Manager doesn't contain newCard so it must not be able to find it by id")
        
    }
    
    func testUpdateDeck(){
        let dummyManager = DataManager.managerWithDummyData()
        var deck = dummyManager.decks(false)[0]
        
        deck.name = "update deck name"
        let _ = try? dummyManager.updateDeck(deck)
        
        let found = dummyManager.deck(withId: deck.id)
        
        XCTAssertEqual(found!.name, "update deck name","Deck with the id has been updated, so must be it's name")
    }
    
    func testUpdateFlashcard(){
        let manager = DataManager.managerWithDummyData()
        let deck = manager.decks(false)[0]
        var flashcard = (try! manager.flashcards(forDeck: deck))[0]
        
        flashcard.question = "update flash question"
        
        let _ = try? manager.updateFlashcard(flashcard)
        
        let found = manager.flashcard(withId: flashcard.id)
        XCTAssertEqual(found?.question, "update flash question","Deck has been updated, so must be it's name")
        
    }
    
    func testRemoveDeck(){
        let manager = DataManager.managerWithDummyData()
        let deck = manager.decks(false)[0]
        
        let _ = try? manager.removeDeck(deck)
        
        let found = manager.deck(withId: deck.id)
        
        XCTAssertNil(found, "The Deck has been deleted, so it has to be nil")
        
        let flashcards = try? manager.flashcards(forDeck: deck)
        
        XCTAssertNil(flashcards,"Removing given Deck removes all FLashcards that refer to it ")
    }
    
    func testRemoveFlashcard(){
        let manager = DataManager.managerWithDummyData()
        let deck = manager.decks(false)[0]
        
        let flashcard = (try! manager.flashcards(forDeck: deck))[0]
        
        let _ = try? manager.removeFlashcard(flashcard)
        
        let foundCard = manager.flashcard(withId: flashcard.id)
        
        XCTAssertNil(foundCard, "Flashcard has been removed, manager must not contain it")
        
    }
    
    
    
    func testPerformanceFilter(){
        let manager = DataManager()
        for i in 1...1000 {
            manager.addDeck("\(i)")
        }
        let docks = manager.decks(false)
        let firstDock = docks[0]
        self.measureBlock {
            let _ =  docks.filter( { $0.id == firstDock.id })
            
        }
        
    }
    
    /**
     Using filter function requires checking every element of an array, while it's not neccesary to look further if we found element with the given unique ID,
     that's why `findUnique` method is used to find objects by ID
     */
    func testPerformanceUniqueId(){
        let manager = DataManager()
        for i in 1...1000 {
            manager.addDeck("\(i)")
        }
        let docks = manager.decks(false)
        let firstDock = docks[0]
        
        self.measureBlock {
            manager.deck(withId: firstDock.id)
        }
    }
    
    
}