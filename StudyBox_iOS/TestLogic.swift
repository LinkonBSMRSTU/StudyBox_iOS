//
//  TestLogic.swift
//  StudyBox_iOS
//
//  Created by user on 12.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

class Test {
    
    private var deck : [Flashcard]
    private var currentCard : Flashcard?
    private var passedFlashcards = 0
    private var index = 0
    
    init(deck : [Flashcard]) {
        
        self.deck = deck
        currentFlashcard()
    }
    
    func currentFlashcard() -> Flashcard? {
        
        var rand : Int
        
        if(deck.count == 0) {
            
            return nil
        }
        else {
            
            rand = Int(arc4random_uniform(UInt32(deck.count)))
            currentCard = deck[rand]
            deck.removeAtIndex(rand)
            index += 1
            return currentCard
        }
    }
    
    func correctAnswer(){ //funkcja podpieta pod przycisk dobra odpowiedz
        
        passedFlashcards += 1
        currentFlashcard()
    }
    
    func IncorrectAnswer(){   //funkcja podpieta pod przycisk zla odpowiedz
        
        currentFlashcard()
    }
    
}