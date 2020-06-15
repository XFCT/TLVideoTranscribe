//
//  TLRecordView.swift
//  TLVideoTranscribe
//
//  Created by 王天龙 on 2020/6/10.
//  Copyright © 2020 hogoCloud. All rights reserved.
//

import UIKit

class TLRecordView: UIView {

    ///模糊效果
    private lazy var blurView:UIVisualEffectView = {
        let blur = UIBlurEffect.init(style: .extraLight)
        let blurView = UIVisualEffectView.init(effect: blur)
        blurView.alpha = 0.88
        blurView.frame = self.bounds
        return blurView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.blurView)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
