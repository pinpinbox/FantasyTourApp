//
//  PriceViewController.swift
//  Networking
//
//  Created by Antelis on 2019/4/23.
//  Copyright © 2019 Scott Gardner. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DetailCellView : UICollectionViewCell {
    @IBOutlet weak var textTitle : UILabel?
    @IBOutlet weak var textTag : UILabel?
    
    var viewModel : DetailCellModel? {
        didSet {
            bind()
        }
    }
    
    private let disposeBag = DisposeBag()
    func bind() {
        guard let title = textTitle, let t = textTag else {
            return
        }
        
        viewModel?.texttag
            .asObservable()
            .bind(to: t.rx.text )
            .disposed(by: disposeBag)
        
        viewModel?.texttitle
            .asObservable()
            .bind(to: title.rx.text)
            .disposed(by: disposeBag)
    }
}
class PriceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var priceList: UICollectionView?

    let viewModel = PriceViewModel()
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        if let p = priceList {
            
            viewModel.pricelist.asObservable().bind(to: p.rx.items) { _, index, pricetag in
                let index = IndexPath(item: index, section: 0)
                guard let cell = p.dequeueReusableCell(withReuseIdentifier: "PriceCellView", for: index) as? DetailCellView else {
                    return UICollectionViewCell()
                }
                
                cell.viewModel = DetailCellModel(pricetag)
                
                return cell
                
            }.disposed(by: disposeBag)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = UIScreen.main.bounds.width
        return CGSize(width: w, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
