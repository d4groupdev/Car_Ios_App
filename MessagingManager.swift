import UIKit
import TwilioAccessManager
import TwilioChatClient

class MessagingManager: NSObject {
    
    static let _sharedManager = MessagingManager()
    
    var client:TwilioChatClient?
    var delegate:ChannelManager?
    var connected = false
    
    override init() {
        super.init()
        delegate = ChannelManager.sharedManager
    }
    
    class func sharedManager() -> MessagingManager {
        return _sharedManager
    }
    
        
    func presentViewControllerByName(viewController: String) {
        presentViewController(controller: storyBoardWithName(name: "Main").instantiateViewController(withIdentifier: viewController))
    }
    
    func presentLaunchScreen() {
        presentViewController(controller: storyBoardWithName(name: "LaunchScreen").instantiateInitialViewController()!)
    }
    
    func presentViewController(controller: UIViewController) {
        let window = UIApplication.shared.delegate!.window!!
        window.rootViewController = controller
    }
    
    func storyBoardWithName(name:String) -> UIStoryboard {
        return UIStoryboard(name:name, bundle: Bundle.main)
    }   
        
    // MARK: Twilio Client
    
    func loadGeneralChatRoomWithCompletion(completion:@escaping (Bool, NSError?) -> Void) {
        ChannelManager.sharedManager.joinGeneralChatRoomWithCompletion(name: "") { succeeded in
            if succeeded {
                completion(succeeded, nil)
            }
            else {
                let error = self.errorWithDescription(description: "Could not join General channel", code: 300)
                completion(succeeded, error)
            }
        }
    }
    
    func connectClientWithCompletion(completion: @escaping (Bool, NSError?) -> Void) {
        requestTokenWithCompletion { succeeded, token in
            if let token = token, succeeded {
                self.initializeClientWithToken(token: token)
                completion(succeeded, nil)
            }
            else {
                let error = self.errorWithDescription(description: "Could not get access token", code:301)
                completion(succeeded, error)
            }
        }
    }
    
    func initializeClientWithToken(token: String) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        TwilioChatClient.chatClient(withToken: token, properties: nil, delegate: self) { [weak self] result, chatClient in
            guard (result.isSuccessful()) else { return }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self?.connected = true
            self?.client = chatClient
        }
    }
    
    func requestTokenWithCompletion(completion:@escaping (Bool, String?) -> Void) {
        TokenRequestHandler.fetchToken(params: ["device": "I", "identity":JSON(User.shared?.id as Any).stringValue]) {token in
            completion(token != "", token)
        }
    }
    
    func errorWithDescription(description: String, code: Int) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey : description]
        return NSError(domain: "app", code: code, userInfo: userInfo)
    }
}

// MARK: - TwilioChatClientDelegate

extension MessagingManager : TwilioChatClientDelegate {
    
    func chatClient(_ client: TwilioChatClient, channelAdded channel: TCHChannel) {
        self.delegate?.chatClient(client, channelAdded: channel)
    }
    
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel, updated: TCHChannelUpdate) {
        self.delegate?.chatClient(client, channel: channel, updated: updated)
    }
    
    func chatClient(_ client: TwilioChatClient, channelDeleted channel: TCHChannel) {
        self.delegate?.chatClient(client, channelDeleted: channel)
    }
    
    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        if status == TCHClientSynchronizationStatus.completed {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            ChannelManager.sharedManager.channelsList = client.channelsList()
            ChannelManager.sharedManager.populateChannels()
            }
        //self.delegate?.chatClient(client, synchronizationStatusUpdated: status)
    }
}

//MARK: - TwilioAccessManagerDelegate

extension MessagingManager : TwilioAccessManagerDelegate {
    
    func accessManagerTokenWillExpire(_ accessManager: TwilioAccessManager) {
        requestTokenWithCompletion { succeeded, token in
            if (succeeded) {
                accessManager.updateToken(token!)
            }
            else {
                print("Error while trying to get new access token")
            }
        }
    }
    
    func accessManager(_ accessManager: TwilioAccessManager!, error: Error!) {
        print("Access manager error: \(error.localizedDescription)")
    }
}
