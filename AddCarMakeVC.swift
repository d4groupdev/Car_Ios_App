
import UIKit

class AddCarMakeVC: BaseVC {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Class Variables -
    
    
    
    
    //paging
    var fullDataArray: [CarBrand] = []
    var dataArray: [CarBrand] = []
    var currentPage = 1
    var isService = false
    var refreshControl = UIRefreshControl()
    
    var didSet: ((CarBrand) -> Swift.Void)?
    var addSuggestion: (([String : Any]) -> Swift.Void)?
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods -
    
    func sortUpdate(_ search: String) {
        
        if search == "" {
            dataArray = fullDataArray
        }
        else {
            dataArray = fullDataArray.filter { $0.name == nil ? false : $0.name!.localizedCaseInsensitiveContains(search) }
        }
        
        tableView?.reloadData()
    }
    
    //-------------------------------------------------------------------------------------
    
    //MARK: - API Validation
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - API Methods -
    
    func getCarBrandsAPI() {
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["page"] = JSON(self.currentPage as Any).stringValue
        
        ApiManger.init().makeRequest(method: .GetCarBrands,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                print(response[kData])
                self.loadData(arrData: JSON(response[kData] as Any).arrayObject)
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func loadData(arrData:Array<Any>?){
        
        if currentPage == 1 {
            fullDataArray.removeAll()
        }
        if arrData != nil {
            for item in arrData!{
                let car = CarBrand.init(fromJson: JSON(item))
                fullDataArray.append(car)
            }
            if arrData?.count != 0 {
                isService = true
            }
        }
        else {
            isService = false
        }
        if refreshControl.isRefreshing{
           refreshControl.endRefreshing()
        }
        
        sortUpdate(searchTextField.text ?? "")
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Delegate Methods -
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isAtBottom {
            if isService {
                isService = false
                currentPage += 1
                debugPrint(".......call \(self.currentPage) page.....")
                getCarBrandsAPI()
            }
        }
    }*/
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Action Methods -
    
    @IBAction func searchDidChangeHandler(_ sender: UITextField) {
        
        sortUpdate(sender.text ?? "")
    }
    
    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        if refreshControl.isRefreshing {
            currentPage = 1
            getCarBrandsAPI()
        }
    }
    
    @IBAction func suggestTapHandler(_ sender: UIButton) {
        let vc = Cars.VC("SuggestMakeVC") as! SuggestMakeVC
        vc.addSuggestion = {(obj) in
            self.addSuggestion?(obj)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backTapHandler(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Style Methods -
    
    override func styleLoad() {
        super.styleLoad()
        
        searchTextField.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 0.0))
        searchTextField.leftViewMode = .always
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - View Life Cycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl
        tableView?.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: kFooterTableViewHeight))
        
        
        
        getCarBrandsAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Memory Management -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
    }
    
    //--------------------------------------------------------------------------------------
}

    // MARK: - UITableViewDelegate

extension AddCarMakeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        backTapHandler(UIButton())
        didSet?(dataArray[indexPath.row])
    }
    
}

    // MARK: - UITableViewDataSource

extension AddCarMakeVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(CarModelSimpleTitleCVCell.self)
        cell.titleLabel.text = dataArray[indexPath.row].name
        return cell
    }
    
}
