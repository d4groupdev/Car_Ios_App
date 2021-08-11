
import UIKit

class ChangePasswordVC: BaseVC {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var currentPasswordField: CustomTextField!
    @IBOutlet weak var newPasswordField: CustomTextField!
    @IBOutlet weak var confirmNewPasswordField: CustomTextField!
    @IBOutlet weak var saveBarButton: UIBarButtonItem?
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Class Variables -
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - Custom Methods -
    
    //-------------------------------------------------------------------------------------
    
    //MARK: - API Validation
    
    override func validationString() -> Bool {
        newPasswordField.valid(kValidationEnterPassword, newPasswordField.text == "")
        newPasswordField.valid(kValidationEnterValidPassword, newPasswordField.text != "" && newPasswordField.text!.count < 8)
        confirmNewPasswordField.valid(kValidationEnterConfirmPwd, confirmNewPasswordField.text == "")
        confirmNewPasswordField.valid(kValidationEnterValidPassword, confirmNewPasswordField.text != "" && confirmNewPasswordField.text!.count < 8)
        
        if CustomTextField.valid {
            newPasswordField.valid(kValidationPasswordMismatch, newPasswordField.text != confirmNewPasswordField.text)
            confirmNewPasswordField.valid(kValidationPasswordMismatch, newPasswordField.text != confirmNewPasswordField.text)
        }
        
        return CustomTextField.isValid()
    }
    
    //--------------------------------------------------------------------------------------
    
    //MARK: - API Methods -
    
    func changePasswordAPI() {
        
        view.endEditing(true)
        
        var parameter = Dictionary<String,Any>()
        parameter["password"] = confirmNewPasswordField.text
        parameter["user_id"] = JSON(User.shared?.id as Any).stringValue
        
        ApiManger.init().makeRequest(method: .ChangePassword, parameter:parameter, withLoaderText: APILoaderText.Loading) { (jsonResponse, responseStatus, error, statusCode) in
            
            if error != nil {
                GlobalFunctions.shared.showAlert(AppName, message: JSON(error?.localizedDescription as Any).stringValue, view: self)
                return
            }
            
            let response = JSON(jsonResponse)
            switch statusCode {
                
            case .SuccessResponse:
                
                let alert = UIAlertController(title: "Change password",
                                              message: JSON(response[APIResponseKey.Message]).stringValue, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
                    self.navigationController?.dismiss(animated: true, completion: {})
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
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
    
    @IBAction func backTapHandler(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapHandler(_ sender: UIButton) {
        
        if fieldsValidation() {
            changePasswordAPI()
        }
    }
    
    @IBAction func newPasswordEyeTapHandler(_ sender: UIButton) {
        newPasswordField.isSecureTextEntry = !newPasswordField.isSecureTextEntry
        sender.setImage(UIImage(named: newPasswordField.isSecureTextEntry ? "eye-icon" : "eye-icon-disable"), for: .normal)
    }

    @IBAction func confirmPasswordEyeTapHandler(_ sender: UIButton) {
        confirmNewPasswordField.isSecureTextEntry = !confirmNewPasswordField.isSecureTextEntry
        sender.setImage(UIImage(named: confirmNewPasswordField.isSecureTextEntry ? "eye-icon" : "eye-icon-disable"), for: .normal)
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
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
