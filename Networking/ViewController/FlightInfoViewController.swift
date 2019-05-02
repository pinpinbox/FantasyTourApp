//
//  FlightInfoViewController.swift
//  Networking
//
//  Created by Antelis on 2019/4/19.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

private let reuseIdentifier = "FlightInfoCell"
private let reuseIdentiHeaderfier = "FlightInfoHeader"

class FlightInfoHeader : UICollectionReusableView {
    
}

class FlightTableTextView : UITextView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isEditable = false
        //self.isScrollEnabled = false
        self.isSelectable = false
    }
}
class FlightInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var departureInfo : FlightTableTextView?
    @IBOutlet weak var arrivalInfo : FlightTableTextView?
    @IBOutlet weak var codeName: UILabel?
    @IBOutlet weak var airplane: UIImageView?
    @IBOutlet weak var planeView: UIView?
    
    @IBOutlet weak var baseView: UIView?
    @IBOutlet weak var shadowView: UIView?
    
    var viewModel : FlightInfoCellViewModel? {
        didSet {
            bind()
        }
    }
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        if let baseView = self.baseView,
            let shadowView = self.shadowView {
            
            baseView.clipsToBounds = true
            baseView.layer.cornerRadius = 8
            shadowView.layer.shadowOffset = CGSize(width:2, height:1)
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowRadius = 3
            shadowView.layer.shadowOpacity = 0.3
            
        }
        
    }
    private func bind() {
        guard let d = departureInfo, let a = arrivalInfo, let code = codeName, let base = baseView else { return }
        code.textColor = UIColor.white
        code.font = UIFont.boldSystemFont(ofSize: 14)
        a.textAlignment = .right
        d.textAlignment = .left
        viewModel?.codeName
            .asObservable()
            .bind(to: code.rx.text)
            .disposed(by: disposeBag)
        
        viewModel?.departureText
            .asObservable()
            .bind(to: d.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel?.arrivalText
            .asObservable()
            .bind(to: a.rx.attributedText)
            .disposed(by: disposeBag)
        
        viewModel?.backgroundColor
            .asObservable()
            .bind(to: base.rx.backgroundColor )
            .disposed(by: disposeBag)
        
        
    }
    
    func showError(_ message: String) {
        guard let a = planeView, let code = codeName, let base = baseView else { return }
        code.textColor = UIColor.white
        code.font = UIFont.boldSystemFont(ofSize: 14)
        a.isHidden = true
        base.backgroundColor = colorTables.last//errColor
        code.text = message
        
    }
    
    func showNoData() {
        guard let a = planeView, let code = codeName, let base = baseView else { return }
        code.textColor = UIColor.white
        code.font = UIFont.boldSystemFont(ofSize: 14)
        a.isHidden = true
        base.backgroundColor = colorTables.last//errColor
        code.text = "航班安排中，敬請期待"
        
    }
    
}

class FlightInfoViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var flightList: UICollectionView?
    
    let viewModel = FlightInfoViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
    }
    
    fileprivate func bind() {
        
        self.rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        
        if let list = flightList {
        
            viewModel.flightCells.bind(to: list.rx.items) { _, index, element in
                let indexPath = IndexPath(item: index, section: 0)
                guard let cell = list.dequeueReusableCell(withReuseIdentifier:reuseIdentifier , for: indexPath) as? FlightInfoCell else {
                    return UICollectionViewCell()
                }
                
                switch element {
                case .normal(let viewModel):
                    cell.viewModel = viewModel
                    return cell
                case .error(let message):
                    cell.isUserInteractionEnabled = false
                    cell.showError(message)
                    return cell
                case .empty:
                    
                    cell.isUserInteractionEnabled = false
                    cell.showNoData()
                    
                    return cell
                }
            }.disposed(by: disposeBag)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = UIScreen.main.bounds.width
        return CGSize(width: w, height: w*150/320)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 60, left: 0, bottom: 16, right: 0)
    }
}
