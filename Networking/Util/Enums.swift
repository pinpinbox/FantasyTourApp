//
//  Enums.swift
//  Networking
//
//  Created by Antelis on 2019/4/2.
//  Copyright © 2019 . All rights reserved.
//

import Foundation

enum TourListType : String, CaseIterable, Equatable {
    case latest = "getlatestlist"
    case highest = "gethighestrevenuelist"
    case mostpopular = "getmostpeoplelist"
    case fav = "fav"
    
    func indexOf() -> Int {
        switch self {
            case .latest : return 0
            case .highest : return 1
            case .mostpopular : return 2
            case .fav : return 3
        }
        
    }
    
}

enum NetworkError {
    case offline
    case networkError
}
