//
//  ComplicationController.swift
//  magiccounter WatchKit Extension
//
//  Created by Aleksander Balicki on 10/02/2019.
//  Copyright © 2019 Alistra. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    private func entry(complication: CLKComplication, state: Game) -> CLKComplicationTimelineEntry? {
        let complicationTemplate = template(for: state, complication: complication)
        return complicationTemplate.flatMap { CLKComplicationTimelineEntry(date: state.date, complicationTemplate: $0) }
    }
    
    private func template(for game: Game, complication: CLKComplication) -> CLKComplicationTemplate? {
        
        let template: CLKComplicationTemplate?
        
        switch complication.family {
        case .graphicCorner:
            
            
            let gaugeTemplate = CLKComplicationTemplateGraphicCornerGaugeText()
            gaugeTemplate.leadingTextProvider = CLKSimpleTextProvider(text: String(game.myLife))
            gaugeTemplate.trailingTextProvider = CLKSimpleTextProvider(text: String(game.opponentLife))
            
            let fraction = Float(game.myLife) / Float(game.myLife + game.opponentLife)
            
            let gaugeProvider = CLKSimpleGaugeProvider(style: .ring,
                                                       gaugeColors: [.green, .orange],
                                                       gaugeColorLocations: [0, NSNumber(value: fraction)],
                                                       fillFraction: fraction)
            gaugeTemplate.gaugeProvider = gaugeProvider
            gaugeTemplate.outerTextProvider = CLKSimpleTextProvider(text: "LIFE")
            template = gaugeTemplate
            
        case .modularSmall:
            let simpleTextTemplate = CLKComplicationTemplateModularSmallSimpleText()
            simpleTextTemplate.textProvider = CLKSimpleTextProvider(text: "\(game.myLife)/\(game.opponentLife)")
            template = simpleTextTemplate
        case .circularSmall:
            let smallStack = CLKComplicationTemplateCircularSmallStackText()
            smallStack.line1TextProvider = CLKSimpleTextProvider(text: "\(game.myLife)")
            smallStack.line2TextProvider = CLKSimpleTextProvider(text: "\(game.opponentLife)")
            template = smallStack
        case .extraLarge:
            let columns = CLKComplicationTemplateExtraLargeColumnsText()
            columns.row1Column1TextProvider = CLKSimpleTextProvider(text: "ME")
            columns.row1Column2TextProvider = CLKSimpleTextProvider(text: "OPP")
            columns.row2Column1TextProvider = CLKSimpleTextProvider(text: "\(game.myLife)")
            columns.row2Column2TextProvider = CLKSimpleTextProvider(text: "\(game.opponentLife)")
            template = columns
        case .graphicBezel:
            let bezel = CLKComplicationTemplateGraphicBezelCircularText()
            let gauge = CLKComplicationTemplateGraphicCircularOpenGaugeRangeText()
            gauge.centerTextProvider = CLKSimpleTextProvider(text: "")
            gauge.leadingTextProvider = CLKSimpleTextProvider(text: "\(game.myLife)")
            gauge.trailingTextProvider = CLKSimpleTextProvider(text: "\(game.opponentLife)")
            let fraction = Float(game.myLife) / Float(game.myLife + game.opponentLife)
            
            let gaugeProvider = CLKSimpleGaugeProvider(style: .ring,
                                                       gaugeColors: [.green, .orange],
                                                       gaugeColorLocations: [0, NSNumber(value: fraction)],
                                                       fillFraction: fraction)
            
            gauge.gaugeProvider = gaugeProvider
            bezel.circularTemplate = gauge
            template = bezel
        default:
            template = nil
        }
        
        return template
    }
    
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(CounterController.shared.allStates.first?.date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(CounterController.shared.allStates.last?.date)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        let state = CounterController.shared.currentGameHistory.currentState
        let timelineEntry = entry(complication: complication, state: state)
        handler(timelineEntry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        let entries = CounterController.shared.allStates
            .filter { $0.date < date }
            .suffix(limit)
            .compactMap { entry(complication: complication, state: $0) }
        
        handler(entries)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        
        let entries = CounterController.shared.allStates
            .filter { $0.date > date }
            .prefix(limit)
            .compactMap { entry(complication: complication, state: $0) }
        
        handler(entries)
    }
    
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        
        let state = Game(myLife: 20, opponentLife: 20)
        let complicationTemplate: CLKComplicationTemplate? = template(for: state, complication: complication)
        handler(complicationTemplate)
    }
    
}
