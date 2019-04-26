//
//  Extensions.swift
//  Networking
//
//  Created by Antelis on 2019/4/2.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import UIKit

var colorTables = [
UIColor(red: 138.0/256.0, green: 184.0/256.0, blue: 48.0/256.0, alpha: 1.0),
UIColor(red: 216.0/256.0, green: 222.0/256.0, blue: 164.0/256.0, alpha: 1.0),
UIColor(red: 253.0/256.0, green: 206.0/256.0, blue: 104.0/256.0, alpha: 1.0),
UIColor(red: 238.0/256.0, green: 150.0/256.0, blue: 5.0/256.0, alpha: 1.0),
UIColor(red: 250.0/256.0, green: 146.0/256.0, blue: 166.0/256.0, alpha: 1.0),
//UIColor(red: 139.0/256.0, green: 249.0/256.0, blue: 251.0/256.0, alpha: 1.0),
//UIColor(red: 249.0/256.0, green: 189.0/256.0, blue: 48.0/256.0, alpha: 1.0),
//UIColor(red: 251.0/256.0, green: 135.0/256.0, blue: 105.0/256.0, alpha: 1.0),
//UIColor(red: 236.0/256.0, green: 222.0/256.0, blue: 196.0/256.0, alpha: 1.0),
UIColor(red: 224.0/256.0, green: 230.0/256.0, blue: 230.0/256.0, alpha: 1.0)]

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
    
}
extension UIScrollView {
    func isNearBottom(edgeOffset : CGFloat = 200.0) -> Bool {
        return (self.contentSize.height - self.contentOffset.y) < (edgeOffset + self.frame.height)
    }
}
