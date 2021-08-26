//
//  PastMoaiViewController.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/08/23.
//

import UIKit

class PastMoaiViewController: standardViewController {
    
    var selectedPastMoaiNumber:Int = 0
    
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
            selectedPastMoaiNumber = self.pastRecodeArray!.count - 1
            
            setLayout(backnumber: selectedPastMoaiNumber)
            setupView()
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumInteritemSpacing = 3
            layout.minimumLineSpacing = 3
            
            collectionView.collectionViewLayout = layout
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
            setNavigationBar(title: date)
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
        filterButton.addTarget(self, action: #selector(tappedTitleButton), for: .touchUpInside)//タップされた時に関数動く
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

}

extension PastMoaiViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    //セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    //セルの中身を決める
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.barColor()
        cell.layer.cornerRadius = 5
        return cell
    }
    
    //collectionViewのレイアウト
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 10
        let cellSize : CGFloat = self.view.bounds.width / 3 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
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
    
    //各行のタイトル
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pastRecodeIDDateArray?[row]
    }
    
    // UIViewPickerのrowが選択された時のメソッド
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //選択されたものに応じて、引数を指定し、ラベルのUI更新のメソッドを呼び出す。
        self.setLayout(backnumber: row)
    }
    
    
}
