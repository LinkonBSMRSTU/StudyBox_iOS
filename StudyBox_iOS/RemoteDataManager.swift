//
//  RemoteDataManager.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 04.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Alamofire
import SwiftyJSON

public enum ServerError: ErrorType {
    case ErrorWithMessage(text: String)
}

public enum ServerResultType<T> {
    case Success(obj: T)
    case Error(err: ErrorType)
}

public class RemoteDataManager {
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    
    // Metoda sprawdza czy odpowiedź serwera zawiera pole 'message' - jeśli tak oznacza to, że coś poszło nie tak,
    // w przypadku jego braku dostajemy dane o które prosiliśmy
    private func handleResponse<T>(responseResult result: Alamofire.Result<AnyObject, NSError>,
                                completion: (ServerResultType<T>)->(),
                                successAction: ((JSON) -> (T))) {
        switch result {
        case .Success(let val):
            let json = JSON(val)
            if let message = json.dictionary?["message"]?.string {
                completion(.Error(err: ServerError.ErrorWithMessage(text: message)))
            } else {
                completion(.Success(obj: successAction(json)))
            }
            
        case .Failure(let err):
            completion(.Error(err: err))
        }
        
    }
    
    private func handleResponse(responseResult result: Alamofire.Result<AnyObject, NSError>,
                                               completion: (ServerResultType<JSON>)->(),
                                               successAction: ((JSON) -> ())? = nil ) {
        handleResponse(responseResult: result, completion: completion) { json in
            return json
        }
    }
    
    // Jeśli udało się zalogować metoda zwróci ServerResultType.Success z obiektem nil,
    // w przeciwnym wypadku obiekt to String z odpowiedzią serwera (powód błędu logowania)
    public func login(username: String, password: String, completion: (ServerResultType<JSON>)->()) {
        request(Router.GetCurrentUser).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion) { json in
                self.defaults.setObject(username, forKey: Utils.NSUserDefaultsKeys.LoggedUserUsername)
                self.defaults.setObject(password, forKey: Utils.NSUserDefaultsKeys.LoggedUserPassword)
                return json
            }
        }
    }
    
    func deck(deckID: String, completion: (ServerResultType<JSON>) -> ()) {
        request(Router.GetSingleDeck(id: deckID)).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion)
        }
    }
    
    func findDecks(includeOwn includeOwn: Bool? = nil, flashcardsCount: Bool? = nil, name: String? = nil, completion: (ServerResultType<[JSON]>)->()) {
        let parameters: [String: AnyObject?] =
            ["includeOwn": includeOwn,
             "flashcardsCount": flashcardsCount,
             "name": name]
        
        let flatMap = Dictionary.flat(parameters)
        
        request(Router.GetAllDecks(params: flatMap).URLRequest).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion) { json in
                return json.arrayValue
            }
        }
    }
    
    func addFlashcard(deckId: String, flashcard: Flashcard, completion: (ServerResultType<JSON>) -> ()) {
        
        request(Router.AddSingleFlashcard(question: flashcard.question, answer: flashcard.answer, isHidden: flashcard.hidden)).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion)
        }
    }
    
    func addDeck(deck: Deck, completion: (ServerResultType<JSON>) -> ()) {
        
        request(Router.GetSingleDeck(id: deck.serverID)).responseJSON {
            self.handleResponse(responseResult: $0.result, completion: completion)
        }
    }
}
