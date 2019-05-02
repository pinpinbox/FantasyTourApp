//
//  TripNoteViewController.swift
//  Networking
//
//  Created by Antelis on 2019/4/24.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TripNoteViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var noteList: UICollectionView?
    
    let viewModel = TripNoteViewModel()
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        if let n = noteList {
        
        viewModel.notelist.asObservable().bind(to: n.rx.items) { _, index, detail in
            let index = IndexPath(item: index, section: 0)
            guard let cell = n.dequeueReusableCell(withReuseIdentifier: "NoteCellView", for: index) as? DetailCellView else {
                return UICollectionViewCell()
            }
        
            cell.viewModel = DetailCellModel(detail)
        
            return cell
        
            }.disposed(by: disposeBag)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = UIScreen.main.bounds.width
        return CGSize(width: w, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}
