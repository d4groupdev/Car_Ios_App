
import UIKit
import youtube_ios_player_helper

class YoutubePlayerVC: BaseVC, YTPlayerViewDelegate {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var youtubePlayerView: YTPlayerView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Class Variables -
    
    var youtubeID: String!
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods -
    
    //-------------------------------------------------------------------------------------
    
    //MARK: - API Validation
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - API Methods -
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Delegate Methods -
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
    func playerViewPreferredWebViewBackgroundColor(_ playerView: YTPlayerView) -> UIColor {
        return UIColor(named: "color-background") ?? .black
    }
    
    func playerViewPreferredInitialLoading(_ playerView: YTPlayerView) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(named: "color-background") ?? .black
        return view
    }

    //--------------------------------------------------------------------------------------
    
    //MARK: - Action Methods -
    @IBAction func backTapHandler(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func moreTapHandler(_ sender: Any) {
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
        
        youtubePlayerView.delegate = self
        youtubePlayerView.load(withVideoId: youtubeID ?? "NR32ULxbjYc",
                               playerVars: ["playsinline": 0])
        youtubePlayerView.playVideo()

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UIPresentationControllerDismissalTransitionDidEndNotification"),   //UIPresentationControllerDismissalTransitionWillBeginNotification
            object: nil,
            queue: nil)
        { notification in
            print(notification)
            if let notificationObject = notification.object {
                if nil != String(describing: notificationObject).range(of: "AVFullScreenViewController") {
                    NotificationCenter.default.removeObserver(self)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UIPresentationControllerPresentationTransitionDidEndNotification"),
            object: nil,
            queue: nil)
        { notification in
            print(notification)
            if let notificationObject = notification.object {
                if nil != String(describing: notificationObject).range(of: "AVFullScreenViewController") {
                    self.coverView.isHidden = true
                    self.spinner.stopAnimating()
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("UIPresentationControllerDismissalTransitionWillBeginNotification"),
            object: nil,
            queue: nil)
        { notification in
            print(notification)
            if let notificationObject = notification.object {
                if nil != String(describing: notificationObject).range(of: "AVFullScreenViewController") {
                    self.coverView.isHidden = false
                }
            }
        }

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

