//
//  TourItemCellViewModel.swift
//  FantasyTourApp
//
//  Created by Antelis on 2019/4/26.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage


//MARK:- ViewModel for TourItemCell -
class TourItemCellViewModel {
    
    private let disposeBag = DisposeBag()
    
    let tourTitle = BehaviorRelay<String>(value: "")
    let datesList = BehaviorRelay<String>(value: "")
    let regionText = BehaviorRelay<String>(value: "")
    let priceText = BehaviorRelay<String>(value: "")
    let coverImage = BehaviorRelay<UIImage?>(value: nil)
    let isFavored = BehaviorRelay<Bool>(value: false)
    let tourDatesVisible = BehaviorRelay<Bool>(value: true)
    
    
    var phoneBtnPressedBlock : (() -> Void)?
    var favRemovedBlock: (() -> Void)?
    var tourDatesBtnBlock: ((_ tour_id : String) -> Void)?
    
    var tid = String()
    var guidestr = String()
    var dates = Array<Date>()
    
    func runPhoneBtnPressedBlock() {
        if let phoneBtnPressedBlock = phoneBtnPressedBlock {
            phoneBtnPressedBlock()
        }
    }
    func updateFav() {
        
        let i = !(self.isFavored.value)
        if i {
            FavListManager.addToFavourite(self.tid, guidestr)
        } else {
            print("delete res \(FavListManager.deleteFavItemWithKey(self.tid))")
            if let favRemovedBlock = favRemovedBlock {
                favRemovedBlock()
            }
        }
        self.isFavored.accept(i)
    }
    func updateTour(_ tour: Tour) {
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(tour)
            if let ss = String(data: jsonData, encoding: .utf8) {
                guidestr = ss
            } else {
                guidestr = ""
            }
        } catch {
            guidestr = ""
        }
        
        self.tid = tour.tour.tour_id
        self.tourTitle.accept(tour.tour.title)
        self.datesList.accept(tour.tour.dates)
        self.regionText.accept(tour.tour.area)
        self.isFavored.accept(FavListManager.isInFavList(tour.tour.tour_id))
        self.tourDatesVisible.accept((tour.tour.dateList.count > 0))
        self.dates.append(contentsOf: tour.tour.dateList)
        if tour.tour.hide_price {
            self.priceText.accept("\(tour.tour.days)天 / \(tour.tour.hide_price_title)")
        } else {
            let format = NumberFormatter()
            format.numberStyle = .currency
            
            format.minimumFractionDigits = 0
            if let s = format.string(from: NSNumber(value: tour.tour.price)) {
                self.priceText.accept("\(tour.tour.days)天 / NTD" + s + " 起")//String(guide.tour.price)
            } else {
                self.priceText.accept("\(tour.tour.days)天 / 電洽")
            }
        }
        let url = tour.tour.cover
        self.coverImage.accept(nil)
        
        let imageDownloader = SDWebImageManager()
        imageDownloader.loadImage(with: url, options: [], progress: nil) { (image, data, error, _, _, _) in
            if let image = image {
                self.coverImage.accept(image)
            }
        }
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let data = data,
//                let image = UIImage(data: data) {
//                self.coverImage.accept(image)
//            }
//
//        }
//
//        task.resume()
        
        
        
    }
    
    
}
