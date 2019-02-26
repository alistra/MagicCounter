//
//  InterfaceController.swift
//  magiccounter WatchKit Extension
//
//  Created by Aleksander Balicki on 10/02/2019.
//  Copyright © 2019 Alistra. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var myLifePicker: WKInterfacePicker?
    @IBOutlet var opponentLifePicker: WKInterfacePicker?
    
    static let lifeRange = -20..<100
    
    private let items: [WKPickerItem] = lifeRange.map {
        let item = WKPickerItem()
        item.title = "\($0)"
        item.caption = "\($0)"
        return item
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        myLifePicker?.setItems(items)
        opponentLifePicker?.setItems(items)
        
        updatePickers()
    }
    
    private func updatePickers() {
        let game = CounterController.shared.currentGameHistory.currentState
        let startMyIndex = items.lastIndex(where: { $0.title == "\(game.myLife)"}) ?? 41
        let startOpponentIndex = items.lastIndex(where: { $0.title == "\(game.opponentLife)"}) ?? 41
        
        myLifePicker?.setSelectedItemIndex(startMyIndex)
        opponentLifePicker?.setSelectedItemIndex(startOpponentIndex)
    }
    
    @IBAction func iWon() {
        savePending()
        CounterController.shared.nextGame()
        updatePickers()
    }
    
    @IBAction func theyWon() {
        savePending()
        CounterController.shared.nextGame()
        updatePickers()
    }
    
    @IBAction func reset() {
        savePending()
        CounterController.shared.currentGameHistory.reset()
        updatePickers()
    }
    
    private var lastMyLifeValue: Int?
    private var lastOpponentLifeValue: Int?
    
    private func cancelMyLifeChanged() {
        if let lastValue = lastMyLifeValue {
            NSObject.cancelPreviousPerformRequests(withTarget: CounterController.shared,
                                                   selector: #selector(CounterController.change(myLife:)),
                                                   object: lastValue)
        }
    }
    
    @IBAction func myLifeChanged(_ value: Int) {
        cancelMyLifeChanged()
        
        let life = value + (InterfaceController.lifeRange.first ?? 0)
        lastMyLifeValue = life
        CounterController.shared.perform(#selector(CounterController.change(myLife:)), with: NSNumber(value: life), afterDelay: 1.5)
    }
    
    private func cancelOppLifeChanged() {
        if let lastValue = lastOpponentLifeValue {
            NSObject.cancelPreviousPerformRequests(withTarget: CounterController.shared,
                                                   selector: #selector(CounterController.change(opponentLife:)),
                                                   object: lastValue)
        }
    }
    
    @IBAction func opponentLifeChanged(_ value: Int) {
        cancelOppLifeChanged()
        
        let life = value + (InterfaceController.lifeRange.first ?? 0)
        
        lastOpponentLifeValue = life
        CounterController.shared.perform(#selector(CounterController.change(opponentLife:)), with: NSNumber(value: life), afterDelay: 1.5)
    }
    

    private func savePending() {
        if let myLife = lastMyLifeValue {
            CounterController.shared.change(myLife: NSNumber(value: myLife))
            lastMyLifeValue = nil
        }
        if let oppLife = lastOpponentLifeValue {
            CounterController.shared.change(opponentLife: NSNumber(value: oppLife))
            lastOpponentLifeValue = nil
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        cancelMyLifeChanged()
        cancelOppLifeChanged()
        
        savePending()
        
        CLKComplicationServer.sharedInstance().activeComplications?.forEach {

            if CounterController.shared.currentGameHistory.currentState.date.addingTimeInterval(60) > Date() {
                CLKComplicationServer.sharedInstance().reloadTimeline(for: $0)
            } else {
                CLKComplicationServer.sharedInstance().extendTimeline(for: $0)
            }
        }
    }

}
