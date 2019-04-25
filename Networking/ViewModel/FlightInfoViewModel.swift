//
//  FlightInfoViewModel.swift
//  Networking
//
//  Created by Antelis on 2019/4/19.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//var depColor = UIColor(red: CGFloat(115.0/256.0), green: CGFloat(186.0/256.0), blue: CGFloat(234.0/256.0), alpha: 1.0)
//var arrColor = UIColor(red: CGFloat(245.0/256.0), green: CGFloat(112.0/256.0), blue: CGFloat(149/256.0), alpha: 1.0)
//var errColor = UIColor(red: CGFloat(180.0/256.0), green: CGFloat(195.0/256.0), blue: CGFloat(213/256.0), alpha: 1.0)

enum FlightInfoCellType {
    case normal(cellViewModel: FlightInfoCellViewModel)
    case error(message: String)
    case empty
}

class FlightInfoCellViewModel : NSObject {
    
    let codeName = BehaviorRelay<String>(value: "")
    let departureText = BehaviorRelay<NSAttributedString>(value: NSAttributedString(string: ""))
    let arrivalText = BehaviorRelay<NSAttributedString>(value: NSAttributedString(string: ""))
    let airLiner = BehaviorRelay<UIImage?>(value: nil)
    let backgroundColor = BehaviorRelay<UIColor>(value: UIColor.white)
    
    init(_ flight : Flight) {
        super.init()
        let airline =  flight.name.trimmingCharacters(in : .whitespaces)
        codeName.accept(airline+" "+flight.number)
        if flight.voyage == "go" {
            backgroundColor.accept(colorTables[0])//depColor)
        } else {
            backgroundColor.accept(colorTables[1])//arrColor)
        }
        
        weaveDeparture(flight)
        weaveArrival(flight)
    }
    func updateFlight(_ flight : Flight) {
        let airline =  flight.name.trimmingCharacters(in : .whitespaces)
        codeName.accept(airline+" "+flight.number)
        if flight.voyage == "go" {
            backgroundColor.accept(colorTables[0])//depColor)
        } else {
            backgroundColor.accept(colorTables[1])//arrColor)
        }
    }
    
    private func weaveArrival(_ flight: Flight){
        let par = NSMutableParagraphStyle()
        par.alignment = .right
        par.lineBreakMode = .byWordWrapping
        
        let part1 = NSMutableAttributedString(string: flight.arrival_time.findDate()+"\n", attributes: [.font: UIFont(name: "HelveticaNeue-Bold", size: 14)!, .paragraphStyle: par, .foregroundColor: UIColor.white])
        let part2 = NSMutableAttributedString(string: flight.arrival_location+"\n", attributes: [.font:UIFont(name: "HelveticaNeue-Bold", size: 22)!, .paragraphStyle: par, .foregroundColor: UIColor.white])
        let part4 = NSMutableAttributedString(string: flight.arrival_time.findTime(), attributes: [.font:UIFont(name: "HelveticaNeue-Bold", size: 16)!, .paragraphStyle: par, .foregroundColor: UIColor.white])
        let total = NSMutableAttributedString()
        total.append(part1)
        total.append(part2)
        total.append(part4)
        
        arrivalText.accept(total)
    }
    private func weaveDeparture(_ flight: Flight) {
        let par = NSMutableParagraphStyle()
        par.alignment = .left
        par.lineBreakMode = .byWordWrapping
        
        let part1 = NSMutableAttributedString(string: flight.departure_time.findDate()+"\n", attributes: [.font: UIFont(name: "HelveticaNeue-Bold", size: 14)!,.paragraphStyle: par, .foregroundColor: UIColor.white])
        let part2 = NSMutableAttributedString(string: flight.departure_location+"\n", attributes: [.font:UIFont(name: "HelveticaNeue-Bold", size: 22)!,.paragraphStyle: par, .foregroundColor: UIColor.white])
        let part4 = NSMutableAttributedString(string: flight.departure_time.findTime(), attributes: [.font:UIFont(name: "HelveticaNeue-Bold", size: 16)!,.paragraphStyle: par, .foregroundColor: UIColor.white])
        let total = NSMutableAttributedString()
        total.append(part1)
        total.append(part2)
        total.append(part4)
        departureText.accept(total)
        
    }
}
class FlightInfoViewModel : TourDetailViewModel {
    
    var flightCells: Observable<[FlightInfoCellType]> {
        return cells.asObservable()
    }
    
    let viewWillAppear = PublishRelay<Bool>()
    let viewWillDisappear = PublishRelay<Bool>()
    
    let errors = PublishRelay<Error>()
    var flightList = BehaviorRelay<[Flight]> (value: [])
    
    override var tourId: String  {
        didSet {
            self.getFlightList(self.tourId)
        }
    }
    
    private let cells = BehaviorRelay<[FlightInfoCellType]>(value: [])
    
    convenience init(_ tid : String) {
        self.init()
        self.tourId = tid
        self.viewWillAppear.subscribe(onNext: { (animated) in
        }).disposed(by: disposeBag)
        
        self.viewWillDisappear.subscribe(onNext: { (animated) in
        }).disposed(by: disposeBag)
        
        
        self.flightList.asObservable().subscribe(onNext: { [weak self] (flights) in
        
            guard flights.count > 0 else {
                self?.cells.accept([.empty])
                return
            }
            
            self?.cells.accept(flights.compactMap {.normal(cellViewModel: FlightInfoCellViewModel($0))})
        },
        onError: { [weak self] error in
            self?.cells.accept([.error(message: "Unable to load")])
        }).disposed(by: disposeBag)
    }
    internal override func getFlightList(_  tid: String) {
        guard let url = URL(string: "https://www.fantasy-tours.com/FantasyAPI/getflightlist/\(tid)" ) else { return }
        URLSession.shared.rx.data(request: URLRequest(url:url)).map(self.decodeFlight).subscribe(onNext: { (flights) in
            
            self.flightList.accept(flights)
            if flights.count < 1 {
                self.cells.accept([.empty])
            } else {
                self.cells.accept(flights.compactMap {.normal(cellViewModel: FlightInfoCellViewModel($0))})
            }
            
        }).disposed(by: disposeBag)
    }
    
}
