//
//  TourDetailPageViewController.swift
//  Networking
//
//  Created by Antelis on 2019/4/16.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import SDWebImage

internal class DetailHeaderView : UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var datesLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    init() {
        super.init(frame: CGRect.zero)
        
        Bundle(for: DetailHeaderView.self).loadNibNamed("DetailHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.backgroundColor = .white
        
        let top = NSLayoutConstraint(item: contentView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)
        
        let left = NSLayoutConstraint(item: contentView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: self,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let bottom = NSLayoutConstraint (item: self,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: contentView,
                                         attribute: .bottom,
                                         multiplier: 1.0,
                                         constant: 0.0)
        
        let right = NSLayoutConstraint(item: self,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: contentView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([top, left, bottom, right])
        
        let gradient = CAGradientLayer(layer: imageView.layer)
        
        gradient.colors = [UIColor.white.cgColor,UIColor.clear.cgColor]
        gradient.locations = [0.5, 0.9]
        gradient.frame = CGRect(x: 0, y: 0, width: imageView.frame.width, height: imageView.frame.height)
        imageView.layer.mask = gradient
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func displayHeader(_ detail: Tour) {
        let length = detail.tour.days
        if let go =  detail.tour.dateList.first,
            let gs = go.simpleDateString(),
            let returndate = Calendar.current.date(byAdding: .day, value: length, to: go),
            let ds = returndate.simpleDateString() {
            self.datesLabel.text = gs + "〜" + ds
        } else {
            self.datesLabel.text = "電洽"
        }
        self.headerLabel.text = detail.tour.area
        self.titleLabel.text = detail.tour.title
        if detail.tour.hide_price {
            self.priceLabel.text = "\(detail.tour.days)天 / \(detail.tour.hide_price_title)"
        } else {
            let format = NumberFormatter()
            format.numberStyle = .currency
            
            format.minimumFractionDigits = 0
            if let s = format.string(from: NSNumber(value: detail.tour.price)) {
                self.priceLabel.text = "\(detail.tour.days)天 / NTD" + s + " 起"
            } else {
                self.priceLabel.text = "\(detail.tour.days)天 / 電洽"
            }
        }
        
        let url = detail.tour.cover
        //imageView.sd_setImage(with: URL(string: "http://www.domain.com/path/to/image.jpg"), placeholderImage: UIImage(named: "placeholder.png"))
        self.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let data = data,
//                let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    self.imageView.image = image
//                }
//            }
//
//        }
//
//        task.resume()
        
        
    }
}

class TourDetailPageViewController: UIViewController {

    var detailHeader : DetailHeaderView = DetailHeaderView()
    
    var tabs : TabPageViewController = TabPageViewController()
    
    var viewModel = TourDetailViewModel()
    
    fileprivate var headerTopConstraint: NSLayoutConstraint?
    
    public init(_ guide : Tour?) {

        super.init(nibName: nil, bundle: nil)
        
        let vc1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FlightInfoVC")
        let vc2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItineraryVC")
        let vc3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FeeVC")
        let vc4 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InfoVC")
        
        self.guideInfo = guide
        if let flight = vc1 as? FlightInfoViewController,
            let it = vc2 as? ItineraryViewController,
            let pr = vc3 as? PriceViewController,
            let nt = vc4 as? TripNoteViewController,
            let s = getTourId() {
            flight.viewModel.tourId = s
            it.viewModel.tourId = s
            pr.viewModel.tourId = s
            nt.viewModel.tourId = s
        }
        
        tabs.tabItems = [(vc1, "航班"), (vc2, "行程"),(vc3,"費用"),(vc4,"其他說明")]
        tabs.option.tabWidth = view.frame.width / CGFloat(tabs.tabItems.count)
        tabs.option.hidesTopViewOnSwipeType = .all
        tabs.option.currentColor = UIColor.darkGray
        tabs.option.defaultColor = UIColor.lightGray
        tabs.option.currentBarHeight = 3
        tabs.option.tabHeight = 44        
        tabs.option.isTranslucent = false
        
        self.title = "行程說明"
        
        setupHeaderView()
        setupTabPageVCContainer()
    }
    private func getTourId() -> String? {
        
        guard let t = self.guideInfo else { return nil }
        
        return t.tour.tour_id
        
    }
    func updateNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        
        if hidden {
            if let h = self.headerTopConstraint {
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
                    h.constant = hidden ? -250 : 0.0
                    
                }, completion: nil)
                
            }
            //navigationController.setNavigationBarHidden(true, animated: true)
        } else {
            if let h = self.headerTopConstraint {
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: .curveLinear, animations: {
                    h.constant =  0
                
                }, completion: nil)
            }
            
        }
        
        
    }

    
    @objc func handleSwipeUp(_ gesture : UISwipeGestureRecognizer) {
        print("swipe")
        self.updateNavigationBarHidden(true, animated: true)
    }
    @objc func handleSwipeDown(_ gesture : UISwipeGestureRecognizer) {
        print("swiped")
        self.updateNavigationBarHidden(false, animated: true)
    }
    fileprivate func setupTabPageVCContainer() {
        
        let container = UIView(frame: CGRect.zero)
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        
        let top = NSLayoutConstraint(item: container,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: detailHeader,
                                     attribute: .bottom,
                                     multiplier:1.0,
                                     constant: 0)
        
        let left = NSLayoutConstraint(item: container,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let right = NSLayoutConstraint(item: view,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: container,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        let bottom = NSLayoutConstraint(item:container,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: bottomLayoutGuide,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        
        view.addConstraints([top, left, right, bottom])
        container.addSubview(self.tabs.view)
        self.tabs.view.bounds = CGRect(origin: CGPoint(x:0,y:0), size: container.bounds.size)
        
        addChild(self.tabs)
        self.tabs.willMove(toParent: self)
        self.tabs.view.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height )
    }
    fileprivate func setupHeaderView() {
        
        self.view.addSubview(detailHeader)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeUp(_:)))
        swipe.direction = .up
        self.view.addGestureRecognizer(swipe)
        
        
        let swipedown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDown(_:)))
        swipedown.direction = .down
        self.view.addGestureRecognizer(swipedown)
        
        detailHeader.translatesAutoresizingMaskIntoConstraints = false
        
        let height = NSLayoutConstraint(item: detailHeader,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: 250)
        detailHeader.addConstraint(height)
        view.addSubview(detailHeader)
        
        let top = NSLayoutConstraint(item: detailHeader,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: topLayoutGuide,
                                     attribute: .bottom,
                                     multiplier:1.0,
                                     constant: 0)
        
        let left = NSLayoutConstraint(item: detailHeader,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)
        
        let right = NSLayoutConstraint(item: view,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: detailHeader,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)
        
        view.addConstraints([top, left, right])
        
        headerTopConstraint = top
        
        if let t = self.guideInfo {
            self.detailHeader.displayHeader(t)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var guideInfo : Tour?
    
}
