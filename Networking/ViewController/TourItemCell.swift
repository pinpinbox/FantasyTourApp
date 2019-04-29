//
//  TourItemCell.swift
//  FantasyTourApp
//
//  Created by Antelis on 2019/4/26.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources


class FavouriteButton : UIView {
    
    public var isTapped : Bool = false
    private let fillView = UIImageView(image: UIImage(named: "heart_set")?.withRenderingMode(.alwaysTemplate))//UIView(frame: CGRect.zero)
    
    private var coeff:CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        
        let v = UIView(frame: fillView.frame)
        v.backgroundColor = UIColor.orange
        self.fillView.frame = self.bounds
        self.fillView.tintColor = colorTables[colorTables.count-2]
        v.frame = CGRect(x: 0, y: self.bounds.height, width:self.bounds.width , height: 0)
        fillView.mask = v
        
        
        addSubview(fillView)
    }
    func refresh() {
        
        if isTapped {
            self.coeff = 1.0
        } else {
            self.coeff = 0.0
        }
        
        UIView.animate(withDuration: 0.5) {
            if let m = self.fillView.mask {
                m.frame = CGRect(x:0, y:self.bounds.height*(1-self.coeff),width:self.bounds.width, height:self.bounds.height*self.coeff)
            }
            
        }
    }
    
    func favTapped(_ t:Bool) {
        isTapped = t
        refresh()
    }
    
}
extension Reactive where Base: FavouriteButton {
    var tapped : Binder<Bool>{
        return Binder(self.base){ btn, tapped in
            btn.favTapped(tapped)
        }
        
    }
}

class TourItemCell: UICollectionViewCell {
    
    @IBOutlet weak var tourName : UILabel?
    @IBOutlet weak var baseView : UIView?
    @IBOutlet weak var shadowView : UIView?
    @IBOutlet weak var imageView : UIImageView?
    @IBOutlet weak var datesList : UILabel?
    @IBOutlet weak var region : UILabel?
    @IBOutlet weak var price : UILabel?
    @IBOutlet weak var phone : UIButton?
    @IBOutlet weak var tourCalendar : UIButton?
    @IBOutlet weak var fav : FavouriteButton?
    
    
    private var gradient: CAGradientLayer?
    
    
    let viewModel = TourItemCellViewModel()
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        if let baseView = self.baseView, let shadowView = self.shadowView {
            baseView.clipsToBounds = true
            baseView.layer.cornerRadius = 8
            shadowView.layer.shadowOffset = CGSize(width:2, height:1)
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowRadius = 3
            shadowView.layer.shadowOpacity = 0.3
        }
        //        if let f = fav {
        //            f.filledMask = UIImageView.init(image: UIImage.init(named: "heart_set"))
        //        }
        
        bind()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    private func bind() {
        guard let t = tourName, let ds = datesList, let re = region, let pr = price, let cover = self.imageView, let f = fav else { return }
        
        //phone.addTarget(self, action: #selector(self.phoneBtnPressed(_:)), for: .touchUpInside)
        
        viewModel.tourTitle
            .asObservable()
            .bind(to: t.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.datesList
            .asObservable()
            .bind(to: ds.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.regionText
            .asObservable()
            .bind(to: re.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.priceText
            .asObservable()
            .bind(to: pr.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.coverImage
            .asObservable()
            .bind(onNext: { [unowned self] (image) in
                DispatchQueue.main.async {
                    cover.image = image
                    self.layoutCoverMask()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.isFavored
            .asObservable()
            .bind(to: f.rx.tapped).disposed(by: disposeBag)
        
        
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = true
        f.addGestureRecognizer(tap)
        
        tap.rx.event.bind(onNext: { recognizer in
            if recognizer.state == .ended {
                self.viewModel.updateFav()
            }
        }).disposed(by: disposeBag)
        
        if let tourCalendar = tourCalendar {
            
            viewModel.tourDatesVisible
                .asObservable()
                .bind(to: tourCalendar.rx.isEnabled)
                .disposed(by: disposeBag)
            
            tourCalendar.rx.tap.asObservable().bind {
                if let block = self.viewModel.tourDatesBtnBlock {
                    
                    block(self.viewModel.tid)
                }
                }.disposed(by: disposeBag)
        }
        if let phone  = self.phone {
            phone.rx.tap.asObservable().bind {
                self.viewModel.runPhoneBtnPressedBlock()
                }.disposed(by: disposeBag)
        }
    }
    func layoutCoverMask() {
        if let v = self.imageView {
            if let grd = self.gradient {
                grd.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: v.frame.height)
            } else {
                self.gradient = CAGradientLayer(layer: v.layer)
                if let grd = self.gradient {
                    grd.colors = [UIColor.white.cgColor,UIColor.clear.cgColor]
                    grd.locations = [0.5, 0.9]
                    grd.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: v.frame.height)
                    v.layer.mask = grd
                }
            }
        }
    }
    
    func showNoData() {
        guard let a = tourName else { return }
        a.text = "尚無資料"
        
    }
    func showLoading(){
        
    }
}
