//
//  TourDetailViewModel.swift
//  Networking
//
//  Created by Antelis on 2019/4/2.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class TourDetailViewModel {
    
    internal let disposeBag = DisposeBag()
    internal var tourId : String = ""
    convenience init(_ tid : String) {
        self.init()
        
        self.tourId = tid
    }
    // MARK: - API
    internal func getTourInfo(_ tid : String) {
        
        guard let url = URL(string:"https://www.fantasy-tours.com/FantasyAPI/gettour/\(tid)" ) else { return }
        
        URLSession.shared.rx.data(request: URLRequest(url: url)).subscribe(onNext: { data in
            if let str = String(data: data, encoding: .utf8) {
                print("gettour API :: \(str)")
            }
        }, onError: { error in
            print("gettour Error :: \(error.localizedDescription)")
        }).disposed(by: disposeBag)
    }
    internal func getTourDetail(_ tid : String) {
        
    }
    internal func getPriceList(_  tid: String) {
    }
    internal func getFlightList(_  tid: String) {
    }
    
    internal func getItineraryList(_  tid: String) {
        
    }
    
    // MARK: - JSON Decodable
    internal func decodeFlight(_ data : Data) -> [Flight]{
        do {
            //let str = String(data:data , encoding: .utf8)
            //print("JSON : \n \(str ?? "") \n")
            let result = try JSONDecoder().decode(getflightlistItem.self, from: data)
            if result.result == "SYSTEM_OK" {
                let list = result.data
                print(list.count)
                return list
            }
            
        } catch let error {
            print("JSON DECODER ERR : \(error)")
        }
        return []
    }
    
    internal func decodeItinerary(_ data : Data) -> [Itinerary]{
        do {
            //let str = String(data:data , encoding: .utf8)
            //print("JSON : \n \(str ?? "") \n")
            let result = try JSONDecoder().decode(getItinerarylistItem.self, from: data)
            if result.result == "SYSTEM_OK" {
                let list = result.data
                print(list.count)
                return list
            }
            
        } catch let error {
            print("JSON DECODER ERR : \(error)")
        }
        return []
    }
    
    internal func decodePrice(_ data : Data) -> [Price]{
        do {
            //let str = String(data:data , encoding: .utf8)
            //print("JSON : \n \(str ?? "") \n")
            let result = try JSONDecoder().decode(getpricelistItem.self, from: data)
            if result.result == "SYSTEM_OK" {
                return [result.data]
            }
            
        } catch let error {
            print("JSON DECODER ERR : \(error)")
        }
        return []
    }
    
    internal func decodeDetail(_ data : Data) -> [Detail]{
        do {
            //let str = String(data:data , encoding: .utf8)
            //print("JSON : \n \(str ?? "") \n")
            let result = try JSONDecoder().decode(getguidelistItem.self, from: data)
            if result.result == "SYSTEM_OK" {
                return result.data
            }
            
        } catch let error {
            print("JSON DECODER ERR : \(error)")
        }
        return []
    }
    
    internal func decodeTourInfo(_ data: Data) -> [TourInfo] {
        do{
            let result = try JSONDecoder().decode(gettourItem.self, from: data)
            if result.result == "SYSTEM_OK" {
                return [result.data]
            }
        } catch let error {
            print("JSON DECODER ERR : \(error)")
        }
        
        return []
    }
}

