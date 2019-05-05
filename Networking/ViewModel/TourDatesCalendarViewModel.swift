//
//  TourDatesCalendarViewModel.swift
//  FantasyTourApp
//
//  Created by Antelis on 2019/4/26.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class TourDatesCalendarViewModel: CalendarViewDataSource, CalendarViewDelegate {
    
    private var last : Int = 0
    
    private let disposeBag = DisposeBag()
    
    let listCount = BehaviorRelay(value: 0)
    let dateDetail = BehaviorRelay<String>(value: "")
    
    var dateList = BehaviorRelay<[DateDetail]> (value: [])
    
    var tour_id = String()  {
        didSet {
            self.retrieveDateDetailList(self.tour_id)
        }
    }
    
    lazy var currencyFormatter : NumberFormatter = {
        let format = NumberFormatter()
        format.numberStyle = .currency
        format.minimumFractionDigits = 0
        return format
    }()
    
    //MARK: API
    func retrieveDateDetailList(_ tour_id:String) {
        
        let count = (listCount.value - last > 0) ? listCount.value - last : 15
        
        let l0 = last
        last = listCount.value
        guard count > 0, let url = URL(string:"https://www.fantasy-tours.com/FantasyAPI/getdatelist?limit=\(l0),\(count)&tour_id=\(tour_id)" ) else { return } //Observable.just([]) }
        
        URLSession.shared.rx.data(request: URLRequest(url: url)).map(self.decode).subscribe(onNext: { (items) in
            let c = self.listCount.value
            self.listCount.accept(c+items.count)
            print("listCount \(self.listCount.value)")
            self.dateList.accept(self.dateList.value + items)
        }).disposed(by: disposeBag)
        
    }
    
    // MARK: JSON Decoding
    func decode(_ data : Data) -> [DateDetail]{
        do {
            
            let result = try JSONDecoder().decode(getdatelistItem.self, from: data)
            if result.result == "SYSTEM_OK" {
                var list = result.data
                list.sort { (dt1, dt2) -> Bool in
                    if let d1 =  dt1.date.simpleDate(), let d2 = dt2.date.simpleDate() {
                        let r = d1.compare(d2)
                        if r == .orderedAscending {
                            return true
                        }
                        return false
                        
                    }
                    
                    return false
    
                }
                print(list.count)
                return list
            }
            
        } catch let error {
            print("JSON DECODER ERR : \(error)")
        }
        return []
    }
    
    
    func startDate() -> Date {
        if let d = dateList.value.first, let date = d.date.simpleDate() {
            return date.firstDayOfMonth()
        }
        return Date()
    }
    
    func endDate() -> Date {
        if let d = dateList.value.last, let date = d.date.simpleDate() {
            return date.lastDayOfMonth()
        }
        return Date()
    }
    
    func preloadEvents() -> Array<CalendarEvent> {
        var days = Array<CalendarEvent>()
        var i = 0
        dateList.value.forEach { (d) in
            if let date = d.date.simpleDate() {
                
                let e = CalendarEvent(title:"\(i)", startDate: date, endDate: date)
                days.append(e)
                
            }
            i = i+1
        }
        
        return days
    }
    
    func calendar(_ calendar: CalendarView, didSelectDate date: Date, withEvents events: [CalendarEvent]) {
        
        if let e = events.first {
            if let i = Int(e.title) {
                let detail = self.dateList.value[i]
                if detail.hide_price {
                    self.dateDetail.accept(detail.hide_price_title)
                } else {
                    if let ss = self.currencyFormatter.string(from: NSNumber(value: detail.price)) {
                        self.dateDetail.accept("價格：NTD\(ss)")
                    } else {
                        self.dateDetail.accept("")
                    }
                }
                
            } else {
                self.dateDetail.accept("")
            }
        }
    }
    func calendar(_ calendar : CalendarView, didScrollToMonth date : Date) {
        
    }
    
    func calendar(_ calendar : CalendarView, canSelectDate date : Date) -> Bool {
        return true
    }
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) {
        
    }
    func calendar(_ calendar : CalendarView, didLongPressDate date : Date) {
        
    }
}
