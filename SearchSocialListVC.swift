
import UIKit

class SearchSocialListVC: BaseVC {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var menuCollection: UICollectionView!
    @IBOutlet weak var searchField: UITextField!
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Class Variables -
    
    var socialVC: SocialVC!
    
    var groups : [Groups] = []
    var events: [Event] = []
    
    var selectedType = 0
    var menu: [MenuCategory] = [MenuCategory(title: "Groups"),
                                MenuCategory(title: "Events")]
    
    var lastRequestId:String?
    //--------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods -
    
    func update() {
        tableView?.isHidden = true
        if selectedType == 0 {
            groups = []
            getGroupListAPI()
        }
        else
        if selectedType == 1 {
            events = []
            getEventListAPI()
        }
    }
    
    //-------------------------------------------------------------------------------------
    
    //MARK: - API Validation
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - API Methods -
    
    func getGroupListAPI() {
        let lastGroupRequestId:String = NSUUID().uuidString
        self.lastRequestId = lastGroupRequestId
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["type"] = "group"//"home"//"discover"
        parameter["page"] = JSON(1 as Any).stringValue
        parameter["unit"] = "mi"
        if !(searchField == nil || searchField.text == "") {
            parameter["search"] = searchField.text
        }
        
        
        //var parameter = Dictionary<String,Any>()
        //parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        //parameter["page"] = JSON(1 as Any).stringValue
        
        //GlobalFunctions.shared.addLoader()
        ApiManger.init().makeRequest(method: .GetExploreData/*.GetPopularUsers*/,
                                     parameter: parameter,
                                     withLoaderText: APILoaderText.Loading)
        { (jsonResponse, responseStatus, error, statusCode) in
            if lastGroupRequestId != self.lastRequestId {
                return
            }
            
            self.tableView?.isHidden = false
            
            GlobalFunctions.shared.removeLoader()
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                print(response[kData])
                let dict = response[kData]
                self.loadGroupData(arrData: JSON(dict[kData] as Any).arrayObject)
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func getEventListAPI() {
        let lastEventRequestId:String = NSUUID().uuidString
        self.lastRequestId = lastEventRequestId
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["type"] = "event"//"home"//"discover"
        parameter["page"] = JSON(1 as Any).stringValue
        parameter["unit"] = "mi"
        if !(searchField == nil || searchField.text == "") {
            parameter["search"] = searchField.text
        }
        //var parameter = Dictionary<String,Any>()
        //parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        //parameter["page"] = JSON(1 as Any).stringValue
        
        //GlobalFunctions.shared.addLoader()
        ApiManger.init().makeRequest(method: .GetExploreData/*.GetPopularUsers*/,
                                     parameter: parameter,
                                     withLoaderText: APILoaderText.Loading)
        { (jsonResponse, responseStatus, error, statusCode) in
            if lastEventRequestId != self.lastRequestId {
                return
            }
            
            self.tableView?.isHidden = false
            
            GlobalFunctions.shared.removeLoader()
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                print(response[kData])
                let dict = response[kData]
                self.loadEventData(arrData: JSON(dict[kData] as Any).arrayObject)
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func loadGroupData(arrData:Array<Any>?){
        if arrData != nil {
            for item in arrData!{
                let vide = Groups.init(fromJson: JSON(item))
                self.groups.append(vide)
            }
        }
        tableView?.reloadData()
    }
    
    func loadEventData(arrData:Array<Any>?){
        if arrData != nil {
            for item in arrData!{
                let vide = Event.init(fromJson: JSON(item))
                self.events.append(vide)
            }
        }
        tableView?.reloadData()
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Delegate Methods -
    
    @IBAction func searchTextDidChangeHandler(_ sender: UITextField) {
        update()
        
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        update()
        
        return true
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Action Methods -
    
    @IBAction func ckearTapHandler(_ sender: UIButton) {
        searchField.text = ""
        view.endEditing(true)
        update()
    }
    
    @IBAction func backTapHandler(_ sender: UIButton) {
        navigationController?.popViewController(animated: false)
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
        
        searchField.becomeFirstResponder()
//        searchField.clearButtonMode = .always
        tableView?.registerCell(UserTVCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
        update()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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

extension SearchSocialListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedType == 0 {
            let vc = Group.VC("GroupDetailsVC") as! GroupDetailsVC
            vc.currentGroup = groups[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = EventS.VC("EventDetailsVC") as! EventDetailsVC
            vc.currentEvent = events[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

//        return UITableView.automaticDimension
//    }
    
}

    // MARK: - UITableViewDataSource

extension SearchSocialListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedType == 0 {
            return groups.count
        }
        else
        if selectedType == 1 {
            return events.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedType == 0 {
            let cell = tableView.reusableCell(UserTVCell.self)
            cell.avatarImageView.layer.cornerRadius = 8
            cell.avatarImageView.layer.borderColor = kKeyColor?.cgColor
            cell.avatarImageView.layer.borderWidth = 1.0
            let group = groups[indexPath.row]
            cell.usernameLabel.text = group.groupName
            cell.cityLabel.text = group.location
            
            if group.imageData.count > 0 {
                cell.avatarImageView.sd_setImage(with: URL(string: group.imageData[0].image),
                placeholderImage: PostTVCell.placeHolder)
            }
            else {
                cell.avatarImageView.image = PostTVCell.placeHolder
            }
            cell.followButton.isHidden = true
            //cell.dataObject3 = (users[indexPath.row], indexPath)
            //cell.followButton.addTarget(self, action: #selector(followTapHandler(_:)), for: .touchUpInside)
            return cell
        }
        else
        if selectedType == 1 {
            let cell = tableView.reusableCell(UserTVCell.self)
            cell.avatarImageView.layer.cornerRadius = 0
            cell.avatarImageView.layer.borderWidth = 0.0
            let event = events[indexPath.row]
            cell.usernameLabel.text = event.eventTitle
            cell.cityLabel.text = event.location
            
            cell.avatarImageView.sd_setImage(with: URL(string: event.image),
                                        placeholderImage: HeaderAccountTVCell.avatarPlaceholder)
            
            cell.followButton.isHidden = true
            //cell.dataObject = cars[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
}

extension SearchSocialListVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == menuCollection {
            selectedType = indexPath.row
            socialVC.segmentedView.setActive(selectedType, false)
            socialVC.currentPage = 1
            searchField.placeholder = selectedType == 0 ? "Groups" : "Events"
            update()
            menuCollection.reloadData()
            return
        }
        
    }
}

extension SearchSocialListVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == menuCollection {
            return menu.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView == menuCollection {
            return UICollectionReusableView()
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        
        
        return CGSize(width: 200, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == menuCollection{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath)
            cell.backgroundView?.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            let title = cell.contentView.viewWithTag(2) as! UILabel
            let selectedView = cell.contentView.viewWithTag(100)
            title.text = menu[indexPath.row].title.uppercased()
            if selectedType == indexPath.row {
                title.textColor = .white
                selectedView!.isHidden = false
            }
            else {
                title.textColor = .white
                selectedView!.isHidden = true
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension SearchSocialListVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == menuCollection {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.font = UIFont(name: "Montserrat-ExtraBold", size: 17)
            label.text = menu[indexPath.row].title
            label.sizeToFit()
            return CGSize(width: SCREEN_WIDTH_2, height: 60)
        }
        
        let width = Float(collectionView.frame.size.width / 2 - 36)
        return CGSize(width: CGFloat(width), height: CGFloat(width))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == menuCollection {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        return UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
    }
}
