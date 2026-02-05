//
//  FilelistViewController.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/6/30.
//

import UIKit

class FilelistViewController:NavigationController,FilelistViewProtocol,FilelistViewCellProtocol,UITableViewDelegate,UITableViewDataSource{
    
    private var fileView = FilelistView()
    
    let CELLIDENTIFITER = "FILELISTTABLEVIEWCELL"
    
    //文件选择
    private var dataList = Array<FileModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutNavigationCenter(title: "File list")
        
    }
    
    override func initView() {
        
        let view = UIView()
        fileView.delegate = self
        fileView.tableView?.delegate = self
        fileView.tableView?.dataSource = self
        fileView.tableView?.tableFooterView = view
        fileView.frame = self.view.bounds
        self.view.addSubview(fileView)
        
    }
    
    override func initData() {
        //读取本地项目存储的沙盒列表文件
        readSandBoxFile()
    }
    
    //界面每次显示的时候
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //如果有列表，把列表清空，再添加新的列表
        if dataList.count > 0{
            dataList.removeAll()
        }
        readSandBoxFile()
    }
    
    //读取沙盒中的文件
    func readSandBoxFile(){
        let documentPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        let documentsDirPath = documentPaths[0]
        let fm = FileManager.default
        var dirContents: [String]? = nil
        do {
            dirContents = try fm.contentsOfDirectory(atPath: documentsDirPath)
        } catch {
            print("Get File Error!")
        }
        
        //自定义过滤器
        let predicate = NSPredicate(format: "pathExtension == 'zip'")
        
        //过滤数据
        let fileNameArray = dirContents?.filter({
            return predicate.evaluate(with: $0)
        })
        
        for filename in fileNameArray! {
            let model = FileModel()
            model.filename = filename
            model.filepath = documentsDirPath
            dataList.append(model)
        }
        
        if dataList.count>0 {
            fileView.tableView?.reloadData()
        }
    }
    
    func onUpdateClick() {
        print("updateClick")
        if dataList.count > 0{
            for model in dataList{
                if model.isSelect {
                    for controller in navigationController?.viewControllers ?? []{
                        if (controller is DFUViewController) {
                            let vc = controller as? DFUViewController
                            if let vc = vc {
                                vc.model = model
                                navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func onClick(sender: UIButton) {
        print("onClick")
    }
    
    //MARK: UITableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: FilelistViewCell? = tableView.dequeueReusableCell(withIdentifier: CELLIDENTIFITER) as? FilelistViewCell
        if cell == nil{
            cell = FilelistViewCell(style: .default, reuseIdentifier: CELLIDENTIFITER)
            cell!.selectionStyle = .none
            cell!.delegate = self
        }
        
        if dataList.count > 0 {
            
            let model = dataList[indexPath.row]
            
            //选择按钮的时候
            if model.isSelect {
                cell?.mCheckBtn?.setImage(UIImage(named: "checkbox_fill"), for: .normal)
            }else{
                cell?.mCheckBtn?.setImage(UIImage(named: "checkbox"), for: .normal)
            }
            
            if model.filename != nil{
                cell?.mFileNameLb?.text = model.filename!
            }
        }
        
        return cell!
    }
    
    //点击列表的事件方法
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //TODO: 点击 进行其他的操作
        var cell: FilelistViewCell? = tableView.dequeueReusableCell(withIdentifier: CELLIDENTIFITER) as? FilelistViewCell
        if cell == nil{
            cell = FilelistViewCell(style: .default, reuseIdentifier: CELLIDENTIFITER)
            cell!.selectionStyle = .none
            cell!.delegate = self
        }
        
        //let model = dataList[indexPath.row]
        
        for i in 0..<dataList.count {
            let model = dataList[i]
            if(i != indexPath.row){
                model.isSelect = false
            }else if(i == indexPath.row){
                model.isSelect = true
            }
        }
        
        //刷新当前的cell
        fileView.tableView!.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
    
    
    //界面消失的时候
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}
