
import UIKit
import ImageSlideshow

class CarDetailsVC: BaseVC {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var tableTopConstraint : NSLayoutConstraint!
    @IBOutlet weak var navBarConstraint : NSLayoutConstraint!
    @IBOutlet weak var activityCell : CarActivityTVCell!
    @IBOutlet weak var titleDescriptionCell : CarTitleDescriptionTVCell!
    
    //MARK: - Class Variables -
    
    var imageScrollView: UIScrollView?
    var modsCollectionView: UICollectionView?
    var sponsorsCollectionView: UICollectionView?
    var headerTableViewCell: CarHeaderTVCell?
    //var momentsCollectionView: UICollectionView?
    
    //var mods: [String] = []
    //var moments: [String] = []
    //var sponsors: [Invities] = []
    var topSafeArea: CGFloat! = 0.0
    
    var comments : [Comments] = []
    
    var carID: String?
    var car: VehicleDetails?
    var story: StoryModel?
    
    var refreshControl = UIRefreshControl()
    var currentPage = 1
    var isService = false
    var commentsCounter = 0
    var isMyCar = true
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods -
    
    private func titleText() -> String {
        if let story = story {
            return story.title
        }

        return car?.headline ?? ""
    }
    
    private func descriptionText()  -> String  {
        if let story = story {
            return story.descriptionField
        }

        return car?.aboutCar ?? ""
    }
    
    //-------------------------------------------------------------------------------------
    
    //MARK: - API Validation
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - API Methods -
    
    func likeVehicleAPI(isLike:Bool) {
   
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["type"] = "motorshow"
        parameter["global_id"] = JSON(self.car?.id as Any).stringValue
        
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
                    self.car?.isLike! = 1
                    self.car?.likeCount! += 1
                    self.activityCell.likeUpdate(self.car!)
                    
                } else {
                    self.car?.isLike! = 0
                    self.car?.likeCount! -= 1
                    self.activityCell.likeUpdate(self.car!)
                }
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func favoriteVehicleAPI(isFav:Bool) {
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["type"] = "motorshow"
        parameter["global_id"] = JSON(self.car?.vehicleId as Any).stringValue
        
        ApiManger.init().makeRequest(method: .MakeFavorites ,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                print(response[kData])
                
                if !isFav{
                    self.titleDescriptionCell.favoriteButton.isSelected = true
                    self.car?.isFavourite = 1
                } else {
                    self.titleDescriptionCell.favoriteButton.isSelected = false
                    self.car?.isFavourite = 0
                }
                
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
    
    @objc func didTap() {
        if headerTableViewCell != nil {
            let fullScreenController = headerTableViewCell?.slideshow.presentFullScreenController(from: self)
            // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
            fullScreenController?.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
        }
    }
    
    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        if refreshControl.isRefreshing {
            currentPage = 1
            //updateData(customSegmented?.segmentedView.selectedIndex ?? 0)
        }
    }
    
    @IBAction func editTapHandler(_ sender: UIButton) {
        if isMyCar {
            let vc = Cars.VC("CreateCar1VC") as! CreateCar1VC
            vc.hideTabBar()
            vc.editedCar = car
            vc.title = "Edit a car"
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let motor = UIAlertAction(title: "Report Vehicle as Fake", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                GAPIMethods.shared.makeReportAPI(userId: JSON(User.shared?.id as Any).stringValue,
                                                 globalID: JSON(self.car?.vehicleId as Any).stringValue,
                                                 type: "vehicle",
                                                 comment: "Report Vehicle as Fake") { (response) in
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel" , style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(motor)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    @IBAction func showMoreTapHandler(_ sender: UIButton) {
        if sender.tag == 2 {
            if isMyCar && car!.moments.count == 0 {
                let vc = Moments.VC("CreateMomentVC") as! CreateMomentVC
                //vc.currentMoment = car?.moments[index]
                vc.create = true
                vc.createCarID = car?.id
                navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = Lists.VC("MomentsListVC") as! MomentsListVC
                vc.car = car
                //vc.moments = car?.moments ?? []
                navigationController?.pushViewController(vc, animated: true)
            }
        } else if sender.tag == 3 {
            if isMyCar {
                let vc = Account.VC("ShowAllSponsorsVC") as! ShowAllSponsorsVC
                vc.isMyCar = isMyCar
                vc.car = car
                navigationController?.pushViewController(vc, animated: true)
            }
            else {
                let vc = Account.VC("ShowAllOtherSponsorsVC") as! ShowAllOtherSponsorsVC
                vc.sponsors = car?.sponsers ?? []
                vc.car = car
                navigationController?.pushViewController(vc, animated: true)
            }
            //
            
        }
    }
    
    @IBAction func backTapHandler(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func likeTapHandler(_ sender: UIButton) {
        
        if let like = car?.isLike {
            likeVehicleAPI(isLike: like == 0 ? false : true)
        }
    }
    
    @IBAction func favoriteTapHandler(_ sender: UIButton) {
        
        if let fav = car?.isFavourite {
            favoriteVehicleAPI(isFav: fav == 0 ? false : true)
        }
    }
    
    @IBAction func playStoryTapHandler(_ sender: UIButton) {
        
        let obj = story
        if obj?.youtube != "" {
            let vc = PostS.VC("YoutubePlayerVC") as! YoutubePlayerVC
            vc.youtubeID = obj?.youtube
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = .fullScreen
            self.present(nvc, animated: true, completion: {})
        }
        else {
            if let data = story?.mediaData, let media = data.first {
                UIApplication.topViewController?.playVideo(link: media.media)
            }
        }
        
    }
    
   
    @IBAction func shareTapHandler(_ sender: UIButton) {
        //shareCarText
        
        GlobalFunctions.shared.shareCarText(self.car!)
        
        /*
        let controller = UIAlertController(title: "Share",
                                           message: "", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Repost to your Feed", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            
        }))
        controller.addAction(UIAlertAction(title: "Share", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            GlobalFunctions.shared.shareCarText(self.car!)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            
        }))
        present(controller, animated: true, completion: {() -> Void in })*/
    }
    
    @objc @IBAction func followTapHandler(_ sender: UIButton) {
        
        followAPI(isFollow: JSON(self.car?.isFollowing as Any).boolValue)
    }
    
    @objc @IBAction func addCommentTapHandler(_ sender: UIButton) {
        let vc = CommentsS.VC("CommentsVC") as! CommentsVC
        //if story != nil {
          //  vc.commentType = .STORY
          //  vc.currentStory = story
        //}
        //else {
            vc.commentType = .MOTORSHOW
            vc.currentVehicle = car
        //}
        vc.hideTabBar()
        vc.addComment = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc @IBAction func showAllCommentsTapHandler(_ sender: UIButton) {
        let vc = CommentsS.VC("CommentsVC") as! CommentsVC
        //if story != nil {
          //  vc.commentType = .STORY
          //  vc.currentStory = story
        //}
        //else {
            vc.commentType = .MOTORSHOW
            vc.currentVehicle = car
        //}
        vc.hideTabBar()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func btnParentLike(sender: CustomBtn){
        self.likeCommentAPI(sender: sender)
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Style Methods -
    
    override func styleLoad() {
        super.styleLoad()
        
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - View Life Cycle Methods -
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            topSafeArea = view.safeAreaInsets.top
        } else {
            topSafeArea = topLayoutGuide.length
        }
        
        //tableTopConstraint.constant = -topSafeArea
        navBarConstraint.constant = topSafeArea
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.isHidden = true
        
        isMyCar = car?.userId == User.shared?.user_id
        
        //tableView?.isHidden = true
        //refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        //tableView?.refreshControl = refreshControl
        
        tableView?.registerCell(CommentTVCell.self)
        tableView?.registerCell(AddNewCommentTVCell.self)
        tableView?.registerCell(CarOwnerTVCell.self)
        
        
        
        //getCommentListAPI()
        
        tableView?.tableFooterView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: kFooterTableViewHeight))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        if story != nil {
            getStoryDetailsAPI()
        }
        else {
            getVehicleDetailsAPI()
        }
        //tableView?.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
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

extension CarDetailsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 9 {
                GlobalFunctions.shared.showProfile(self,  JSON(car?.userId as Any).intValue)
            }
        }
        
        if indexPath.section == 2 {
            let vc = Moments.VC("CarMomentsDetailsVC") as! CarMomentsDetailsVC
            vc.moment = car!.moments[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        else if section == 1 {
            let cell = tableView.reusableCell(SectionHeaderTVCell.self)
            cell.titleLabel.text = "Mods"
            cell.showMoreButton.setTitle("Show all", for: .normal)
            cell.showMoreButton.isHidden = true
            cell.showMoreButton.tag = 1
            return cell
        }
        else if section == 2 {
            let cell = tableView.reusableCell(SectionHeaderTVCell.self)
            cell.titleLabel.text = "Moments and Awards"
            cell.showMoreButton.setTitle("Show all", for: .normal)
            if isMyCar && car!.moments.count == 0 {
                cell.showMoreButton.setTitle("Add a moment", for: .normal)
            }
            cell.showMoreButton.isHidden = false
            cell.showMoreButton.tag = 2
            return cell
        }
        else if section == 3 {
            let cell = tableView.reusableCell(SectionHeaderTVCell.self)
            cell.titleLabel.text = "Auto Partners"
            cell.showMoreButton.setTitle("Show all", for: .normal)
            cell.showMoreButton.isHidden = false
            cell.showMoreButton.tag = 3
            return cell
        }
        else if section == 4 {
            let cell = tableView.reusableCell(FeaturedUsersHeaderTVCell.self)
            return cell
        }
        else if section == 5 {
            let cell = tableView.reusableCell(CommentsHeaderTVCell.self)
            cell.commentsCounterLabel.text = "(\(commentsCounter))"
            return cell
        }
        else if section == 6 {
            let cell = tableView.reusableCell(AddNewCommentTVCell.self)
            cell.addButton.addTarget(self, action: #selector(addCommentTapHandler), for: .touchUpInside)
            cell.addBigButton.addTarget(self, action: #selector(addCommentTapHandler), for: .touchUpInside)
            cell.avatarImageView.sd_setImage(with: URL(string: User.shared!.profileImage),
                                             placeholderImage: HeaderAccountTVCell.avatarPlaceholder)
            return cell
        }
        /*
        else if section == 5 {
            let cell = tableView.reusableCell(SectionHeaderTVCell.self)
            cell.titleLabel.text = "Comments"
            cell.showMoreButton.setTitle("Show all", for: .normal)
            cell.showMoreButton.isHidden = false
            cell.showMoreButton.tag = 4
            return cell
        }*/
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.0
        }
        
        if section == 1 {
            if car?.modificationDetail.count == 0 {
                return 0.0
            }
        }
        
        if section == 2 {
            //if car!.moments.count == 0 {
              //  return 0.0
            //}
        }
        
        if section == 3 {
            //if isMyCar {
              //  return UITableView.automaticDimension
            //}
            //if car!.sponsers.count == 0 {
              //  return 0.0
            //}
        }
        
        if section == 4 {
            return 0
            /*
            if story == nil {
                return 0
            }
            if story?.refferFriends.count == 0 {
                return 0
            }
            return 54.0*/
        }
        
        if section == 5 {
            if comments.count == 0 {
                return 0
            }
            return 54.0
        }
        
        if section == 6 {
            return 54.0
        }
        
        return 44.0//UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //if isPrivate {
          //  if indexPath.row == 0 {
            //    return 350
            //}
       // }
        
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                if story != nil {
                    return 54.0
                }
                else {
                    return 0.0
                }
            }
            
            if indexPath.row == 4 {
                if car?.modelName?.isEmpty ?? true {
                    return 0.0
                }
            }
            if indexPath.row == 5 {
                return 0.0
                //if car?.model_variant == "" {
                  //  return 0.0
                //}
            }
            //remove type
            if indexPath.row == 7 {
                
                return 0.0
            }
            if indexPath.row == 8{
                if titleText().isEmpty {
                    return 0
                }
            }
            if indexPath.row == 9 {
                return car?.userId == JSON(User.shared?.id as Any).stringValue ? 0.0 : 54.0
            }
            
            if indexPath.row == 10 {
                if descriptionText().isEmpty {
                    return 0
                }
            }
            
            if indexPath.row == 12 {
                if car?.tagsDetail.count == 0 {
                    return 0
                }
            }
            //comments
        }
        
        //if indexPath.section == 1 {
          //  return 100
        //}
        
        return UITableView.automaticDimension
    }
}

    // MARK: - UITableViewDataSource

extension CarDetailsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 13
        }
        
        if section == 1 {
            if car?.modificationDetail?.isEmpty ?? true {
                return 0
            }
            return 1
        }
        
        if section == 2 {
            if let count = car?.moments?.count, 5 < count{
                return 5
            }
            
            return car?.moments?.count ?? 0
        }
        
        if section == 3 {
            if car?.sponsers?.isEmpty ?? true{
                if isMyCar {
                    return 1
                }
                
                return 0
            }
            
            return 1//car!.sponsers.count
        }
        
        if section == 4 {
            return 0
            /*
            if story == nil {
                return 0
            }
            if story?.refferFriends.count == 0 {
                return 0
            }
            return story?.refferFriends.count ?? 0*/
        }
        
        if section == 5 {
            if comments.count > 3 {
                return 3
            }
            return comments.count
        }
        
        if section == 6 {
            return 0
        }
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        if indexPath.section == 1 {
            let cell = tableView.reusableCell(FeaturedUsersTVCell.self)
            cell.followButton.tag = indexPath.row
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.reusableCell(CommentTVCell.self)
            cell.dataObject = (comments[indexPath.row], indexPath.row, self)
            cell.showMoreButton.isHidden = true
            return cell
        }*/
        
        if indexPath.section == 5 {
            let cell = tableView.reusableCell(CommentTVCell.self)
            cell.dataObject = (comments[indexPath.row], indexPath.row, self)
            cell.showMoreButton.isHidden = true
            return cell
        }
        
        if indexPath.section == 4 {
            let cell = tableView.reusableCell(FeaturedUsersTVCell.self)
            let user = story?.refferFriends[indexPath.row]
            cell.setFollow(user?.is_following == 0)
            if let profileImage = user?.profileImage {
                cell.avatarImageView.sd_setImage(with: URL(string: profileImage))
            }
            else {
                cell.avatarImageView.image = HeaderAccountTVCell.avatarPlaceholder
            }
            cell.usernameLabel.text = user?.username
            cell.followButton.tag = indexPath.row
            cell.followButton.isHidden = user?.userId == User.shared?.user_id
            return cell
        }
        
        if indexPath.section == 3 {
            let cell = tableView.reusableCell(ParameterTVCell.self)
            sponsorsCollectionView = cell.collectionView
            sponsorsCollectionView?.reloadData()
            return cell
        }
        
        if indexPath.section == 2 {
            let cell = tableView.reusableCell(CarMomentsAndAvardsTVCell.self)
            cell.dataObject = car?.moments[indexPath.row]
            return cell
        }
        
        if indexPath.section == 1 {
            let cell = tableView.reusableCell(ParameterTVCell2.self)
            modsCollectionView = cell.collectionView
            modsCollectionView?.reloadData()
            return cell
        }
        
        //
        
        if indexPath.row == 0 {
            let cell = tableView.reusableCell(CarHeaderTVCell.self)
            headerTableViewCell = cell
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
            cell.slideshow.addGestureRecognizer(recognizer)
            //cell.isStory = story != nil
            cell.story = story
            cell.dataObject = car
            if !isMyCar {
                cell.editButton.setImage(UIImage(named: "more-vertical-icon"), for: .normal)
                cell.editButton.isHidden = (nil != self.story)
            }
            //cell.editButton.tag = indexPath.row
            return cell
        }
        else
        if indexPath.row == 1 {
            let cell = tableView.reusableCell(FeatureLineTVCell.self)
            return cell
        }
        else
        if indexPath.row == 2 {
            let cell = tableView.reusableCell(CarHeaderParameterTVCell.self)
            cell.dataObject = car
            return cell
        }
        else
        if indexPath.row == 3 {
            let cell = tableView.reusableCell(CarParameterTVCell.self)
            cell.parameterLabel.text = "Make: \(car?.brandName ?? "")"
            return cell
        }
        else
        if indexPath.row == 4 {
            let cell = tableView.reusableCell(CarParameterTVCell.self)
            cell.parameterLabel.text = "Model: \(car?.modelName ?? "")"
            return cell
        }
        else
        if indexPath.row == 5 {
            let cell = tableView.reusableCell(CarParameterTVCell.self)
            cell.parameterLabel.text = "Trim: \(car?.model_variant ?? "")"
            return cell
        }
        else
        if indexPath.row == 6 {
            let cell = tableView.reusableCell(CarParameterTVCell.self)
            cell.parameterLabel.text = "Engine: \(car?.engine ?? "")"
            return cell
        }
        else
        if indexPath.row == 7 {
            let cell = tableView.reusableCell(CarParameterTVCell.self)
            cell.parameterLabel.text = "\(car?.type ?? "") car"
            return cell
        }
        else
        if indexPath.row == 8 {
            let cell = tableView.reusableCell(CarTitleDescriptionTVCell.self)
            titleDescriptionCell = cell
            cell.titleLabel.text = titleText()
            cell.favoriteButton.isSelected = car?.isFavourite == 0 ? false : true
            cell.favoriteButton.isHidden = car?.headline == ""
            
            //cell.favoriteButton.isHidden = isMyCar
            return cell
        }
        else
        if indexPath.row == 9 {
            let cell = tableView.reusableCell(CarOwnerTVCell.self)
            cell.usernameLabel.text = car?.username
            if let image1 = car?.profileImage {
                cell.avatarImageView.sd_setImage(with: URL(string: image1),
                                                 placeholderImage: HeaderAccountTVCell.avatarPlaceholder)
            }
            else {
                cell.avatarImageView.image = HeaderAccountTVCell.avatarPlaceholder
            }
            
            cell.followButton.isHidden = isMyCar
            if car?.isFollowing == 0 {
                cell.followButton.backgroundColor = kKeyColor
                cell.followButton.setTitleColor(.white, for: .normal)
                cell.followButton.setTitle("Follow", for: .normal)
            }
            else {
                cell.followButton.backgroundColor = .clear
                cell.followButton.setTitleColor(kKeyColor, for: .normal)
                cell.followButton.setTitle("Unfollow", for: .normal)
            }
            cell.followButton.addTarget(self, action: #selector(followTapHandler), for: .touchUpInside)
            
            return cell
        }
        else
        if indexPath.row == 10 {
            let cell = tableView.reusableCell(CarDescriptionTVCell.self)
            cell.descriptionLabel.text = descriptionText()
            cell.descriptionLabel.textColor = kTextColor
            cell.descriptionLabel.enabledTypes = [.hashtag, .mention, .url]
            cell.descriptionLabel.mentionColor = kKeyColor!
            cell.descriptionLabel.handleMentionTap { (mention) in
                GAPIMethods.shared.getUserIdAPI(username: mention) { (userId) in
                    if let userId = userId {
                        GlobalFunctions.shared.showProfile(self, userId.intValue)
                    }
                }
            }
            
            cell.descriptionLabel.URLColor = kKeyColor!
            cell.descriptionLabel.handleURLTap({(url) in
                GlobalFunctions.shared.urlOpen(url.absoluteString)
            })
            
            cell.descriptionLabel.hashtagColor = kKeyColor!
            cell.descriptionLabel.handleHashtagTap{(mention) in
                let vc = Lists.VC("TagsListVC") as! TagsListVC
                vc.selectedType = .car
                vc.currentTag = mention
                vc.title = mention
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        }
        else
        if indexPath.row == 11 {
            let cell = tableView.reusableCell(CarActivityTVCell.self)
            activityCell = cell
            cell.dataObject = car
            return cell
        }
        else
        if indexPath.row == 12 {
            let cell = tableView.reusableCell(CarDescriptionTVCell.self)
            //"#" +
            cell.descriptionLabel.text = car?.tagsDetail.compactMap{$0.tags.hashTag()}.joined(separator: " ")
            cell.descriptionLabel.textColor = kKeyColor
            cell.descriptionLabel.enabledTypes = [ActiveType.hashtag]
            cell.descriptionLabel.hashtagColor = kKeyColor!
            cell.descriptionLabel.handleHashtagTap{(mention) in
                let vc = Lists.VC("TagsListVC") as! TagsListVC
                vc.selectedType = .car
                vc.currentTag = mention
                vc.title = mention
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
}

    // MARK: - Collection view delegate

extension CarDetailsVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if sponsorsCollectionView == collectionView {
            if self.isMyCar {
                if let car = self.car, let sponsors = car.sponsers, !sponsors.isEmpty {
                    DomainLayerApi().getSponsorship(page: 1, sponsorshipIsAccepted: "1", sponsorshipId: sponsors[indexPath.row].id)
                    { (sponsorship:[VehicleDetails]?, errorMessage:String?) in
                        if let sponsorship = sponsorship {
                            let vc = Account.VC("SponsorEditDescriptionVC") as! SponsorEditDescriptionVC
                            vc.car = sponsorship.first
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        else{
                            GlobalFunctions.shared.showAlert(AppName, message: errorMessage ?? DomainLayerApi.defaultErrorMessage, view: self)
                        }
                    }
                }
            }
            else if let car = self.car, !car.sponsers.isEmpty {
                let vc = Account.VC("InviteSponsorDetailsVC") as! InviteSponsorDetailsVC
                vc.car = car
                vc.sponsor = car.sponsers[indexPath.row]
                vc.isSponsorInfoShowed = self.isMyCar
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if collectionView == modsCollectionView {
            if let modificationDetail = car!.modificationDetail {
                let mod:ModificationResponse = modificationDetail[indexPath.row]
                let vc = Cars.VC("TextVC") as! TextVC
                vc.text = mod.descriptionField
                vc.title = mod.name
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

    // MARK: - Collection view data source

extension CarDetailsVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if modsCollectionView == collectionView {
            //if car!.modificationDetail.count == 0 {
              //  return 2
            //}
            return car!.modificationDetail.count
        }
        else if sponsorsCollectionView == collectionView {
            if isMyCar {
                if car!.sponsers.count == 0 {
                    return 2
                }
            }
            //if car!.sponsers.count == 0 {
              //  return 2
            //}
            return car!.sponsers.count
        }
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if modsCollectionView == collectionView {
            if car!.modificationDetail.count == 0 {
                if indexPath.row == 0 {
                    let cell = collectionView.reusableCell(ParameterCVCell.self, indexPath)
                    cell.titleLabel.text = "Add your mods"
                    cell.mainImageView.image = #imageLiteral(resourceName: "add-skills-icon")
                    return cell
                }
                else {
                    let cell = collectionView.reusableCell(ParameterEmptyCVCell.self, indexPath)
                    
                    return cell
                }
            }
            else {
                let cell = collectionView.reusableCell(ParameterSkillCVCell.self, indexPath)
                cell.dataMod2 = car?.modificationDetail[indexPath.row]
                return cell
            }
        }
        else if sponsorsCollectionView == collectionView {
            if car!.sponsers.count == 0 {
                if indexPath.row == 0 {
                    let cell = collectionView.reusableCell(ParameterCVCell.self, indexPath)
                    cell.titleLabel.text = "Add Brands, Manufacturers and Auto Businesses you Partner with"
                    cell.mainImageView.image = #imageLiteral(resourceName: "add-invite-sponsor")
                    return cell
                }
                else {
                    let cell = collectionView.reusableCell(ParameterEmptyCVCell.self, indexPath)
                    return cell
                }
            }
            else {
                let cell = collectionView.reusableCell(ParameterDetailsCVCell.self, indexPath)
                cell.sponsorObject = car!.sponsers[indexPath.row]
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
}

extension CarDetailsVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 202, height: 117)
    }
    
}

extension CarDetailsVC {
    
    func deleteCommentAPI(sender:CustomBtn) {
        
        var parameter = Dictionary<String,Any>()
        //if story != nil {
          //  parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
          //  parameter["type"] = "story"
        //}
        //else {
            parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
            parameter["type"] = "motorshow"
        //}
        parameter["comment_id"] = JSON(self.comments[sender.sectionIndex].id as Any).stringValue
        ApiManger.init().makeRequest(method: .DeleteComment ,parameter:parameter, withLoader : false, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            let response = JSON(jsonResponse)
            switch statusCode {
            case .SuccessResponse:
                if self.story != nil {
                    self.getStoryDetailsAPI()
                }
                else {
                    self.getVehicleDetailsAPI()
                }
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func reportComment(sender: CustomBtn,comment: String) {
        
        var type = "motorshow"
        var globalId = JSON(self.car?.id as Any).stringValue
        //if story != nil {
        //    type = "story"
        //    globalId = JSON(self.story?.id as Any).stringValue
        //}
        GAPIMethods.shared.makeReportCommentAPI(userId: JSON(User.shared?.id as Any).stringValue, globalID: globalId, commentId: JSON(self.comments[sender.sectionIndex].id as Any).stringValue, type: type, comment: comment) { (json) in
        }
    }
    
    func getCommentListAPI() {
        
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        
        //if story != nil {
          //  parameter["type"] = "story"
          //  parameter["global_id"] = JSON(self.story?.id as Any).stringValue
        //}
        //else {
            parameter["type"] = "motorshow"
            parameter["global_id"] = JSON(self.car?.id as Any).stringValue
        //}
        
        ApiManger.init().makeRequest(method: .GetComments,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            self.tableView?.isHidden = false
            
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
                //GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func loadData(arrData:Array<Any>?){
        self.comments = []
        commentsCounter = arrData!.count
        if arrData != nil {
            var index = 0
            for item in arrData!{
                let cmnt = Comments.init(fromJson: JSON(item))
                self.comments.append(cmnt)
                index += 1
                if index >= 3 {
                    break
                }
            }
        }
        self.tableView?.reloadData()
    }
    
    func reportCar(sender: UIButton,comment: String) {
        //if story != nil {
         //   GAPIMethods.shared.makeReportAPI(userId: JSON(User.shared?.id as Any).stringValue,
           //                                  globalID: JSON(self.story?.id as Any).stringValue, type: "story", comment: comment) { (response) in
                                                
           // }
        //}
        //else {
            GAPIMethods.shared.makeReportAPI(userId: JSON(User.shared?.id as Any).stringValue,
                                             globalID: JSON(self.car?.id as Any).stringValue, type: "motorshow", comment: comment) { (response) in
                                                
            }
        //}
    }
    
    @objc func btnCommentMoreTapped(_ sender: CustomBtn) {
        let optionMenu = UIAlertController(title: nil, message: "Select Option", preferredStyle: .actionSheet)
        
        let delete = UIAlertAction(title: "Delete Comment", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.deleteCommentAPI(sender: sender)
        })
        
        let edit = UIAlertAction(title: "Report Comment", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            GlobalFunctions.shared.popupAlert(title: nil, message: nil, actionTitles: ["This is Offensive","Nudity","Violence","Suicide or Self Injury","Spam","Unauthorized Sales","Hate Speech"], actions: [{ (action1) in
                self.reportCar(sender: sender, comment: "This is Offensive")
                },{ (action2) in
                    self.reportComment(sender: sender, comment: "Nudity")
                },{ (action3) in
                    self.reportComment(sender: sender, comment: "Violence")
                },{ (action4) in
                    self.reportComment(sender: sender, comment: "Suicide or Self Injury")
                },{ (action5) in
                    self.reportComment(sender: sender, comment: "Spam")
                },{ (action6) in
                    self.reportComment(sender: sender, comment: "Unauthorized Sales")
                },{ (action7) in
                    self.reportComment(sender: sender, comment: "Hate Speech")
                },nil], delegate: self)
        })
        let cancelAction = UIAlertAction(title: "Cancel" , style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        let userId = JSON(self.car?.userId as Any).stringValue//story == nil ? JSON(self.car?.userId as Any).stringValue : JSON(self.story?.userId as Any).stringValue
        if userId == JSON(User.shared?.id as Any).stringValue{
            optionMenu.addAction(delete)
        }
        else {
            if self.comments[sender.sectionIndex].userId == JSON(User.shared?.id as Any).stringValue{
                optionMenu.addAction(delete)
            }
        }
        if self.comments[sender.sectionIndex].userId != JSON(User.shared?.id as Any).stringValue{
            optionMenu.addAction(edit)
        }
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func likeCommentAPI(sender:CustomBtn) {
        var parameter = Dictionary<String,Any>()
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        parameter["type"] = "motorshow"//story == nil ? "motorshow" : "story"
        parameter["comment_id"] = JSON(self.comments[sender.tag].id as Any).stringValue
        ApiManger.init().makeRequest(method: .LikeComment ,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                print(response[kData])
                if !JSON(self.comments[sender.tag].isLike as Any).boolValue{
                    //sender.isSelected = true//setTitle("Following", for: .normal)
                    self.comments[sender.tag].likeCount! += 1
                    self.comments[sender.tag].isLike = 1
                } else {
                    //sender.isSelected = false
                    self.comments[sender.tag].likeCount! -= 1
                    self.comments[sender.tag].isLike = 0
                }
                self.tableView?.reloadData()
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func getStoryDetailsAPI() {
        
        var parameter = Dictionary<String,Any>()
        parameter["story_id"] = story?.storyId
        parameter["user_id"] = story?.userId
        ApiManger.init().makeRequest(method: .StoryDetails, parameter:parameter,withLoader: false, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
            case .SuccessResponse:
                self.story = StoryModel(fromJson: JSON(response[APIResponseKey.Data]))
                self.tableView?.reloadData()
                self.getCommentListAPI()
            default:
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
    
    func getVehicleDetailsAPI() {
        
        if let carId = car?.vehicleId {
            DomainLayerApi().getVehicle(withId: carId) { (carDetail:VehicleDetails?, message:String?) in
                if let carDetail = carDetail {
                    self.car = carDetail
                    self.tableView?.reloadData()
                    self.getCommentListAPI()
                }
                else{
                    GlobalFunctions.shared.showAlert(AppName, message: message ?? DomainLayerApi.defaultErrorMessage, view: self)
                }
            }
        }
        else{
            GlobalFunctions.shared.showAlertWithBlock(AppName, message: DomainLayerApi.defaultErrorMessage, view: self, completion: { (Bool) in
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func followAPI(isFollow: Bool) {
        
        var parameter = Dictionary<String,Any>()
        parameter["other_user_id"] = JSON(self.car?.userId as Any).stringValue
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        
        ApiManger.init().makeRequest(method: (isFollow) ? .UnFollowUser : .FollowUser ,parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                print(response[kData])
                
                if !isFollow{
                    self.car?.isFollowing = 1
                } else {
                    self.car?.isFollowing = 0
                }
                
                self.tableView?.reloadData()
            default:
                debugPrint("")
                GlobalFunctions.shared.showAlert(AppName, message: JSON(response[APIResponseKey.Message]).stringValue, view: self)
            }
        }
    }
}
