//
//  ItineraryViewModel.swift
//  Networking
//
//  Created by Antelis on 2019/4/22.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


//enum ItinerarySectionType {
//    case normal(sectionModel: ItinerarySectionModel)
//    case error(message: String)
//    case empty
//}

struct ItinerarySectionModel {
    var section : String = ""
    var index : Int = 0 {
        didSet {
            section = "Day\(index+1))"
        }
    }
    var walk : Walk?
    var live: Live?
    var eat : Eat?
    var items: [Itinerary] = [] {
        didSet {
            if let i = items.first {
                walk = i.walk
                live = i.live
                eat = i.eat
            }
        }
    }
    

}
extension ItinerarySectionModel : SectionModelType {
    typealias Item = Itinerary
    
    init(original: ItinerarySectionModel, items: [Item]) {
        
        self = original
        self.items = items
    }
}
class itineraryCellModel : NSObject {

    let walkTitle = BehaviorRelay<String>(value: "")
    let walkContent =  BehaviorRelay<String>(value: "")
    let liveTitle = BehaviorRelay<String>(value: "")
    let liveContent =  BehaviorRelay<String>(value: "")
    let mealInfo = BehaviorRelay<String>(value: "")
    var itineraryInfo : InfoProtocol?
    
    convenience init(_ tour : Itinerary,_ info : InfoProtocol) {
        self.init(tour)
        self.itineraryInfo = info
    }
    
    init(_ tour : Itinerary) {
        super.init()
        walkTitle.accept(tour.walk.title)
        walkContent.accept(tour.walk.innertext)
        // consider : https://github.com/scinfu/SwiftSoup
        do {
            let regex:NSRegularExpression  = try NSRegularExpression(  pattern: "<.*?>", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, tour.live.title.count)
            let htmlLessString :String = regex.stringByReplacingMatches(in: tour.live.title, options: NSRegularExpression.MatchingOptions(), range:range , withTemplate: "")
            liveTitle.accept(htmlLessString)
            
        } catch {
            liveTitle.accept(tour.live.title)
        }
        
        do {
            let regex:NSRegularExpression  = try NSRegularExpression(  pattern: "<.*?>", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, tour.live.innertext.count)
            let htmlLessString :String = regex.stringByReplacingMatches(in: tour.live.innertext, options: NSRegularExpression.MatchingOptions(), range:range , withTemplate: "")
            liveContent.accept(htmlLessString)
            
        } catch {
            
            liveContent.accept(tour.live.innertext)
        }
        
        mealInfo.accept("早："+tour.eat.breakfast+"\n中："+tour.eat.lunch+"\n晚："+tour.eat.dinner)
    }
    
    func showInfo() {
        if let p = self.itineraryInfo {
            p.showItineraryInfo(walkContent.value)
        }
    }
    
}
class ItineraryViewModel : TourDetailViewModel {

    var ItineraryCells : Observable<[ItinerarySectionModel]> {
        return cells.asObservable()
    }
    
    let viewWillAppear = PublishRelay<Bool>()
    let viewWillDisappear = PublishRelay<Bool>()
    
    let errors = PublishRelay<Error>()
    var ItineraryList = BehaviorRelay<[Itinerary]>(value: [])
    
    override var tourId: String  {
        didSet {
            self.getItineraryList(tourId)
        }
    }
    
    private let cells = BehaviorRelay<[ItinerarySectionModel]>(value: [])
    
    convenience init(_ tid : String) {
        self.init()
        self.tourId = tid
        self.viewWillAppear.subscribe(onNext: { (animated) in
        }).disposed(by: disposeBag)
        
        self.viewWillDisappear.subscribe(onNext: { (animated) in
        }).disposed(by: disposeBag)
        
    }
    internal override func getItineraryList(_ tid: String) {
        
        guard let url = URL(string: "https://www.fantasy-tours.com/FantasyAPI/getdailylist/\(tid)" ) else { return }
        URLSession.shared.rx.data(request: URLRequest(url:url)).map(self.decodeItinerary).subscribe(onNext: {(list) in
            self.ItineraryList.accept(list)
            if list.count < 1 {
                self.cells.accept([])
            } else {
                //self.cells.accept(list.compactMap{.normal(sectionModel: ItinerarySectionModel(original: $0, items: list.firstIndex(of: $0) ?? 0))})
                var i = 0
                var va = Array<ItinerarySectionModel>()
                list.forEach({ (itinerary) in
                    let v = //ItinerarySectionModel(original:ItinerarySectionModel() , items: [itinerary])
                        ItinerarySectionModel(section: "Day\(i+1)", index:i+1 , walk: nil, live: nil, eat: nil, items: [itinerary])
                    va.append(v)
                    i = i+1
                })
                self.cells.accept(va)
                
            }
            
            
        }, onError: { error in
            print("getdailylist Error :: \(error.localizedDescription)")
        }).disposed(by: disposeBag)
        
    }
}

