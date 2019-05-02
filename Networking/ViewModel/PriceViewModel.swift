//
//  PriceViewModel.swift
//  Networking
//
//  Created by Antelis on 2019/4/23.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources


class DetailCellModel : NSObject {
    
    let texttag = BehaviorRelay<String>(value: "")
    let texttitle = BehaviorRelay<String>(value: "")
    
    init(_ detail : Detail) {
        super.init()
        update(detail)
    }

    func update(_ detail : Detail) {
        
        texttag.accept(detail.innertext)
        texttitle.accept(detail.formattedTitle)
    }
}
class PriceViewModel : TourDetailViewModel {
    
    let pricelist = BehaviorRelay<[Detail]> (value: [])
    override var tourId: String  {
        didSet {
            self.getPriceList(tourId)
        }
    }
    
    
    internal override func getPriceList(_  tid: String) {
        guard let url = URL(string: "https://www.fantasy-tours.com/FantasyAPI/getpricelist/\(tid)" ) else { return }
        
        URLSession.shared.rx.data(request: URLRequest(url:url)).map(self.decodePrice).subscribe(onNext: {(list) in
            if list.count > 0 , let p = list.first{
                let taglist = p.priceTags
                self.pricelist.accept(taglist)
            } else {
                self.pricelist.accept([])
            }
            
        }, onError: { error in
            print("getPricelist Error :: \(error.localizedDescription)")
        }).disposed(by: disposeBag)

        
    }
}
