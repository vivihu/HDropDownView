//
//  HSwapButton.swift
//  HiGo
//
//  Created by vvho on 2018/3/20.
//  Copyright © 2018年 vvho. All rights reserved.
//

import UIKit

class HSwapButton: UIButton {
    
    convenience init(title: String?, isSorted: Bool) {
        self.init(type: .custom)
        // 是否排序按钮
        if isSorted {
            setImage(#imageLiteral(resourceName: "ic_sort"), for: .normal)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right:0)
        } else {
            setTitle(title, for: .normal)
            setImage(#imageLiteral(resourceName: "ic_drop_down"), for: .normal)
            setImage(#imageLiteral(resourceName: "ic_pull_up"), for: .selected)
        }
        // 通用设置
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.size(14)
        adjustsImageWhenHighlighted = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 文字在左，图片在右
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageView?.image?.size.width ?? 0) - 3,
                                       bottom: 0, right: (imageView?.image?.size.width ?? 0))
        imageEdgeInsets = UIEdgeInsets(top: 0, left: (titleLabel?.width ?? 0) + 3,
                                       bottom: 0, right: -(titleLabel?.width ?? 0))
    }
    
}
