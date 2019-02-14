//
//  CounterController.swift
//  magiccounter
//
//  Created by Aleksander Balicki on 10/02/2019.
//  Copyright © 2019 Alistra. All rights reserved.
//

import Foundation

class GameHistory: Codable {
    var states: [Game] = [Game.newGame]
    
    var canUndo: Bool {
       return states.count > 1
    }
    
    func undo() {
        guard canUndo else {
            print("Tried to undo when can't")
            return
        }
        states.removeLast()
    }
    
    var currentState: Game {
        guard let last = states.last else {
            print("No history elements")
            return Game(myLife: 20, opponentLife: 20)
        }
        
        return last
    }
}

struct Game: Codable, CustomStringConvertible {
    enum Winner: Int, Codable {
        case noWinnerYet
        case me
        case opponent
        case none
    }
    let myLife: Int
    let opponentLife: Int
    
    static var newGame: Game {
        return Game(myLife: 20, opponentLife: 20)
    }
    
    var winner: Winner {
        switch (myLife <= 0, opponentLife <= 0) {
        case (false, false):
            return .noWinnerYet
        case (true, false):
            return .opponent
        case (false, true):
            return .me
        case (true, true):
            return .none
        }
    }
    
    var description: String {
        return "Game(me: \(myLife), opp: \(opponentLife))"
    }
}

class CounterController: NSObject {
    public static let shared = CounterController()
    private let userDefaults: UserDefaults = .standard
    
    var currentGameHistory: GameHistory {
        return userDefaults.currentGameHistory
    }

    private func modifyHistory(block: (Game) -> (Game)) {
        let history = userDefaults.currentGameHistory
        history.states.append(block(userDefaults.currentGameHistory.currentState))
        userDefaults.currentGameHistory = history
 
        print(history.states)
    }
    
    @objc func change(myLife: NSNumber) {
        modifyHistory {
            return Game(myLife: myLife.intValue, opponentLife: $0.opponentLife)
        }
    }
    
    @objc func change(opponentLife: NSNumber) {
        modifyHistory {
            return Game(myLife: $0.myLife, opponentLife: opponentLife.intValue)
        }
    }
}

extension UserDefaults {
    var currentGameHistoryKey: String { return "currentGameHistoryKey" }
    var previousGameHistoriesKey: String { return "previousGameHistoriesKey" }
    
    var currentGameHistory: GameHistory {
        get {
            guard let historyData = data(forKey: currentGameHistoryKey) else {
                print("No current history stored")
                return GameHistory()
            }
            
            do {
                guard let history = try JSONDecoder().decode([GameHistory].self, from: historyData).first else {
                    print("Current history not encoded as an array")
                    return GameHistory()
                }
                
                return history
            } catch {
                print("Can't decode current history \(error)")
                return GameHistory()
            }
        }
        
        set {
            do {
                let historyData = try JSONEncoder().encode([newValue])
                set(historyData, forKey: currentGameHistoryKey)
            } catch {
                print("Couldn't encode current history \(error)")
            }
        }
    }
    
    var previousGameHistories: [GameHistory] {
        get {
            guard let historiesData = data(forKey: previousGameHistoriesKey) else {
                print("No previous histories stored")
                return []
            }
            
            do {
                return try JSONDecoder().decode([GameHistory].self, from: historiesData)
            } catch {
                print("Can't decode previous histories \(error)")
                return []
            }
        }
        
        set {
            do {
                let historiesData = try JSONEncoder().encode(newValue)
                set(historiesData, forKey: previousGameHistoriesKey)
            } catch {
                print("Couldn't encode previous histories \(error)")
            }
        }
    }
}
