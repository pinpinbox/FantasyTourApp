//
//  TourDatesCalendarViewController.swift
//  FantasyTourApp
//
//  Created by Antelis on 2019/4/26.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TourDatesCalendarViewController: UIViewController {
    
    @IBOutlet weak var calendar : CalendarView?
    @IBOutlet weak var shadow : UIView?
    @IBOutlet weak var detailLabel : UILabel?

    private let disposeBag = DisposeBag()

    var viewModel = TourDatesCalendarViewModel()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .overFullScreen
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overFullScreen
        bind()
        setupCalendarStyle()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func bind() {
        viewModel.dateList.asObservable().subscribe(onNext: { (list) in
            if let calendar = self.calendar, list.count > 0{
                
                calendar.calendar.timeZone = TimeZone.current
                
                calendar.dataSource = self.viewModel
                calendar.delegate = self.viewModel
                DispatchQueue.main.async {
                    calendar.reloadData()
                }
                
            }
        }).disposed(by: disposeBag)
        
        
        if let d = self.detailLabel {
            viewModel.dateDetail
                .asObservable()
                .bind(to: d.rx.text)
                .disposed(by: disposeBag)
        }
    }
    
   
    private func setupCalendarStyle() {
        
        CalendarView.Style.cellShape                = .bevel(8.0)
        CalendarView.Style.cellColorDefault         = UIColor.clear
        CalendarView.Style.cellColorToday           = UIColor(red:1.00, green:0.84, blue:0.64, alpha:1.00)
        CalendarView.Style.cellSelectedBorderColor  = UIColor.clear//UIColor(red:1.00, green:0.63, blue:0.24, alpha:1.00)
        CalendarView.Style.cellEventColor           = colorTables[4]
        CalendarView.Style.cellTextColorWeekend     = colorTables[3]
        CalendarView.Style.headerTextColor          = UIColor.white
        CalendarView.Style.cellTextColorDefault     = UIColor.white
        CalendarView.Style.cellTextColorToday       = UIColor(red:0.31, green:0.44, blue:0.47, alpha:1.00)
        //CalendarView.Style.loc //ca = Locale(identifier: "zh_TW")
        
        
        if let calendar = self.calendar {
            //calendar.dataSource = self.viewModel
            calendar.direction = .horizontal
        }
        
        self.view.backgroundColor = UIColor.clear
        setupBackgroundView()
    }
    
    private func setupBackgroundView() {
        
        let backgroundview = UIView(frame: self.view.frame)
        backgroundview.backgroundColor = UIColor.gray
        backgroundview.alpha = 0.7
        view.addSubview(backgroundview)
        view.sendSubviewToBack(backgroundview)
        let top = NSLayoutConstraint(item: backgroundview,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: view,
                                     attribute: .top,
                                     multiplier:1.0,
                                     constant: 0)
        
        let left = NSLayoutConstraint(item: backgroundview,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let right = NSLayoutConstraint(item: view,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: backgroundview,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        let bottom = NSLayoutConstraint(item:backgroundview,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: bottomLayoutGuide,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        
        view.addConstraints([top, left, right, bottom])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TourDatesCalendarViewController.tapAction(_ :)))
        tap.cancelsTouchesInView = false
        backgroundview.addGestureRecognizer(tap)
        
        if let shadow = self.shadow {
            shadow.layer.shadowOffset = CGSize(width:2, height:1)
            shadow.layer.shadowColor = UIColor.black.cgColor
            shadow.layer.shadowRadius = 8
            shadow.layer.shadowOpacity = 0.5
        }
    }
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

}
