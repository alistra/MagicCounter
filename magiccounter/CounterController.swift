//
//  CounterController.swift
//  magiccounter
//
//  Created by Aleksander Balicki on 10/02/2019.
//  Copyright © 2019 Alistra. All rights reserved.
//

import Foundation

#if os(watchOS)
import WatchConnectivity
#endif

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

struct Game: Codable, CustomStringConvertible, Equatable {
    let myLife: Int
    let opponentLife: Int
    let date: Date = Date()
    
    static var newGame: Game {
        return Game(myLife: 20, opponentLife: 20)
    }

    var description: String {
        return "Game(me: \(myLife), opp: \(opponentLife))"
    }
    
    static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.myLife == rhs.myLife && lhs.opponentLife == rhs.opponentLife
    }
}

class CounterController: NSObject {
    public static let shared = CounterController()
    private let userDefaults: UserDefaults = .standard
    
    var gameHistories: [GameHistory] {
        return previousGameHistories + [currentGameHistory]
    }
    
    var firstGameHistory: GameHistory {
        return previousGameHistories.first!
    }
    
    var currentGameHistory: GameHistory {
        return userDefaults.currentGameHistory
    }
    
    var previousGameHistories: [GameHistory] {
        return userDefaults.previousGameHistories
    }
    
    var allStates: [Game] {
        return previousGameHistories.flatMap { $0.states } + currentGameHistory.states
    }
    
    func reset() {
        userDefaults.currentGameHistory = GameHistory()
    }
    
    func nextGame() {
        userDefaults.previousGameHistories.append(currentGameHistory)
        userDefaults.currentGameHistory = GameHistory()
        
        #if os(watchOS)
        WCSession.default.transferUserInfo([
            UserDefaults.standard.previousGameHistoriesKey: userDefaults.previousGameHistoriesData as Any,
            UserDefaults.standard.currentGameHistoryKey: userDefaults.currentGameHistoryData as Any
        ])
        #endif
    }

    private func modifyHistory(block: (Game) -> (Game)) {
        let history = currentGameHistory
        let newState = block(currentGameHistory.currentState)

        guard newState != currentGameHistory.currentState else {
            return
        }
        
        history.states.append(newState)
        userDefaults.currentGameHistory = history
        #if os(watchOS)
        WCSession.default.transferUserInfo([
            UserDefaults.standard.currentGameHistoryKey: userDefaults.currentGameHistoryData as Any
        ])
        #endif
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
    
    func gameHistories(from data: Data) throws -> [GameHistory] {
        return try JSONDecoder().decode([GameHistory].self, from: data)
    }
    
    func data(from gameHistories: [GameHistory]) throws -> Data {
        return try JSONEncoder().encode(gameHistories)
    }
    
    var currentGameHistoryData: Data? {
        get {
            return data(forKey: currentGameHistoryKey)
        }
        set {
            set(newValue, forKey: currentGameHistoryKey)
        }
    }
    
    var previousGameHistoriesData: Data? {
        get {
            return data(forKey: previousGameHistoriesKey)
        }
        set {
            set(newValue, forKey: previousGameHistoriesKey)
        }
    }
    
    var currentGameHistory: GameHistory {
        get {
            guard let historyData = data(forKey: currentGameHistoryKey) else {
                print("No current history stored")
                return GameHistory()
            }
            
            do {
                guard let history = try gameHistories(from: historyData).first else {
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
                let historiesData = try data(from: [newValue])
                set(historiesData, forKey: currentGameHistoryKey)
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
                return try gameHistories(from: historiesData)
            } catch {
                print("Can't decode previous histories \(error)")
                return []
            }
        }
        
        set {
            do {
                let historiesData = try data(from: newValue)
                set(historiesData, forKey: previousGameHistoriesKey)
            } catch {
                print("Couldn't encode previous histories \(error)")
            }
        }
    }
}
