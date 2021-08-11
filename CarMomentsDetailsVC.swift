
import UIKit
import AWSS3

class CarMomentsDetailsVC: BaseVC {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: ActiveLabel!
    @IBOutlet weak var tagsLabel: ActiveLabel!
    @IBOutlet weak var moreButton: UIButton!
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Class Variables -
    
    let myGroup = DispatchGroup()
    var moment: MomentModel!
    var momentID: String?
    var myMoment = false
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods -
    
    //-------------------------------------------------------------------------------------
    
    //MARK: - API Validation
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - API Methods -
    
    func momentAPI() {
    
         var parameter = Dictionary<String,Any>()
         parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
         parameter["type"] = "motorshow"
        parameter["moment_id"] = momentID
         //parameter["moment_id"] = JSON(self.arrStory[index].vehiclesDetail?.id as Any).stringValue
         
         ApiManger.init().makeRequest(method: .GetMoment ,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
             
             if error != nil {
                 GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                 return
             }
             
             let response = JSON(jsonResponse)
             switch statusCode {
                 
             case .SuccessResponse:
                 print(response[kData])
                 
                 
                 self.moment = MomentModel.init(fromJson: JSON(response[kData] as Any))
                 self.update()
                
             default:
                 debugPrint("")
                 GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
             }
         }
     }
    
    func editTap(_ index: Int) {
        let vc = Moments.VC("CreateMomentVC") as! CreateMomentVC
        //vc.currentCar = currentCar
        vc.createCarID = moment.vehicleId
        vc.currentMoment = moment
        vc.edit = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func deleteMoment() {
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["moment_id"] = moment.id
        //parameter["page"] = JSON(self.currentPage as Any).stringValue
        
        ApiManger.init().makeRequest(method: .DeleteMoment,parameter:parameter, withLoader : false) { (jsonResponse, responseStatus, error, statusCode) in
            
            //self.refreshControl.endRefreshing()
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            
            switch statusCode {
            case .SuccessResponse:
                print(JSON(response[kData] as Any))
                GlobalFunctions.shared.showAlertWithBlock(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self, completion: { (finish) in
                    self.navigationController?.popViewController(animated: true)
                })
                //MyGarages(fromJson: JSON(response[kData] as Any))
                
            case .NoDataFound:
                print("no data")
                //self.tableView.reloadData()
                
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
    
    @IBAction func moreTapHandler(_ sender: UIButton) {
        
        if myMoment {
            let controller = UIAlertController(title: "More",
                                               message: "", preferredStyle: .actionSheet)
            controller.addAction(UIAlertAction(title: "Edit", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                self.editTap(sender.tag)
            }))
            controller.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
                self.deleteMoment()
            }))
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in }))
            present(controller, animated: true, completion: {() -> Void in })
        }
        
    }
    
    @IBAction func shareTapHandler(_ sender: UIButton) {
        
        GlobalFunctions.shared.shareMomentText(self.moment)
        /*
        let controller = UIAlertController(title: "Share",
                                           message: "", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Repost to your Feed", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            
        }))
        controller.addAction(UIAlertAction(title: "Share", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            GlobalFunctions.shared.shareMomentText(self.moment)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in }))
        present(controller, animated: true, completion: {() -> Void in })*/
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
    
    func update() {
        
        titleLabel.isHidden = false
        descriptionLabel.isHidden = false
        dateLabel.isHidden = false
        addressLabel.isHidden = false
        tagsLabel.isHidden = false
        mainImageView.isHidden = false
        
        myMoment = User.shared?.id == Int(moment.user_id)
        if !myMoment {
            moreButton.isHidden = true
        }
        
        titleLabel.text = moment.title.uppercased()
        dateLabel.text = "\(moment.month ?? "") \(moment.year ?? "")"
        addressLabel.text = moment.location
        
        if moment.mediaData.count > 0 {
            mainImageView.sd_setImage(with: URL(string: moment.mediaData![0].strImage),
                                      placeholderImage: PostTVCell.placeHolder)
        }
        else {
            mainImageView.image = PostTVCell.placeHolder
        }
        
        descriptionLabel.text = moment.descriptionField
        descriptionLabel.mentionColor = kKeyColor!
        descriptionLabel.handleMentionTap{(mention) in
            GAPIMethods.shared.getUserIdAPI(username: mention) { (userId) in
              if let userId = userId {
                GlobalFunctions.shared.showProfile(self, userId.intValue)
              }
            }
        }

        descriptionLabel.URLColor = kKeyColor!
        descriptionLabel.handleURLTap({(url) in
            GlobalFunctions.shared.urlOpen(url.absoluteString)
        })

        descriptionLabel.hashtagColor = kKeyColor!
        descriptionLabel.handleHashtagTap{(mention) in
            let vc = Lists.VC("TagsListVC") as! TagsListVC
            vc.selectedType = .moment
            vc.currentTag = mention
            vc.title = mention
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        tagsLabel.text = moment.tagsDetail.compactMap{$0.tags.hashTag()}.joined(separator: " ")
        tagsLabel.enabledTypes = [.hashtag]
        tagsLabel.hashtagColor = kKeyColor!
        tagsLabel.handleHashtagTap{(mention) in
            let vc = Lists.VC("TagsListVC") as! TagsListVC
            vc.selectedType = .moment
            vc.currentTag = mention
            vc.title = mention
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if momentID == nil {
            update()
        }
        else {
            titleLabel.isHidden = true
            descriptionLabel.isHidden = true
            dateLabel.isHidden = true
            addressLabel.isHidden = true
            tagsLabel.isHidden = true
            mainImageView.isHidden = true
            momentAPI()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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



