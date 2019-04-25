//
//  ItineraryViewController.swift
//  Networking
//
//  Created by Antelis on 2019/4/22.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import WebKit

private let reuseIdentifierCell = "ItineraryCell"
private let reuseHeaderIdentitfier = "ItineraryHeader"
let dayColor = UIColor(red: 253.0/256/0 , green:206.0/256.0 , blue: 104.0/256.0, alpha: 1.0)

class iHeaderView: UICollectionReusableView {
    @IBOutlet weak var date : UILabel?
    var index : Int = 0 {
        didSet {
            self.dayNumber = "Day \(index+1)"
            addLine()
        }
    }
    
    var dayNumber : String {
        get {
            if let d = date, let t = d.text {
                return t
            }
            return ""
        }
        set {
            if let d = date {
                let w = d.frame.width
                d.text = newValue
                d.layer.cornerRadius = w/2
                d.clipsToBounds = true
                d.backgroundColor = dayColor
            }
        }
    }
    private var shape : CAShapeLayer? = nil
    private func addLine() {
        
        let p = UIBezierPath()
        let rect = CGRect(origin: CGPoint.zero, size: self.frame.size)
        p.move(to: CGPoint(x: 36, y: 0))
        if index != 0 {
            p.addLine(to: CGPoint(x:36, y: rect.height/2-24))
        }
        
        p.move(to: CGPoint(x:36, y: rect.height/2+24))
        p.addLine(to: CGPoint(x: 36, y: rect.height))
        
        if let _ = self.shape {
        } else {
            self.shape = CAShapeLayer()
            self.shape?.frame = rect
            self.layer.addSublayer(self.shape!)
        }
        
        if let shapeLayer = self.shape {
    
            shapeLayer.path = p.cgPath
            shapeLayer.strokeColor = UIColor.gray.cgColor
            shapeLayer.lineWidth = 1.0
            
            shapeLayer.frame = rect
        }
    }
    
}
class ItineraryCellView : UICollectionViewCell {
    @IBOutlet weak var tourContent: UILabel?
    @IBOutlet weak var mealContent: UILabel?
    @IBOutlet weak var liveContent: UILabel?
    //@IBOutlet weak var hotelWebview: WKWebView?
    @IBOutlet weak var infoButton : UIButton?
    
    let disposeBag = DisposeBag()
    var viewModel : itineraryCellModel? {
        didSet {
            bind()
        }
    }
    override func awakeFromNib() {
        
        bind()
        
    }
    private func addLine() {
        
        let p = UIBezierPath()
        let rect = CGRect(origin: CGPoint.zero, size: self.frame.size)
        p.move(to: CGPoint(x: 36, y: 0))
        p.addLine(to: CGPoint(x: 36, y: rect.height))
        let shape = CAShapeLayer()
        shape.frame = rect
        self.layer.addSublayer(shape)
        shape.path = p.cgPath
        
        shape.strokeColor = UIColor.gray.cgColor
        shape.lineWidth = 1.0
            
        shape.frame = rect
        
    }
    private func bind() {
        addLine()
        
        guard let t = tourContent,
            let m = mealContent,
            let l = liveContent, let i = infoButton else { return }
        
        i.rx.tap.subscribe(onNext: { [unowned self] in
            if let v = self.viewModel {
                v.showInfo()
            }
        }).disposed(by: disposeBag)
        
        viewModel?.walkTitle
            .asObservable()
            .bind(to: t.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.mealInfo
            .asObservable()
            .bind(to: m.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.liveTitle
            .asObservable()
            .bind(to: l.rx.text)
            .disposed(by: disposeBag)
        
//        viewModel?.liveTitle
//            .asObservable()
//            .subscribe(onNext: { (title) in
//                let s = "<html><body>\(title)</body></html>"
//                w.loadHTMLString(s, baseURL: nil)
//            }).disposed(by: disposeBag)
        
    }
    
    @IBAction func showContent(_ sender: Any?) {
        
    }
    
}
protocol InfoProtocol {
    func showItineraryInfo(_ source: String)
}
class ItineraryViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, InfoProtocol {

    @IBOutlet weak var itineraryList: UICollectionView?
    
    
    let viewModel = ItineraryViewModel()
    let disposeBag = DisposeBag()
    
    
    
    
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<ItinerarySectionModel>(
        configureCell:configureCell, configureSupplementaryView: {(source, collectionView, name, indexPath) -> UICollectionReusableView in
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentitfier, for: indexPath)
        
        if let h = header as? iHeaderView, let d = h.date {
            h.index = indexPath.section
            let c = colorTables[h.index%5]
            d.backgroundColor = c
            
        }
        return header
    })

    private lazy var configureCell: RxCollectionViewSectionedReloadDataSource<ItinerarySectionModel>.ConfigureCell = { [weak self] (source, collectionView, indexPath, itinerary) in
        guard let strongSelf = self else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:reuseIdentifierCell , for: indexPath)
        if let c = cell as? ItineraryCellView {
            c.viewModel = itineraryCellModel(itinerary, strongSelf)
            
        }
        return cell
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
    }
    
    
    private func bind() {

        if let i = itineraryList {
            
            viewModel.ItineraryCells
                .asObservable()
                .bind(to: i.rx.items(dataSource: dataSource))
                .disposed(by: disposeBag)
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let w = UIScreen.main.bounds.width
        return CGSize(width: w, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = UIScreen.main.bounds.width
        return CGSize(width: w, height: 340)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func showItineraryInfo(_ source : String) {
        let w = WKWebView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
        w.loadHTMLString(source, baseURL: nil)
        //        let alert = UIAlertController()
        
        let p = PhoneListViewController()
        p.showWebView(w)
        self.present(p, animated: true, completion: nil)
    }
}
