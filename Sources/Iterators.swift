//
//  Iterators.swift
//  RRuleSwift
//
//  Created by Xin Hong on 16/3/29.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import JavaScriptCore

public struct Iterator {
    public static let endlessRecurrenceCount = 500
    internal static let rruleContext: JSContext? = {
        guard let rrulejs = JavaScriptBridge.rrulejs() else {
            return nil
        }
        let context = JSContext()
        
        let nativeLog: @convention(block) (String) -> Void = { message in
            NSLog("JS Log: \(message)")
        }
        
        context?.setObject(nativeLog, forKeyedSubscript: "nativeLog" as NSString)
        
        context?.exceptionHandler = { context, exception in
            print("[RRuleSwift] rrule.js error: \(String(describing: exception))")
        }
        let _ = context?.evaluateScript(rrulejs)
        return context
    }()
}

public extension RecurrenceRule {
    
    
    internal func iterate(_ ruleString: String, options: String, beginDate: Date, endDate: Date) -> [Date] {
        var events = [Date]()
        var ruleString = ruleString
        let jsModule = Iterator.rruleContext?.objectForKeyedSubscript("RRuleSwift")
        let jsAnalyzer = jsModule?.objectForKeyedSubscript("Iterator")
        
        let limitClause = ";COUNT=\(Iterator.endlessRecurrenceCount)"
        if recurrenceEnd == nil {
            ruleString += limitClause
        }
        
        if let result = jsAnalyzer?.objectForKeyedSubscript("iterate").call(withArguments: [ruleString, options, beginDate, endDate]) {
            events = result.toArray() as? [Date] ?? []
        }

        return events
    }
    
    func occurrences(between date: Date = .distantPast, and otherDate: Date = .distantFuture, limit endlessRecurrenceCount: Int = Iterator.endlessRecurrenceCount, timeZone: TimeZone? = nil) -> [Date] {
        guard let _ = JavaScriptBridge.rrulejs() else {
            return []
        }
        
        let options = timeZone.flatMap { "{ \"tzid\": \"\($0.identifier)\" }" } ?? "{}"
        
        return iterate(toRRuleString(), options: options, beginDate: date, endDate: otherDate)
    }
}
