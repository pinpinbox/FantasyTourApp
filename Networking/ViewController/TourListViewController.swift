

import UIKit
import RxSwift
import RxDataSources

//MARK: -
//MARK: NOTE - Be mindful of Guideline 4.2.2 violation
//MARK: -

class FavouriteButton : UIView {
    
    var isTapped : Bool = false
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapEffect(_:)))
        tap.cancelsTouchesInView = true
        self.addGestureRecognizer(tap)
        layer.masksToBounds = true
        
        let v = UIView(frame: fillView.frame)
        v.backgroundColor = UIColor.orange
        self.fillView.frame = self.bounds
        self.fillView.tintColor = colorTables[colorTables.count-2]
        v.frame = CGRect(x: 0, y: self.bounds.height, width:self.bounds.width , height: 0)
        fillView.mask = v
        
        
        addSubview(fillView)
    }
    @objc func tapEffect(_ gesture : UITapGestureRecognizer) {
        print("tapEffect")
        isTapped = !isTapped
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
        guard let t = tourName, let ds = datesList, let re = region, let pr = price, let cover = self.imageView, let phone = phone else { return }
        
        phone.addTarget(self, action: #selector(self.phoneBtnPressed(_:)), for: .touchUpInside)
        
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
    
    @IBAction func phoneBtnPressed(_ sender: Any?) {
        
        self.viewModel.runPhoneBtnPressedBlock()
    }
}


class TourListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var listView : UICollectionView?
    @IBOutlet weak var countItem : UINavigationItem?
    
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
                    cell.viewModel.updateTour(element)
                    cell.viewModel.phoneBtnPressedBlock = {
                        DispatchQueue.main.async {                                                
                            let p = PhoneListViewController()                                                    
                            self.present(p, animated: true, completion: nil)
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

