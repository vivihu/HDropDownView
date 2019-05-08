//
//  HFilterView.swift
//  HiGo
//
//  Created by vvho on 2018/3/20.
//  Copyright © 2018年 vvho. All rights reserved.
//

import SnapKit

protocol HFilterViewDelegate: class {
    func didSelected(filterView: HFilterView)
}

class HFilterView: UIView {
    
    weak var delegate: HFilterViewDelegate?
    private let backgroundView = UIView()
    
    /// 调用此方法，必须要保证HFilterView已完成自身约束条件
    ///
    /// - Parameters:
    ///   - delegate: 完成选择代理
    ///   - items: 下拉项数组
    ///   - topOffsetInWindow: 距离顶部距离。(如果在UITabBarController一级页面需要设置此值)
    open func setup(delegate: HFilterViewDelegate, items: [HBaseFilterItem], topOffsetInWindow: CGFloat? = nil) {
        self.delegate = delegate
        
        // 1.添加背景遮罩
        backgroundView.alpha = 0
        backgroundView.isHidden = true
        backgroundView.clipsToBounds = true
        backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        if let offset = topOffsetInWindow {
            UIApplication.shared.keyWindow?.addSubview(backgroundView)
            backgroundView.snp.makeConstraints { maker in
                maker.left.bottom.right.equalToSuperview()
                maker.top.equalToSuperview().offset(offset)
            }
        } else {
            superview?.addSubview(backgroundView)
            backgroundView.snp.makeConstraints { maker in
                maker.left.bottom.right.equalToSuperview()
                maker.top.equalTo(snp.bottom)
            }
        }
        
        // 2.为背景添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tap.delegate = self
        backgroundView.addGestureRecognizer(tap)
        
        // 3.添加按钮和内容视图
        for (index, item) in items.enumerated() {
            // 添加分类按钮并设置坐标
            let button = HSwapButton(title: item.title, isSorted: item.isSortItem)
            button.addTarget(self, action: #selector(onClick), for: .touchUpInside)
            button.tag = 1000 + index
            addSubview(button)
            
            button.snp.makeConstraints { maker in
                if index == 0 {
                    maker.left.equalToSuperview()// 第一个按钮的左侧=superview
                } else {
                    let lastButton = viewWithTag(button.tag - 1)!
                    maker.width.equalTo(item.isSortItem ? 44 : lastButton)// 宽相等
                    maker.left.equalTo(lastButton.snp.right).offset(item.isSortItem ? -8 : 0)// 当前按钮的左侧=上一个按钮的右侧
                }
                if index == items.count - 1 {
                    maker.right.equalToSuperview()// 最后一个按钮的右侧=superview
                }
                maker.top.bottom.equalToSuperview()
            }
            
            // 添加内容并设置坐标
            item.delegate = self
            item.tag = button.tag
            
            backgroundView.addSubview(item)
            item.snp.makeConstraints { maker in
                maker.left.right.equalToSuperview()
                maker.bottom.equalTo(backgroundView.snp.top)
            }
        }
    }
    
    /// 隐藏筛选下拉框
    @objc open func dismiss() {
        onClick(nil)
    }
    
    /// 当添加在keywindow时需要调用
    open func remove() {
        backgroundView.subviews.forEach { $0.removeFromSuperview() }
        backgroundView.removeFromSuperview()
    }

}

private extension HFilterView {
    
    @objc func onClick(_ sender: UIButton?) {
        subviews.forEach { view in
            guard let button = view as? HSwapButton,
                let contentView = backgroundView.viewWithTag(button.tag),
                let filterItem = contentView as? HBaseFilterItem else { return }
            // 1.设置按钮是否选中
            if button == sender {
                button.isSelected = !button.isSelected
                backgroundView.bringSubviewToFront(contentView)
            } else {
                button.isSelected = false
            }
            // 2.恢复上次选择: 逻辑上来讲，判断条件应该是button.isSelected=false时
            if button.isSelected {
                filterItem.restore()
            }
            // 3.设置显示的内容视图
            let offset = button.isSelected ? contentView.height : 0
            contentView.snp.updateConstraints {
                $0.bottom.equalTo(backgroundView.snp.top).offset(offset)
            }
        }
        
        // ps: 解决导航栈push之后再pop，backgroundView出现在tabbar的问题
        backgroundView.superview?.bringSubviewToFront(backgroundView)
        // 强制隐藏键盘
        backgroundView.endEditing(true)
        // 设置内容不隐藏、动画过渡布局、如果内容不显示，则设置隐藏
        backgroundView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.layoutIfNeeded()
            self.backgroundView.alpha = (sender?.isSelected ?? false) ? 1 : 0
        }) { _ in
            self.backgroundView.isHidden = (self.backgroundView.alpha == 0)
        }
    }
    
}

extension HFilterView: UIGestureRecognizerDelegate, HFilterItemDelegate {
    
    // MARK: 手势代理回调，完成点击背景隐藏筛选下拉框
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        var flag = true
        let point = gestureRecognizer.location(in: backgroundView)
        gestureRecognizer.view?.subviews.forEach { view in
            if view.frame.contains(point) {
                flag = false
            }
        }
        return flag
    }
    
    // MARK: 子筛选视图完成选择回调
    
    func didFinish(filterItem: HBaseFilterItem, displayMode: DisplayMode) {
        // 1.隐藏内容
        dismiss()
        // 2.不是排序项，则设置按钮标题
        if filterItem.isSortItem == false {
            if let btn = subviews.first(where: { $0.tag == filterItem.tag }) as? HSwapButton {
                switch displayMode {
                case .none:
                    btn.setTitle(filterItem.title, for: .normal)
                case let .message(title):
                    btn.setTitle(title, for: .normal)
                }
            }
        }
        // 3.完成筛选回调
        delegate?.didSelected(filterView: self)
    }

}
