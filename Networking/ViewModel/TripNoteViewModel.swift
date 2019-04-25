//
//  TripNoteViewModel.swift
//  Networking
//
//  Created by Antelis on 2019/4/24.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa


class TripNoteViewModel : TourDetailViewModel {
    
    let notelist = BehaviorRelay<[Detail]> (value: [])
    override var tourId: String  {
        didSet {
            self.getTourDetail(tourId)
        }
    }
    
    
    override internal func getTourDetail(_ tid : String) {
        
        guard let url = URL(string:"https://www.fantasy-tours.com/FantasyAPI/getguidelist/\(tid)" ) else { return }
        
        URLSession.shared.rx.data(request: URLRequest(url: url)).map(self.decodeDetail).subscribe(onNext: { (list) in
            if list.count > 0 {
                self.notelist.accept(list)
            } else {
                self.notelist.accept([])
            }
        }, onError: { error in
            print("getguidelist Error :: \(error.localizedDescription)")
        }).disposed(by: disposeBag)
    }
}
