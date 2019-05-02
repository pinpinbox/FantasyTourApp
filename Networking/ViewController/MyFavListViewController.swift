//
//  MyFavListViewController.swift
//  FantasyTourApp
//
//  Created by Antelis on 2019/4/25.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MyFavListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var favlistView: UICollectionView?
    @IBOutlet weak var emptyHint : UIButton?
    
    let viewModel = FavListViewModel(.fav)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _ = favlistView {
            bind()
        }
        definesPresentationContext = true
    }
    
    func bind() {
        
        self.rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        if let hint = emptyHint {
            hint.layer.cornerRadius = 10
            hint.clipsToBounds = true
        }
        
        if let list = favlistView {
            
            list.rx.itemSelected
                .map { $0.row }
                .bind(to: viewModel.itemSelected)
                .disposed(by: disposeBag)
            
            list.rx.itemSelected
                .subscribe(onNext: { [unowned self] in
                    self.favlistView?.deselectItem(at: $0, animated: false)
                    // self present vc here //
                    
                    }, onError: { (error) in
                        print("item Selected error : \(error.localizedDescription)")
                }).disposed(by: disposeBag)
            
//            list.rx.contentOffset.asDriver()
//                .map { _ in self.shouldRequestNextPage() }
//                .distinctUntilChanged()
//                .filter { $0 }
//                .drive(onNext: { _ in self.viewModel.retrieveList(self.viewModel.listType) })
//                .disposed(by: disposeBag)
//            
            
            viewModel.guideList.asObservable().bind { (guides) in
                list.isHidden = (guides.count < 1)
            }.disposed(by: disposeBag)
            
            viewModel.guideList.asDriver()
                .drive(list.rx.items(cellIdentifier: "TourItemCell",
                                         cellType: TourItemCell.self)
                ){(index, element, cell) in
                    cell.viewModel.updateTour(element)
                    cell.viewModel.phoneBtnPressedBlock = {
                        DispatchQueue.main.async {
                            let p = PhoneListViewController()
                            self.present(p, animated: true, completion: nil)
                        }
                    }
                    cell.viewModel.favRemovedBlock = {
                        DispatchQueue.main.async {
                            //list.deleteItems(at: [IndexPath(item: index, section: 0)])
                            self.viewModel.removeFavItemAt(index)
                        }
                    }
                    cell.viewModel.tourDatesBtnBlock = {(tour_id) in
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            
                            if let fv  = storyboard.instantiateViewController(withIdentifier: "TourDatesCalendarViewController") as? TourDatesCalendarViewController {
                                //fv.dates = dates
                                fv.viewModel.tour_id = tour_id
                                self.present(fv, animated: true, completion: nil)
                            }
                        }
                    }
                }.disposed(by: disposeBag)
            
            viewModel.detailVC.subscribe(onNext: { vc in
                if let n = self.navigationController {
                    n.pushViewController(vc, animated: true)
                    if let back = vc.navigationItem.backBarButtonItem {
                        back.title = "◀︎"
                    }
                }
            }, onError: { error in
                
            }, onCompleted: {
                
            }).disposed(by: disposeBag)
        }
        
    }
    @IBAction func dismissView(_ sender : Any?) {
        self.navigationController?.popViewController(animated: true)
    }
    private func shouldRequestNextPage() -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = UIScreen.main.bounds.width
        return CGSize(width: w, height: w*220/375)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            print(segue)
        
    }
}
