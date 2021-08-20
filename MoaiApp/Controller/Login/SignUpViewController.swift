//
//  SignUpViewController.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/11.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import PKHUD  //インジケーターの表示

class SignUpViewController: UIViewController {
    
    var user:User?
    
    var moveVC:UIViewController?
    var moveVCName:String?
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var createOrJoinSegumentControl: UISegmentedControl!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setUpViews() {
        
        self.moveVCName = "CreateRoomViewController"
        
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        
        
        alreadyHaveAccountButton.addTarget(self, action: #selector(tappedAlreadyHaveAccountButton), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        //toolbarに表示させるアイテム
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelPressed))
        toolbar.setItems([cancel , space, done ], animated: true)
        
        emailTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
        usernameTextField.inputAccessoryView = toolbar
        
        createOrJoinSegumentControl.selectedSegmentTintColor = .barColor()
        
        //全てのテキストフィールドに値が入ってないとボタンが押せなくする処理
        registerButton.isEnabled = false
        registerButton.layer.cornerRadius = 12
        registerButton.backgroundColor = .barColor()
    }
    
    @objc func donePressed() {
        view.endEditing(true)
    }
    
    @objc func cancelPressed() {
        view.endEditing(true)
    }
    
    @IBAction func selectedControl(_ sender: UISegmentedControl) {
        //sender.selectedSegmentIndex -> 左が０、右が１
        if sender.selectedSegmentIndex == 0 {
            print("模合、作ります！！")
            self.moveVCName = "CreateRoomViewController"
        }else if sender.selectedSegmentIndex == 1 {
            print("模合に参加します！！")
            self.moveVCName = "FirstJoinViewController"
        }
    }
    
    
    @objc private func tappedAlreadyHaveAccountButton() {
        //LoginViewControllerへの画面遷移
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(loginViewController, animated: true)
        
    }
    
    @IBAction func tappedProfileImageButton(_ sender: Any) {
        //端末の画像フォルダにアクセスしてプロフィール画像を設定
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func tappedRegisterButton(_ sender: Any) {
        //画像をfirebaseに保存
        let image = profileImageButton.imageView?.image ?? UIImage(named: "niwatori")
        //画像のクオリティを0.3倍に変更
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3) else {return}
        
        HUD.show(.progress)
        
        //ファイルネームを任意で設定して保存するための定数
        let fileName = NSUUID().uuidString
        //storage(画像を保存するとこ)に"profile_image"フォルダとその中にfileNameの情報を入れたものをインスタンス化
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        
        //インスタンス化したstorageRefのfileNameの中にuploadImageの情報を紐づけ
        storageRef.putData(uploadImage, metadata: nil) { (metadate, err) in
            if let err = err {
                print("Firestorageへの情報の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            
            //成功した後の処理

            //画像データをURLとして取得（FireStoreに入れるため）
            storageRef.downloadURL { (url, err) in
                if let err = err {
                    print("FireStorgaeからのダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                //URLを文字列に変換
                guard let urlString = url?.absoluteString else {return}
                //URLをfirestoreに保存
                self.createUserToFirestore(profileImageUrl: urlString)
            }
        }
    }
 
    
    private func createUserToFirestore(profileImageUrl: String){
        //テキストフィールドの値と画像をDBに格納（textFieldは下のコードで取り出すので、画像のURLだけ引数として指定してる）
        
        //user情報を認証
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { [self] (res, err) in
            if let err = err {
                print("認証情報の保存に失敗しました。\(err)")
                self.errorAlert()
                HUD.hide()
                return
            }
            guard let uid = res?.user.uid else {return}
            guard let username = usernameTextField.text else {return}
            let docData = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "profileImageUrl": profileImageUrl,
                "password": password,
                "moais":[""]
            ] as [String : Any]
            
            
            Firestore.firestore().collection("users").document(uid).setData(docData) {
                (err) in
                if let err = err {
                    print("FireStoreへの情報に保存に失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                
                Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
                    if let err = err {
                        print("エラーでっせ\(err)")
                        return
                    }
                    guard let dic = snapshot?.data() else {
                        print("snapshotのデータの取得に失敗")
                        return
                    }
                    self.user = User(dic: dic)
                    print("FireStoreへの情報に保存に成功しました。")
                    HUD.hide()
                    //模合作成 or 参加画面に遷移(画面遷移と一緒にユーザー情報を渡す)
    //                self.dismiss(animated: true, completion: nil)
                    if self.moveVCName == "CreateRoomViewController" {
                        print("模合作りまーす")
                        pushCreateRoomVC(uid: uid)
                    }else {
                        print("模合に参加しまーす")
                        pushJoinRoomVC(uid: uid)
                }
                }
            }
        }
        
    }
    
    //画面をタップするとテキストフィールドの編集を終わらせてくれる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func pushCreateRoomVC(uid: String) {
        let CreateRoomStoryboard = UIStoryboard(name: "SignUp", bundle: nil)
        let CreateRoomVC = CreateRoomStoryboard.instantiateViewController(withIdentifier: "CreateRoomViewController") as! CreateRoomViewController
        CreateRoomVC.userID = uid
        CreateRoomVC.user = user
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(CreateRoomVC, animated: true)
    }
    
    private func pushJoinRoomVC(uid: String) {
        let FirstJoinStoryboard = UIStoryboard(name: "SignUp", bundle: nil)
        let FirstJoinVC = FirstJoinStoryboard.instantiateViewController(withIdentifier: "FirstJoinViewController") as! FirstJoinViewController
        FirstJoinVC.userID = uid
        FirstJoinVC.user = self.user
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(FirstJoinVC, animated: true)
    }
    
    private func errorAlert() {
        //この時、メールかパスワードのテキストフィールドの色を変更できたら最高
        let alertText = "このメールアドレス、またはパスワードは、既に他のユーザーに使用されています。"
        
        let alert: UIAlertController = UIAlertController(title: alertText, message: "", preferredStyle:  UIAlertController.Style.alert)

        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        // ③ UIAlertControllerにActionを追加
        alert.addAction(defaultAction)
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
}




extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .textColor()
        }else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .barColor()
        }
    }
    
}



extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //もし、info[.editedImage]が空じゃなかったら中の処理をする
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        //セットした画像がプロフィール画像の丸に合うような処理
        profileImageButton.setTitle("", for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
}
