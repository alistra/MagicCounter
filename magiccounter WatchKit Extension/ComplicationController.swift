//
//  ComplicationController.swift
//  magiccounter WatchKit Extension
//
//  Created by Aleksander Balicki on 10/02/2019.
//  Copyright © 2019 Alistra. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        let template: CLKComplicationTemplate
        let state = CounterController.shared.currentGameHistory.currentState

        switch complication.family {
        case .graphicCorner:
            
            
            let gaugeTemplate = CLKComplicationTemplateGraphicCornerGaugeText()
            gaugeTemplate.leadingTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: String(state.myLife))
            gaugeTemplate.trailingTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: String(state.opponentLife))
            
            let fraction = Float(state.myLife) / Float(state.myLife + state.opponentLife)
            
            let gaugeProvider = CLKSimpleGaugeProvider(style: .ring,
                                                       gaugeColors: [.green, .orange],
                                                       gaugeColorLocations: [0, NSNumber(value: fraction)],
                                                       fillFraction: fraction)
            gaugeTemplate.gaugeProvider = gaugeProvider
            gaugeTemplate.outerTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: "LIFE")
            template = gaugeTemplate
            
        case .modularSmall:
            let simpleTextTemplate = CLKComplicationTemplateModularSmallSimpleText()
            simpleTextTemplate.textProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: "\(state.myLife)/\(state.opponentLife)")
            template = simpleTextTemplate
            
        default:
            handler(nil)
            return
        }
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        
        let template: CLKComplicationTemplate
        let state = Game(myLife: 20, opponentLife: 20)
        
        switch complication.family {
        case .graphicCorner:
            
            let gaugeTemplate = CLKComplicationTemplateGraphicCornerGaugeText()
            gaugeTemplate.leadingTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: String(state.myLife))
            gaugeTemplate.trailingTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: String(state.opponentLife))
            
            let fraction = Float(state.myLife) / Float(state.myLife + state.opponentLife)
            
            let gaugeProvider = CLKSimpleGaugeProvider(style: .ring,
                                                       gaugeColors: [.green, .orange],
                                                       gaugeColorLocations: [0, NSNumber(value: fraction)],
                                                       fillFraction: fraction)
            gaugeTemplate.gaugeProvider = gaugeProvider
            gaugeTemplate.outerTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: "LIFE")
            template = gaugeTemplate
            
        case .modularSmall:
            let simpleTextTemplate = CLKComplicationTemplateModularSmallSimpleText()
            simpleTextTemplate.textProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: "\(state.myLife)/\(state.opponentLife)")
            template = simpleTextTemplate
            
        default:
            handler(nil)
            return
        }
        
        handler(template)
    }
    
}
