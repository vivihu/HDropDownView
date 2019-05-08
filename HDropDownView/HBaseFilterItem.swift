//
//  HBaseFilterItem.swift
//  YaLangKe
//
//  Created by macV on 2019/3/7.
//  Copyright © 2019 木润森. All rights reserved.
//

import UIKit

enum DisplayMode {
    case none
    case message(title: String)
}

protocol HFilterItemDelegate: class {
    func didFinish(filterItem: HBaseFilterItem, displayMode: DisplayMode)
}

class HBaseFilterItem: UIView {

    // 请注意: 这里实现类应使用weak
    weak var delegate: HFilterItemDelegate?
    
    /// 按钮标题
    private(set) var title: String = ""
    
    /// 是否排序项
    private(set) var isSortItem: Bool = false
    
    // MARK: - 初始化方法
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    convenience init(isSortItem: Bool) {
        self.init()
        self.title = "排序项"
        self.isSortItem = isSortItem
    }
    
    /// 需要子类实现：关闭时，恢复选择值
    func restore() {}

}
