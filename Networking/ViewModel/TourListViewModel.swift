import RxSwift
import RxCocoa

// MARK: - ViewModel for ViewController -
class TourListViewModel {
    
    private var last : Int = 0
    
    private let disposeBag = DisposeBag()
    
    let listCount = BehaviorRelay(value: 15)
    
    let viewWillAppear = PublishRelay<Bool>()
    let viewWillDisappear = PublishRelay<Bool>()
    let itemSelected = PublishRelay<Int>()
    let errors = PublishRelay<Error>()
    var guideList = BehaviorRelay<[Tour]> (value: [])
    
    let detailVC = PublishRelay<TourDetailPageViewController>()
    
    var listType: TourListType = .latest  {
        didSet {
            guideList.accept([])
        }
    }
    
    
    convenience init(_ listType : TourListType) {
        self.init()
        self.listType = listType
        self.viewWillAppear.subscribe(onNext: { (animated) in
            
            //  fetch query if empty
            if self.guideList.value.count < 1 {
                self.retrieveList(self.listType)
            }
            
        }).disposed(by: disposeBag)
        
        self.viewWillDisappear.subscribe(onNext: { (animated) in
        }).disposed(by: disposeBag)
        
        
        self.itemSelected.withLatestFrom(guideList) { (index, list) in list[index]}
            .subscribe({ guide in
                // VC transitioning, passing model //
                let detailVC = TourDetailPageViewController(guide.element)
                //detailVC.guideInfo = guide.element
                self.detailVC.accept(detailVC)
                
            })
            .disposed(by: disposeBag)
        
    }
    
    
    
    //MARK: API
    func retrieveList(_ listType:TourListType) {
        
        let count = listCount.value - last
        let l0 = last
        last = listCount.value
        guard count > 0, let url = URL(string:"https://www.fantasy-tours.com/FantasyAPI/\(listType.rawValue)/\(l0),\(count)" ) else { return } //Observable.just([]) }
        
        URLSession.shared.rx.data(request: URLRequest(url: url)).map(self.decode).subscribe(onNext: { (items) in
            let c = self.listCount.value
            self.listCount.accept(c+items.count)
            print("listCount \(self.listCount.value)")
            self.guideList.accept(self.guideList.value + items)
        }).disposed(by: disposeBag)
        
    }
    
    // MARK: JSON Decoding
    func decode(_ data : Data) -> [Tour]{
        do {
            //let str = String(data:data , encoding: .utf8)
            //print("JSON : \n \(str ?? "") \n")
            let result = try JSONDecoder().decode(getlatestlistItem.self, from: data)
            if result.result == "SYSTEM_OK" {
                let list = result.data
                print(list.count)
                return list
            }
            
        } catch let error {
            print("JSON DECODER ERR : \(error)")
        }
        return []
    }
}

//MARK:- ViewModel for TourItemCell -
class TourItemCellViewModel {
    
    private let disposeBag = DisposeBag()
    
    let tourTitle = BehaviorRelay<String>(value: "")
    let datesList = BehaviorRelay<String>(value: "")
    let regionText = BehaviorRelay<String>(value: "")
    let priceText = BehaviorRelay<String>(value: "")
    let coverImage = BehaviorRelay<UIImage?>(value: nil)
    
    var phoneBtnPressedBlock : (() -> Void)?
    func runPhoneBtnPressedBlock() {
        if let p = phoneBtnPressedBlock {
            p()
        }
    }
    func updateTour(_ tour: Tour) {
        
        self.tourTitle.accept(tour.tour.title)
        self.datesList.accept(tour.tour.dates)
        self.regionText.accept(tour.tour.area)
        
        if tour.tour.hide_price {
            self.priceText.accept("\(tour.tour.days)天 / \(tour.tour.hide_price_title)")
        } else {
            let format = NumberFormatter()
            format.numberStyle = .currency
            
            format.minimumFractionDigits = 0
            if let s = format.string(from: NSNumber(value: tour.tour.price)) {
                self.priceText.accept("\(tour.tour.days)天 / NTD" + s + " 起")//String(guide.tour.price)
            } else {
                self.priceText.accept("\(tour.tour.days)天 / 電洽")
            }
        }
        let url = tour.tour.cover
        self.coverImage.accept(nil)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let image = UIImage(data: data) {
                self.coverImage.accept(image)
            }
            
        }
        
        task.resume()
        
    }
    
    
    
}
