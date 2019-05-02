//
//  FavListViewModel.swift
//  FantasyTourApp
//
//  Created by Antelis on 2019/4/25.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FavListViewModel: TourListViewModel {
    
    //MARK: API
    override func retrieveList(_ listType:TourListType) {
        let list = FavListManager.getFavList()
        var tlist = Array<Tour>()
        
        list.forEach { (item) in
            let json = item.json
            if json.count > 1, let data = json.data(using: .utf8) {
                let t = self.decode(data)
                tlist.append(contentsOf: t)
            }
        }
        
        self.guideList.accept(tlist)
        
    }
    override func decode(_ data: Data) -> [Tour] {
        do {
            //let str = String(data:data , encoding: .utf8)
            //print("JSON : \n \(str ?? "") \n")
            let result = try JSONDecoder().decode(Tour.self, from: data)
            return [result]
            
        } catch let error {
            print("JSON DECODER ERR : \(error)")
        }
        return []
    }
    func removeFavItemAt(_ index: Int) {
        
        var r2 = Array(self.guideList.value)
        if index < r2.count {
            r2.remove(at: index)
            self.guideList.accept(r2)
        }
        
        
    }
    
}
