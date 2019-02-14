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
        
        let game = CounterController.shared.currentGameHistory.currentState
        
        let startMyIndex = items.lastIndex(where: { $0.title == "\(game.myLife)"}) ?? 41
        let startOpponentIndex = items.lastIndex(where: { $0.title == "\(game.opponentLife)"}) ?? 41
        
        myLifePicker?.setItems(items)
        opponentLifePicker?.setItems(items)
        
        myLifePicker?.setSelectedItemIndex(startMyIndex)
        opponentLifePicker?.setSelectedItemIndex(startOpponentIndex)
    }
    
    private var lastMyLifeValue: Int?
    private var lastOpponentLifeValue: Int?
    
    @IBAction func myLifeChanged(_ value: Int) {
        if let lastValue = lastMyLifeValue {
            NSObject.cancelPreviousPerformRequests(withTarget: CounterController.shared,
                                                   selector: #selector(CounterController.change(myLife:)),
                                                   object: lastValue)
        }
        
        let life = value + (InterfaceController.lifeRange.first ?? 0)
        lastMyLifeValue = life
        CounterController.shared.perform(#selector(CounterController.change(myLife:)), with: NSNumber(value: life), afterDelay: 1.5)
    }
    
    @IBAction func opponentLifeChanged(_ value: Int) {
        if let lastValue = lastOpponentLifeValue {
            NSObject.cancelPreviousPerformRequests(withTarget: CounterController.shared,
                                                   selector: #selector(CounterController.change(opponentLife:)),
                                                   object: lastValue)
        }
        
        let life = value + (InterfaceController.lifeRange.first ?? 0)
        
        lastOpponentLifeValue = value
        CounterController.shared.perform(#selector(CounterController.change(opponentLife:)), with: NSNumber(value: life), afterDelay: 1.5)
    }
    

    override func didDeactivate() {
        super.didDeactivate()
        
        CLKComplicationServer.sharedInstance().activeComplications?.forEach {
            CLKComplicationServer.sharedInstance().reloadTimeline(for: $0)
        }
    }

}
