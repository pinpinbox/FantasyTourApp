

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

//MARK: -
//MARK: NOTE - Be mindful of Guideline 4.2.2 violation
//MARK: -

class TourListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var listView : UICollectionView?
    @IBOutlet weak var loadingView : UIActivityIndicatorView?
    
    var viewModel = TourListViewModel(.mostpopular)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = listView {
            bind()
        }
        definesPresentationContext = true
    }
    
    func bind() {
        
        self.rx.viewWillAppear
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        if let listView = listView {
            listView.rx.itemSelected
                .map { $0.row }
                .bind(to: viewModel.itemSelected)
                .disposed(by: disposeBag)
            
            listView.rx.itemSelected
                .subscribe(onNext: { [unowned self] in
                    self.listView?.deselectItem(at: $0, animated: false)
                    // self present vc here //
                    
                    }, onError: { (error) in
                        print("item Selected error : \(error.localizedDescription)")
                }).disposed(by: disposeBag)
            
            listView.rx.contentOffset.asDriver()
                .map { _ in self.shouldRequestNextPage() }
                .distinctUntilChanged()
                .filter { $0 }
                //.withLatestFrom(
                //.filter { !$0 }
                .drive(onNext: { _ in self.viewModel.retrieveList(self.viewModel.listType) })
                .disposed(by: disposeBag)
            
            viewModel.guideList.asDriver()
                .drive(listView.rx.items(cellIdentifier: "TourItemCell",
                                         cellType: TourItemCell.self)
                ){(_, element, cell) in
                    DispatchQueue.main.async {
                        if let l = self.listView, let ld = self.loadingView, l.isHidden {
                            l.isHidden = false
                            ld.isHidden = true
                        }
                    }
                    cell.viewModel.updateTour(element)
                    cell.viewModel.phoneBtnPressedBlock = {
                        DispatchQueue.main.async {                                                
                            let p = PhoneListViewController()                                                    
                            self.present(p, animated: true, completion: nil)
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
    
    private func shouldRequestNextPage() -> Bool {
        if let list = self.listView {
            let edge = UIScreen.main.bounds.height
        return list.contentSize.height > 0 &&
            list.isNearBottom(edgeOffset: edge )
        }
        return false
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
    
}

