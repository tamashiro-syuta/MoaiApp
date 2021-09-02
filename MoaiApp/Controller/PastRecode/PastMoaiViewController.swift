//
//  PastMoaiViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/08/23.
//

import UIKit
import Firebase
import FirebaseStorage
import PKHUD

class PastMoaiViewController: standardViewController {
    
    let storage = Storage.storage().reference().child("past_recodes")
    
    var selectedPastMoaiNumber:Int = 0
    
    var pastMoaiDate:String?
    
    var pastMoaiImageURLArray = [String]()
    var pastMoaiImageArray = [Data]()
    
    var vi: UIView?  //ピッカービューで使用
    
    @IBOutlet weak var pastMoaiInfoLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addFileButton: UIButton!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("self.pastRecodeArray?.countは \(self.pastRecodeArray?.count)")
        print("self.moai?.groupNameは \(self.moai?.groupName)")
        
        //模合を　過去にしたことがあるかの判定条件
        if self.pastRecodeArray != nil && self.pastRecodeArray?.count != 0 {
            //模合をしたことがある
//            self.fetchPastPicture()
            
            print("viewを作り始めます")
            //viewを表示
            self.selectedPastMoaiNumber = self.pastRecodeArray!.count - 1
            self.setLayout(backnumber: self.selectedPastMoaiNumber)
            self.fetchPastPicture(pastMoaiDate: self.pastMoaiDate!)
            
            HUD.flash(.progress, onView: view, delay: 1.5) { _ in
                
                self.setupView()
                
                let layout = UICollectionViewFlowLayout()
                layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                layout.minimumInteritemSpacing = 3
                layout.minimumLineSpacing = 3
                
                self.collectionView.collectionViewLayout = layout
            }
        }else {
            //模合をしたことがない
            
            //上からBlurViewをかけて利用を制限
            self.addBlurEffect()
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        
        //レイアウトの更新
//        resetLayout(backnumber: )
        
    }
    
    private func setupView() {
        pastMoaiInfoLabel.layer.cornerRadius = pastMoaiInfoLabel.bounds.height / 3
        addFileButton.layer.cornerRadius = addFileButton.bounds.height / 3
        
        collectionView.delegate = self
        collectionView.dataSource = self

    }
    
    //画像のアップロード
    @IBAction func addPictures(_ sender: Any) {
        //端末の画像フォルダにアクセスしてプロフィール画像を設定
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    //ナビゲーションのタイトルをタップした時の処理
    @objc func tappedTitleButton() {
        print("タップしたよ")
        //ダウンスクロールメニューを表示し、その中から過去の模合を選択し、し終わると、その詳細を表示する

        let pickerView = UIPickerView()
        pickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerView.bounds.size.height + 80)

        pickerView.delegate   = self
        pickerView.dataSource = self
        
        self.vi = UIView(frame: pickerView.bounds)
        vi?.backgroundColor = UIColor.white
        vi?.addSubview(pickerView)
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 150))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        toolBar.setItems([space, done ], animated: true)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        vi?.addSubview(toolBar)
        view.addSubview(vi!)
        let screenSize = UIScreen.main.bounds.size
        vi?.frame.origin.y = screenSize.height
        UIView.animate(withDuration: 0.3) {
            self.vi?.frame.origin.y = screenSize.height - (self.vi?.bounds.size.height)!
        }
    }
    
    @objc func donePressed() {
        self.vi?.isHidden = true
        
        reloadImageOnCollectionView()
    }
    
    private func reloadImageOnCollectionView() {
        //画像取得
        self.fetchPastPicture(pastMoaiDate: self.pastMoaiDate!)
        
        HUD.flash(.progress,onView: self.collectionView, delay: 1) { _ in
            self.collectionView.reloadData()
        }
    }
    
    private func setLayout(backnumber:Int) {
        print("引数は \(backnumber)")
        let navTitle = "まだだよん♪"
        if backnumber < 0 || backnumber + 1 > self.pastRecodeArray?.count ?? 0 {
            print("例外な値だよとアラートを出す")
        }else {
            let record =  self.pastRecodeArray![backnumber]
            let text = "受取：" + "\(record.getMoneyPerson)" + "\n" + "場所：" + "\(record.locationName)"
            self.pastMoaiInfoLabel.text = text
            
            let date = DateUtils.stringFromDate(date: record.date.dateValue())
            self.pastMoaiDate = DateUtils.stringFromDateoForSettingNextID(date: record.date.dateValue())
            setNavigationBar(title: date)
//            fetchPastPicture(pastMoaiDate: pastMoaiDate)
        }
    }
    
    private func setNavigationBar(title:String) {
        //ナビゲーションのタイトルを設定
        //元となるViewを生成(ここにボタンやviewを乗せていく)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 160, height: 46))
        //ボタンを生成
        let filterButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 46))
        if self.pastRecodeArray != nil && self.pastRecodeArray?.count != 0 {
            //ボタンが働く処理
            print("pastRecodeArrayにはちゃんと値があるからボタンとして機能させるンゴよ")
            filterButton.addTarget(self, action: #selector(tappedTitleButton), for: .touchUpInside)//タップされた時に関数動く
        }
//        filterButton.addTarget(self, action: #selector(tappedTitleButton), for: .touchUpInside)//タップされた時に関数動く
        view.addSubview(filterButton)//メインのviewにviewをのせる
        //タイトルとなるViewを生成
        let label = UILabel(frame: CGRect(x: 0, y: 13, width: 160, height: 18))
        label.text = title
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.black
        view.addSubview(label)
        //三角形のimageを生成
        let imageView = UIImageView(frame: CGRect(x: 70, y: 30, width: 10, height: 12))
        imageView.image = UIImage(systemName: "arrowtriangle.down.fill")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        view.addSubview(imageView)
        //navigationBarのtitleViewに作ったviewを渡す
        navigationItem.titleView = view
    }
    
    private func addBlurEffect() {
        //画面全体に曇りガラスを設置
        let effect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(effectView)
        
        //その上にメッセージを設置
        let message = UILabel()
        let frame = CGRect(x: view.frame.size.width / 12 , y: view.frame.size.height / 3, width: (view.frame.size.width / 12) * 10, height: (view.frame.size.height / 3) )
        message.frame = frame
        message.text = "初めての模合がまだ終了してません。" + "\n" + "初回終了後、利用できます。" + "それまでしばらくお待ちください。"
        message.tintColor = UIColor.textColor()
        message.textAlignment = NSTextAlignment.center  //中央寄せ
        message.adjustsFontSizeToFitWidth = true  //文字サイズを自動調整
        message.numberOfLines = 10
        message.backgroundColor = UIColor.labelBackGroundColor()
        message.layer.cornerRadius = 50
        
        view.addSubview(message)
    }
    
    //引数は、20210415のような形にする
    private func fetchPastPicture(pastMoaiDate: String) {
        guard let moaiID = self.user?.moais[1] else {
            print("模合IDの取得に失敗しまいした。")
            return
        }
        
        let storageReference = self.storage.child(moaiID).child(pastMoaiDate)
        storageReference.listAll { (result, err) in
            if let err = err {
              print("エラーでした〜〜〜 \(err)")
            }
        
            //配列の初期化（別日の画像やURLが入っているかもしれないから）
            self.pastMoaiImageArray.removeAll()
            self.pastMoaiImageURLArray.removeAll()
            
            for item in result.items {
              // The items under storageReference.
              print("item → \(item)")
              print("item.fullpath → \(item.fullPath)")
              print("itemの型は、\( type(of: item) )")
              self.pastMoaiImageURLArray.append(item.fullPath)
              self.getImagesFromFireStorage(ImagePath: item.fullPath)
            }
        }
    }
    
//    引数のURLは、"gs://<your-firebase-storage-bucket>/images/stars.jpg"のようなものを渡す
    private func getImagesFromFireStorage(ImagePath: String) {
        let storage = Storage.storage()
        let pastMoaiImageRef = storage.reference(withPath: ImagePath)
        
        pastMoaiImageRef.getData(maxSize: 1 * 1024 * 1024) { (data, err) in
            if let err = err {
                print("エラーです〜〜〜 \(err)")
                return
            }else {
                //エラーが出ない時点でdataには値が入っているから強制アンラップしても大丈夫
                guard let image = UIImage(data: data!)?.jpegData(compressionQuality: 0.1) else {
                    print("何か知らんけど、UIImage型に変換できんかったわ")
                    return
                }
                self.pastMoaiImageArray.append(image)
                print("self.pastMoaiImageArray → \(self.pastMoaiImageArray)")
            }
//            self.collectionView.reloadData()
        }
    }

}

extension PastMoaiViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    //セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 15
        return self.pastMoaiImageURLArray.count
    }
    
    //セルの中身を決める
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.barColor()
        cell.layer.cornerRadius = 5
        
        print("indexPath.rowは、\(indexPath.row)")
        print("self.pastMoaiImageArray.countは、\(self.pastMoaiImageArray.count)")
        
        // Tag番号を使ってImageViewのインスタンス生成
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
        
        let cellImage = UIImage(data: self.pastMoaiImageArray[indexPath.row])
        // UIImageをUIImageViewのimageとして設定
        imageView.image = cellImage
        
        return cell
    }
    
    //collectionViewのレイアウト
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 10
        let cellSize : CGFloat = self.view.bounds.width / 3 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }
    
    // セルが選択された時の挙動
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("セルがタップされたよ")
    }
    
    
}

extension PastMoaiViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //UIViewPickerの列(横方向)数を指定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //UIViewPickerの行(縦方向)数を指定
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //上でボタンが有効な条件として、カウントが０以外かつ配列が空出ないことを指定しているので、ここが呼ばれる＝カウントが存在するということになる
        return (self.pastRecodeArray?.count)!
    }
    
    //各行のタイトルとテキストカラー
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: (self.pastRecodeIDDateArray?[row])!, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    // UIViewPickerのrowが選択された時のメソッド
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //選択されたものに応じて、引数を指定し、ラベルのUI更新のメソッドを呼び出す。
        self.setLayout(backnumber: row)
    }
}


extension PastMoaiViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //もし、info[.editedImage]が空じゃなかったら中の処理をする
        if let editImage = info[.editedImage] as? UIImage {
            //firebaseに保存
            uploadImages(image: editImage)
        }else if let originalImage = info[.originalImage] as? UIImage {
            uploadImages(image: originalImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadImages(image: UIImage) {
        
        guard let moaiID = self.user?.moais[1] else {
            print("模合IDの取得に失敗しまいした。")
            return
        }
        //画像のクオリティを0.3倍に変更
        guard let uploadImage = image.jpegData(compressionQuality: 0.7) else {return}
        //ファイルネームを任意で設定して保存するための定数
        let fileName = NSUUID().uuidString
        let storageReference = self.storage.child(moaiID).child("20210415").child(fileName)
        
        //インスタンス化したstorageRefのfileNameの中にuploadImageの情報を紐づけ
        storageReference.putData(uploadImage, metadata: nil) { (metadate, err) in
            if let err = err {
                print("Firestorageへの情報の保存に失敗しました。\(err)")
                return
            }
            
            print("画像の保存に成功しました。")
            //画像を更新
            self.reloadImageOnCollectionView()
        }
    }
}

