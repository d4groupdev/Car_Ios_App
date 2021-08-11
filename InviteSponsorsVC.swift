
import UIKit
import MessageUI

class InviteSponsorsVC: BaseVC {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var searchTextField: UITextField?
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Class Variables -
    
    var editedCar: VehicleDetails?
    var currentCar: CarDetails?
    var mapSponsors: [String: String] = [:]
    var dataArray: [Invities] = []
    var mainTypeNameForMail = ""
    var businesName : String? = nil
    var currentPage = 1
    var nextPageStop = false
    var requested = false
    
    private var lastRequestID:String?
    //--------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods -
    
    //-------------------------------------------------------------------------------------
    
    //MARK: - API Validation
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - API Methods -
    
    func getInvitiesAPI(searchText : String? = nil) {
        let requestID:String = NSUUID().uuidString
        self.lastRequestID = requestID

        /*
        var parameter = Dictionary<String,Any>()
        parameter["page"] = JSON(self.currentPage as Any).stringValue
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["type"] = "business"
        
        if let text = searchText {
            parameter["search"] = text
        }*/
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["type"] = "business"//"home"//"discover"
        parameter["page"] = JSON(1 as Any).stringValue
        parameter["unit"] = "mi"
        if let text = searchText {
            parameter["search"] = text
        }
        
        
        requested = true
        ApiManger.init().makeRequest(method: .GetExploreData/*.GetInvities*/,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if requestID != self.lastRequestID {
                return
            }

            self.requested = false
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                
                if self.currentPage == 1 {
                    self.dataArray.removeAll()
                }
                
                debugPrint(response[kData])
                let dict = response[kData]
                self.loadData(arrData: JSON(dict[kData] as Any).arrayObject)
                
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func loadData(arrData:Array<Any>?){
        
        if arrData != nil {
            for item in arrData!{
                let vide = Invities.init(fromJson: JSON(item))
                if (mapSponsors[vide.userId] == nil) {
                    self.dataArray.append(vide)
                }
            }
            
            if arrData?.count == 0 {
                nextPageStop = true
            }
        }
        else {
            nextPageStop = true
        }
        
        tableView?.reloadData()
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Delegate Methods -
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextPageStop = false
        currentPage = 1
        getInvitiesAPI(searchText: searchTextField?.text!)
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isAtTop{
            
        }else if scrollView.isAtBottom && !nextPageStop && !requested{
            currentPage += 1
            debugPrint(".......call \(self.currentPage) page.....")
            getInvitiesAPI(searchText: searchTextField?.text!)
        }
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Action Methods -
    
    @IBAction func backTapHandler(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchDidChange(_ field: UITextField) {
        nextPageStop = false
        currentPage = 1
        getInvitiesAPI(searchText: searchTextField?.text!)
    }
    
    @IBAction func inviteByEmailTapHandler(_ sender: UIButton) {
        if let vehicle = self.editedCar {
            sendEmail(vehicle: vehicle)
        }
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
        
        for sponsor in currentCar?.arrSponsor ?? [] {
            mapSponsors[sponsor.userId] = ""
        }
        
        searchTextField?.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 0.0))
        searchTextField?.leftViewMode = .always
        tableView?.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: kFooterTableViewHeight))
        
        getInvitiesAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

extension InviteSponsorsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Setter.VC("ConfirmSponsorsVC") as! ConfirmSponsorsVC
        vc.candidate = dataArray[indexPath.row]
        vc.currentCar = currentCar
        //vc.editedModificationInt = indexPath.row
        //vc.editedModification = dataArray[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

    // MARK: - UITableViewDataSource

extension InviteSponsorsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(SponsorListTVCell.self)
        let sponsor:Invities = dataArray[indexPath.row]
        cell.titleLabel.text =  "\(sponsor.businessname ?? "")"
        cell.modelLabel.text = sponsor.city
        cell.mainImageView.downloadedFrom(link: sponsor.profileImage)
        return cell
    }
    
}

    // MARK: - MFMailComposeViewControllerDelegate

extension InviteSponsorsVC : MFMailComposeViewControllerDelegate{
    
    func sendEmail(vehicle:VehicleDetails) {
        if true ||  MFMailComposeViewController.canSendMail() {
            let mail = GlobalFunctions.shared.sponsorInviteEmail(car: vehicle)
            mail.mailComposeDelegate = self
            present(mail, animated: true)
        } else {
            GlobalFunctions.shared.showTroubleMailMessage()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
