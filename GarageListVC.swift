
import UIKit

class GarageListVC: BaseVC {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: UITableView?
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Class Variables -
    
    var myGarage = MyGarages()
    var garageCars: [[VehicleDetails]] = []
    var currentUser: User?
    var canEditing: Bool?
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods -
    
    //-------------------------------------------------------------------------------------
    
    //MARK: - API Validation
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - API Methods -
    
    func deleteVehicleAPI(indexPath: IndexPath) {
        
        var parameter = Dictionary<String,Any>()
        parameter["vehicle_id"] = JSON(garageCars[indexPath.section][indexPath.row].id as Any).stringValue
        
        ApiManger.init().makeRequest(method: .DeleteVehicle ,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                
                //if self.garageCars.count
                
                self.garageCars[indexPath.section].remove(at: indexPath.row)
                if self.garageCars[indexPath.section].count > 0 {
                    self.tableView?.deleteRows(at: [indexPath], with: .automatic)
                }
                else {
                    self.tableView?.reloadData()
                }
                
                
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func getGarageAPI() {
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(currentUser?.id as Any).stringValue
        
        ApiManger.init().makeRequest(method: .GetGarage,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            self.tableView?.isHidden = false
            
            //self.refreshControl.endRefreshing()
            self.tableView?.isHidden = false
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                print(response[kData])
                self.garageCars = []
                self.myGarage = MyGarages(fromJson: JSON(response[kData] as Any))
                guard let arrCur = self.myGarage.current,
                      let arrPre = self.myGarage.previous else {return}
                
                self.garageCars.append(arrCur)
                self.garageCars.append(arrPre)
                
                self.tableView?.reloadData()
                
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Delegate Methods -
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Action Methods -
    
    @IBAction func addTapHandler(_ sender: UIButton) {
        let vc = Cars.VC("CreateCar1VC") as! CreateCar1VC
        vc.title = "Add a car"
        vc.hideTabBar()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backTapHandler(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Style Methods -
    
    override func styleLoad() {
        super.styleLoad()
        
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - View Life Cycle Methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentUser?.user_id != User.shared?.user_id {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        #if targetEnvironment(simulator)
        if SELETCT_ADD_CAR {
            addTapHandler(UIButton())
        }
        #endif
        
        tableView?.isHidden = true
        tableView?.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: kFooterTableViewHeight / 2.0))
        tableView?.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: kFooterTableViewHeight))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        getGarageAPI()
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

extension GarageListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.canEditing ?? false 
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let controller = UIAlertController(title: AppName,
                                           message: "Are you sure you want to delete this car?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            self.deleteVehicleAPI(indexPath: indexPath)
        }))
        controller.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            
        }))
        present(controller, animated: true, completion: {() -> Void in })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Cars.VC("CarDetailsVC") as! CarDetailsVC
        vc.car = garageCars[indexPath.section][indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.reusableCell(GarageSectionTVCell.self)
        cell.titleLabel.text = "  \(garageTypes[section])  "
        cell.titleLabel.backgroundColor = garageColors[garageTypes[section]] == nil ? #colorLiteral(red: 0.1333333333, green: 0.7568627451, blue: 0.03137254902, alpha: 1) : garageColors[garageTypes[section]]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if garageCars[section].count == 0 {
            return 0.0
        }
        
        return 41.0
        ////UITableView.automaticDimension
    }
}

    // MARK: - UITableViewDataSource

extension GarageListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return garageCars.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return garageCars[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(GarageListTVCell.self)
        cell.dataObject = garageCars[indexPath.section][indexPath.row]
        return cell
    }
    
}
