//
//  ViewController.swift
//  TLVideoTranscribe
//
//  Created by 王天龙 on 2020/4/8.
//  Copyright © 2020 hogoCloud. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let button = UIButton(type: .custom)
        view.addSubview(button)
        button.setTitle("开始", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.frame = CGRect(x: 50, y: 100, width: 50, height: 30)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }

    @objc func buttonClick (){
        let vc = TLVideoViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true) {
        }
    }

}

