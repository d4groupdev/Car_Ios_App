
import UIKit

class StoryListVC: BaseVC {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: UITableView!
    var currentPage = 1
    var isWebCalling = false
    var refreshControl = UIRefreshControl()
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Class Variables -
    
    var arrStory: [StoryModel] = []
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods -
    
    //-------------------------------------------------------------------------------------
    
    //MARK: - API Validation
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - API Methods -
    
    func likeVehicleAPI(isLike:Bool, index: Int) {
    
         var parameter = Dictionary<String,Any>()
         parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
         parameter["type"] = "motorshow"
         parameter["global_id"] = JSON(self.arrStory[index].vehiclesDetail?.id as Any).stringValue
         
         ApiManger.init().makeRequest(method: .LikeCar ,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
             
             if error != nil {
                 GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                 return
             }
             
             let response = JSON(jsonResponse)
             switch statusCode {
                 
             case .SuccessResponse:
                 print(response[kData])
                 
                 if !isLike{
                     self.arrStory[index].vehiclesDetail.isLike! = 1
                     self.arrStory[index].vehiclesDetail.likeCount! += 1
                     let cell = self.tableView?.cellForRow(at: IndexPath(row: index, section: 0)) as! StoryTVCell
                     cell.likeUpdate(self.arrStory[index])
                     
                 } else {
                     self.arrStory[index].vehiclesDetail.isLike! = 0
                     self.arrStory[index].vehiclesDetail.likeCount! -= 1
                     let cell = self.tableView?.cellForRow(at: IndexPath(row: index, section: 0)) as! StoryTVCell
                     cell.likeUpdate(self.arrStory[index])
                 }
             default:
                 debugPrint("")
                 GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
             }
         }
     }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Delegate Methods -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.isAtTop{
            
        }else if scrollView.isAtBottom {
            if self.isWebCalling {
                self.isWebCalling = false
                self.currentPage += 1
                debugPrint(".......call \(self.currentPage) page.....")
                self.getNormalStoryList()
            }
        }
    }

    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Action Methods -
    
    @IBAction func backTapHandler(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func likeTapHandler(_ sender: UIButton) {
        if let like = arrStory[sender.tag].vehiclesDetail.isLike {
            likeVehicleAPI(isLike: like == 0 ? false : true, index: sender.tag)
        }
    }
    
    @objc func messageTapHandler(_ sender: UIButton) {
        let vc = CommentsS.VC("CommentsVC") as! CommentsVC
        vc.commentType = .MOTORSHOW
        vc.currentVehicle = arrStory[sender.tag].vehiclesDetail
        vc.hideTabBar()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func favoriteTapHandler(_ sender: UIButton) {
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["type"] = "motorshow"
        parameter["global_id"] = JSON(self.arrStory[sender.tag].vehicleId as Any).stringValue
        ApiManger.init().makeRequest(method: .MakeFavorites ,parameter:parameter, withLoader : false, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                if !JSON(self.arrStory[sender.tag].isFavourite as Any).boolValue{
                    sender.isSelected = true
                    self.arrStory[sender.tag].isFavourite = "1"
                } else {
                    sender.isSelected = false
                    self.arrStory[sender.tag].isFavourite = "0"
                    return
                }
                
                let cell = self.tableView!.cellForRow(at: IndexPath(item: sender.tag, section: 1)) as? StoryTVCell
                cell?.favoriteUpdate(self.arrStory[sender.tag])
                
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    @objc func playVideo(_ button: UIButton) {
        
        let obj = arrStory[button.tag]
        if let data = obj.mediaData, let media = data.first {
            UIApplication.topViewController?.playVideo(link: media.media)
        }
    }
    
    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        if refreshControl.isRefreshing {
            currentPage = 1
            getNormalStoryList()
        }
    }
    
    func getNormalStoryList() {
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["type"] = "normal"
        parameter["page"] = JSON(self.currentPage as Any).stringValue
        
        ApiManger.init().makeRequest(method: .GetStoryList,parameter:parameter, withLoader : false) { (jsonResponse, responseStatus, error, statusCode) in
            
            self.refreshControl.endRefreshing()
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            
            switch statusCode {
            case .SuccessResponse:
                
                self.tableView.isHidden = false
                
                let dict = JSON(response[kData] as Any).dictionaryValue
                if self.currentPage == 1 {
                    self.arrStory.removeAll()
                }
                let arrData = StoryModel.modelsFromDictionaryArray(array: dict[kData]!.arrayValue)
                self.arrStory += arrData
                self.isWebCalling = !arrData.isEmpty
                self.tableView.reloadData()
                
            case .NoDataFound:
                print("no data")
                self.tableView.reloadData()
                
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
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
        
        tableView.isHidden = true
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView?.isHidden = true
        tableView?.refreshControl = refreshControl
        tableView?.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: kFooterTableViewHeight))
        
        tableView.registerCell(StoryTVCell.self)
       // getNormalStoryList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNormalStoryList()
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

extension StoryListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = Cars.VC("CarDetailsVC") as! CarDetailsVC
        vc.car = arrStory[indexPath.row].vehiclesDetail
        vc.story = arrStory[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

    // MARK: - UITableViewDataSource

extension StoryListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.reusableCell(StoryTVCell.self)
        cell.dataObject = arrStory[indexPath.row]
        
        //let obj = arrStory[indexPath.row]
        
        //if let data = obj.mediaData, let media = data.first {
          //  cell.mainImageView.handleTapToAction {
           //     UIApplication.topViewController?.playVideo(link: media.media)
            //}
        //}
        
        cell.descriptionLabel.handleHashtagTap{(mention) in
            let vc = Lists.VC("TagsListVC") as! TagsListVC
            vc.currentTag = mention
            vc.selectedType = .car
            vc.title = mention
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.descriptionLabel.handleURLTap({(url) in
            GlobalFunctions.shared.urlOpen(url.absoluteString)
        })
        
        cell.descriptionLabel.handleMentionTap { (mention) in
            GAPIMethods.shared.getUserIdAPI(username: mention) { (userId) in
              if let userId = userId {
                GlobalFunctions.shared.showProfile(self, userId.intValue)
              }
            }
        }
        
        cell.messageButton.tag = indexPath.row
        cell.messageButton.addTarget(self, action: #selector(messageTapHandler), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likeTapHandler), for: .touchUpInside)
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteTapHandler), for: .touchUpInside)
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playVideo(_:)), for: .touchUpInside)
        return cell
    }
    
}
