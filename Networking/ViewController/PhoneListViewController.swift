//
//  PhoneListViewController.swift
//  Networking
//
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import WebKit

// add some info text in the header...

var locations : Array<(loc: String, tel: String)> = [("台北總公司","02-2517-1157"),
("新竹分公司","03-523-4177"),
("台中分公司","04-2201-1733"),
("南台中分公司","04-2472-9696"),
("彰化分公司","04-722-0432"),
("台南分公司","06-338-7595"),
("高雄分公司","07-332-8399")]

// MARK: - Cell for displaying branch name and phone number
internal class PhoneCell : UICollectionViewCell {
    
    let nameLabel = UILabel(frame: CGRect.zero)
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.contentView.addSubview(nameLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(nameLabel)
    }
    
    func refreshData(_ indexPath: IndexPath) {
        
        self.nameLabel.frame = self.contentView.frame.insetBy(dx: -3 , dy: -3)
        if indexPath.item == 0 {
            self.nameLabel.text = "請電洽"
            self.nameLabel.numberOfLines = 0
            self.nameLabel.layer.cornerRadius = 6
            self.nameLabel.layer.borderColor = UIColor.clear.cgColor//UIColor.brown.cgColor
            self.nameLabel.layer.borderWidth = 0.5
        } else {
            self.nameLabel.text = locations[indexPath.item-1].loc+"\n"+locations[indexPath.item-1].tel
            self.nameLabel.numberOfLines = 0
            self.nameLabel.layer.cornerRadius = 6
            self.nameLabel.layer.borderColor = UIColor.brown.cgColor
            self.nameLabel.layer.borderWidth = 0.5
        }
        
        self.nameLabel.textColor = UIColor.brown
        self.nameLabel.textAlignment = .center
    }
    
}

// MARK: - VC presenting list of branch. Tap any cell to make a call
class PhoneListViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var listView : UICollectionView?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        setupBackgroundView()
        setupPhoneList()
    }
    private func setupBackgroundView() {
        
        let backgroundview = UIView(frame: self.view.frame)
        backgroundview.backgroundColor = UIColor.gray
        backgroundview.alpha = 0.7
        view.addSubview(backgroundview)
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PhoneListViewController.tapAction(_ :)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    @objc func tapAction(_ tap: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    private func setupPhoneList() {
        let layout = UICollectionViewFlowLayout.init()
        
        self.listView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)//UICollectionView(frame: self.view.frame)
        self.listView?.register(PhoneCell.self, forCellWithReuseIdentifier: "placeCell")
        
        if let listView = self.listView {
            listView.layer.cornerRadius = 6
            listView.layer.shadowOffset = CGSize(width:2, height:1)
            listView.layer.shadowColor = UIColor.black.cgColor
            listView.layer.shadowRadius = 5
            listView.layer.shadowOpacity = 0.5
            listView.translatesAutoresizingMaskIntoConstraints = false
            listView.clipsToBounds = false
            
            let top = NSLayoutConstraint(item: listView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: topLayoutGuide,
                                         attribute: .bottom,
                                         multiplier:1.0,
                                         constant: 60)
            
            let left = NSLayoutConstraint(item: listView,
                                          attribute: .leading,
                                          relatedBy: .equal,
                                          toItem: view,
                                          attribute: .leading,
                                          multiplier: 1.0,
                                          constant: 40.0)
            
            let right = NSLayoutConstraint(item: view,
                                           attribute: .trailing,
                                           relatedBy: .equal,
                                           toItem: listView,
                                           attribute: .trailing,
                                           multiplier: 1.0,
                                           constant: 40.0)
            
            let bottom = NSLayoutConstraint(item:listView,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: bottomLayoutGuide,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: -60.0)
            listView.backgroundColor = UIColor.white
            view.addSubview(listView)
            view.addConstraints([top, left, right, bottom])
            
            layout.itemSize = CGSize(width: self.listView!.frame.width-20, height: 40)
            layout.minimumLineSpacing = 20
            layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
            listView.dataSource = self
            listView.delegate = self
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 40.0
        if let l = self.listView {
            let c = CGFloat(locations.count)+1
            height = (l.frame.height-(c+1)*20.0) / c
        }
        
        return CGSize(width: self.listView!.frame.width-20, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count+1
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placeCell", for: indexPath)
        if let cc = cell as? PhoneCell {
            cc.refreshData(indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 { return }
        let tel = locations[indexPath.item].tel
        let ntel = tel.replacingOccurrences(of: "-", with: "")
        //print(ntel)
        if let url = URL(string: "tel://"+ntel) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func showWebView(_ webview : WKWebView) {
        
        if #available(iOS 11.0, *) {
            webview.frame = view.safeAreaLayoutGuide.layoutFrame
        } else {
            webview.frame = view.frame
        }
        webview.layer.cornerRadius = 8
        webview.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: webview,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: topLayoutGuide,
                                     attribute: .bottom,
                                     multiplier:1.0,
                                     constant: 65)
        
        let left = NSLayoutConstraint(item: webview,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 45.0)
        
        let right = NSLayoutConstraint(item: view,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: webview,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 45.0)
        
        let bottom = NSLayoutConstraint(item:webview,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: bottomLayoutGuide,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: -65.0)
        
        view.addSubview(webview)
        view.addConstraints([top, left, right, bottom])
        
        
    }
    

}
