//
//  TourListModel.swift
//  Networking
//
//  Created by Antelis on 2019/3/29.
//  Copyright © 2019 . All rights reserved.
//

import Foundation

//MARK:  Tour List
struct getlatestlistItem : Decodable {
    let result : String
    let data : Array<Tour>
}

struct Tour : Codable {
    let tour : Guide
}

struct Guide : Codable {
    let area : String
    let cover : URL
    let date_go : String
    let date_return : String
    let dates : String
    let days : Int
    let hide_price : Bool
    let hide_price_title : String
    let price : Int
    let title : String
    let tour_id : String
    
    var dateList : Array<Date> {
        get {
            var datess : Array<Date> = []
                let datesl = self.dates.dateList()
            datesl.forEach { (dateStr) in
                if let d = dateStr.simpleDate() {
                    datess.append(d)
                }
            }
            return datess
        }
    }
    
    
    func debugStr() -> String {
        return "...DEBUG..."
    }
    
}

//MARK: Flight
struct getflightlistItem : Decodable {
    let result : String
    let data : Array<Flight>
}
struct Flight : Decodable {
    let `case`: String
    let name: String
    let voyage: String
    let number: String
    let departure_time: String//"2019/06/13 06:30",
    let departure_location: String
    let arrival_time: String //"2019/06/13 10:10",
    let arrival_location: String
    let icon: URL //"https://www.fantasy-tours.com/Content/Images/Upload/AirLine/20130422105302557.png"
    
}

//MARK: Itinerary
struct getItinerarylistItem: Decodable {
    let result : String
    let data : Array<Itinerary>
}
struct Itinerary : Decodable,Equatable {
    static func == (lhs: Itinerary, rhs: Itinerary) -> Bool {
        return lhs.walk.title == rhs.walk.title
    }
    
    let eat : Eat
    let walk: Walk
    let live : Live
}
struct Eat : Decodable {
    let breakfast: String
    let lunch: String
    let dinner: String
}
struct Walk : Decodable {
    let title: String
    let innertext: String
}
struct Live: Decodable {
    let title : String
    let innertext: String
}
//MARK: Info
struct gettourItem: Decodable {
    let result : String
    let data : TourInfo
}
struct TourInfo: Decodable {
    let area : String
    let cover : URL
    let background : URL
    let date_go : String
    let date_return : String
    let days : Int
    let hide_price : Bool
    let hide_price_title : String
    let price : Int
    let title : String
    let tour_id : String
    
}
//MARK: Detail
struct getguidelistItem: Decodable {
    let result : String
    let data : Array<Detail>
}
struct Detail:Decodable  {
    let title : String
    let innertext: String
    
    var formattedTitle: String {
        get {
            return "\(title)："
        }
    }
}

//MARK: Price
struct getpricelistItem: Decodable {
    let result : String
    let data : Price
}
struct Price : Decodable {
    
    let adult : Int
    let child_with_bed: Int
    let child_without_bed: Int
    let deposit: Int
    let extra_bed: Int
    let baby: Int
    let tax: String
    let tip: String
    let visa: String
    
    
    var priceTags : [Detail] {
        get {
            var list = Array<Detail>()
            let format = NumberFormatter()
            format.numberStyle = .currency
            format.minimumFractionDigits = 0
            
            list.append(Detail(title: "大人" , innertext: "NTD"+(format.string(from: NSNumber(value: adult)) ?? "\(adult)")))
            list.append(Detail(title: "小孩佔床" , innertext:  "NTD"+(format.string(from: NSNumber(value: child_with_bed)) ?? "\(child_with_bed)")))
            list.append(Detail(title: "小孩不佔床" , innertext:  "NTD"+(format.string(from: NSNumber(value: child_without_bed)) ?? "\(child_without_bed)")))
            list.append(Detail(title: "訂金" , innertext:  "NTD"+(format.string(from: NSNumber(value: deposit)) ?? "\(deposit)")))
            if baby <= 0 {
                list.append(Detail(title: "嬰兒" , innertext: "電洽"))
            } else {
                list.append(Detail(title: "嬰兒" , innertext:  "NTD"+(format.string(from: NSNumber(value: baby)) ?? "\(baby)")))
            }
            list.append(Detail(title: "税" , innertext: tax))
            list.append(Detail(title: "小費" , innertext: tip))
            list.append(Detail(title: "簽證" , innertext: visa))
            return list
        }
    }
}
