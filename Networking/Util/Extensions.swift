//
//  Extensions.swift
//  Networking
//
//  Created by Antelis on 2019/4/2.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import UIKit

let color0 = UIColor(red: 238/256.0, green: 150/256.0, blue: 5/256.0, alpha: 1.0)
let color1 = UIColor(red: 255.0/256.0, green: 105.0/256.0, blue: 135.0/256.0, alpha: 1.0)
let color2 = UIColor(red: 253/256.0, green: 206/256.0, blue: 104/256.0, alpha: 1.0)
let invalidColor = UIColor(red: 112.0/256.0, green: 115.0/256.0, blue: 115.0/256.0, alpha: 1.0)

extension String {
    static let simpleDateformat = DateFormatter()
    static let datetime = DateFormatter()
    func simpleDate() -> Date? {
        String.simpleDateformat.dateFormat = "yyyy-MM-dd"
        return String.simpleDateformat.date(from: self)
    }
    func findDate() -> String {
        String.datetime.dateFormat = "yyyy/MM/dd HH:mm:00"
        
        if let d = String.datetime.date(from: self) {
            String.datetime.dateFormat = "yyyy/MM/dd"
            return String.datetime.string(from: d)
        }
        
        return ""
    }
    func findTime() -> String {
        String.datetime.dateFormat = "yyyy/MM/dd HH:mm:00"
        
        if let d = String.datetime.date(from: self) {
            String.datetime.dateFormat = "HH:mm"
            return String.datetime.string(from: d)
        }
        
        return ""
    }
    func dateList() -> Array<String> {
        if self.contains(",") {
            let nr = self.components(separatedBy: ",")
            return nr
        } else {
        
            let nr = self.components(separatedBy: "，")
            return nr
        }
        
    }
}
extension Date {
    static let simpleDateformat = DateFormatter()
    
    func simpleDateString() -> String? {
        Date.simpleDateformat.dateFormat = "yyyy-MM-dd"
        return Date.simpleDateformat.string(from: self)
    }
    
    func lastDayOfMonth() -> Date {
        let calendar = Calendar.current
        let dayRange = calendar.range(of: .day, in: .month, for: self)
        let dayCount = dayRange!.count
        var comp = calendar.dateComponents([.year, .month, .day], from: self)
        
        comp.day = dayCount
        
        return calendar.date(from: comp)!
    }
    
    func firstDayOfMonth() -> Date {
        let calendar: Calendar = Calendar.current
        var components: DateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        components.setValue(1, for: .day)
        return calendar.date(from: components)!
    }
}
extension UIScrollView {
    func isNearBottom(edgeOffset : CGFloat = 200.0) -> Bool {
        return (self.contentSize.height - self.contentOffset.y) < (edgeOffset + self.frame.height)
    }
}
