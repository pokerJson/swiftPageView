//
//  EPPageTitleView.swift
//  EcologyPlanet
//
//  Created by dzc on 2020/11/18.
//

import UIKit

protocol TYPageTitleViewDelegate : class {
    func pageView(pageView:EPPageTitleView,selectIndex:Int)
}


public class EPPageTitleView: UIView {

    weak var delegate:TYPageTitleViewDelegate?
    
    fileprivate var style:EPPageStyle!
    
    var titles = [String]()
    var titleLabels = [UILabel]()
    
    lazy var scrollView:UIScrollView = {
        let scroll = UIScrollView(frame: self.bounds)
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    lazy var lineView:UIView = {
        let line = UIView()
        line.backgroundColor = self.style.bottomLineColor
        line.frame.size.height = 2
        line.frame.origin.y = self.bounds.size.height - line.frame.size.height - 5
        return line
    }()
    
    fileprivate var currentIndex:Int = 0
    
     init(frame: CGRect, titles: [String], style: EPPageStyle) {
        
        self.titles = titles
        self.style = style
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EPPageTitleView{
    
    fileprivate func setupUI(){
        
        //设置scrollView
        addSubview(scrollView)
        //初始化lineView
        scrollView.addSubview(lineView)
        //初始化title
        setupLabels()
    }
    
    // MARK: 初始化Item
    fileprivate func setupLabels(){
        var x:CGFloat = 0
        let y:CGFloat = 0
        var textWidth:CGFloat = 0
        var labelWidth:CGFloat = 0
        let height:CGFloat = self.style.labelHeight
        let margin:CGFloat = self.style.labelMargin
//        let normalWidth:CGFloat = 60
        var preLabel:UILabel = UILabel()
        for (i,title) in titles.enumerated() {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = style.normalColor
            titleLabel.font = UIFont.systemFont(ofSize: style.labelFont)
            titleLabel.tag = i
            titleLabel.textAlignment = .center
            titleLabel.isUserInteractionEnabled = true
            titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemClick(_:))))
            //设置frame
            textWidth = widthForContent(titleLabel,style.isShowFontScale ? style.labelSelFont : 0)
            if style.labelLayout == .divide{
                labelWidth = (bounds.size.width - CGFloat(titles.count + 1) * margin) / CGFloat(titles.count)
            }else if style.labelLayout == .center{
                labelWidth = style.labelCenterWidth
            }else{
                labelWidth = textWidth
            }
            
            if i == 0{
                
                if style.isShowFontScale{
                    titleLabel.font = UIFont.systemFont(ofSize: style.labelSelFont)
                }
                
                if style.labelLayout == .scroll {
                    x = margin*0.5
                }else if style.labelLayout == .divide{
                    x = margin
                }
                else{  //设置居中情况下x
                    x = (bounds.size.width - labelWidth*CGFloat(titles.count) - margin*CGFloat(titles.count - 1))/CGFloat(2)
                }
                
                if self.style.isFixedLineWidth {
                    lineView.frame.origin.x = x + (labelWidth - self.style.lineCenterWidth)/2.0
                    lineView.frame.size.width = self.style.lineCenterWidth
                }else{
                    lineView.frame.origin.x = style.bottomAlginLabel ? x : x + (labelWidth - textWidth)/2.0
                    lineView.frame.size.width = style.bottomAlginLabel ? labelWidth : textWidth
                }
                
                titleLabel.textColor = style.selectColor
                
                //字体变大
                
            }else{
                if style.labelLayout == .scroll {
                    x = preLabel.frame.maxX + margin
                }else {
                    x = preLabel.frame.maxX + margin
                }
            }
            titleLabel.frame = CGRect(x: x, y: y, width: labelWidth, height: height)
            
            //添加到视图中
            scrollView.addSubview(titleLabel)
            titleLabels.append(titleLabel)
            preLabel = titleLabel
        }
        
        //设置scrollView的ContentSize
        scrollView.contentSize = CGSize(width: preLabel.frame.maxX+margin*0.5, height: 0)
        scrollView.bringSubviewToFront(lineView)
    }
    
    fileprivate func widthForContent(_ label:UILabel, _ fontSize: CGFloat = 0) -> CGFloat{
        return ((label.text! as NSString).boundingRect(with: CGSize(width : CGFloat.greatestFiniteMagnitude, height: 0), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: fontSize > 0 ? UIFont.systemFont(ofSize: fontSize) : label.font ?? 15], context: nil)).width
    }
}

extension EPPageTitleView{
    
    private func ajustViewPostion(_ selectLabel:UILabel){
        let preLabel = titleLabels[currentIndex]
        currentIndex = selectLabel.tag
        
        preLabel.textColor = style.normalColor
        selectLabel.textColor = style.selectColor
        
        //设置lineView的位置
        //计算textWidth
        UIView .animate(withDuration: 0.25) {

            if self.style.isFixedLineWidth {
                //固定宽度的权限最高
                self.lineView.frame.origin.x = selectLabel.frame.origin.x + selectLabel.frame.size.width / 2 - self.style.lineCenterWidth/2
            }else{
                if self.style.bottomAlginLabel{
                    self.lineView.frame.origin.x = selectLabel.frame.origin.x
                }else{
                    //使用center.x会有偏差，采用frame.x
                    self.lineView.frame.origin.x = (selectLabel.frame.size.width - self.widthForContent(selectLabel))/CGFloat(2) + selectLabel.frame.minX
                }
            }
            
            if self.style.isFixedLineWidth {
                self.lineView.frame.size.width = self.style.lineCenterWidth
            }else{
                self.lineView.frame.size.width = self.style.bottomAlginLabel ? selectLabel.frame.size.width : self.widthForContent(selectLabel)
            }

            if self.style.isShowFontScale{  //font缩放
                if selectLabel != preLabel {
                    selectLabel.font = UIFont.systemFont(ofSize: self.style.labelSelFont)
                    preLabel.font = UIFont.systemFont(ofSize: self.style.labelFont)
                }
            }else{

            }
        }

        if style.labelLayout == .scroll {
            
            if scrollView.contentSize.width <= bounds.size.width {
                return
            }
            //中间offset
            var offsetX = selectLabel.center.x - bounds.size.width*0.5
            //最大offset
            let maxOffset = scrollView.contentSize.width - bounds.width
            //最小offset
            if offsetX <= 0{
                offsetX = 0
            }else if offsetX >= maxOffset{
                offsetX = maxOffset
            }
            scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        }
    }
    
    @objc fileprivate func itemClick(_ tap:UITapGestureRecognizer){
        //获取目标item
        let selectLabel = tap.view as! UILabel
        //调整位置
        ajustViewPostion(selectLabel)
        //通知外部选中状态
        delegate?.pageView(pageView: self, selectIndex: currentIndex)
    }
    
    // MARK: 更新label 更新lineView
    func pageViewScroll(direction: MoveDirection,sourceIndex: Int,nextIndex:Int,progress:CGFloat){
        
        let currentLabel = titleLabels[sourceIndex]
        let nextLabel = titleLabels[nextIndex]
        
        //设置字体颜色渐变
        if style.isShowColorScale {
            let selectRGB = getGRBValue(style.selectColor)
            let normalRGB = getGRBValue(style.normalColor)
            let deltaRGB = (selectRGB.0 - normalRGB.0, selectRGB.1 - normalRGB.1, selectRGB.2 - normalRGB.2)
            currentLabel.textColor = UIColor(red: (selectRGB.0 - deltaRGB.0 * progress), green: selectRGB.1 - deltaRGB.1 * progress, blue: selectRGB.2 - deltaRGB.2 * progress, alpha: 1)
            nextLabel.textColor = UIColor(red: (normalRGB.0 + deltaRGB.0 * progress), green: normalRGB.1 + deltaRGB.1 * progress, blue: normalRGB.2 + deltaRGB.2 * progress, alpha: 1)
        }
        
        //设置lineView的渐变
        if style.isShowBottomLine {
            var deltaX:CGFloat = 0
            var deltaW:CGFloat = 0

            if style.isShowBottomLine{  //显示底部划线

                if style.moveAnimation == .fastScroll{  //快速滑动  类似微博
                    let currentLabelRealWidth = (style.bottomAlginLabel ?  currentLabel.width : widthForContent(currentLabel))
                    let currentDeltaW = (style.bottomAlginLabel ? 0 : (currentLabel.width - currentLabelRealWidth)/2.0)
                    let nextLabelRealWidth =  (style.bottomAlginLabel ?  nextLabel.width : widthForContent(nextLabel))
                    let nextDeltaW = (style.bottomAlginLabel ? 0 : (nextLabel.width - nextLabelRealWidth)/2.0)
                    let margin = style.labelMargin
                    //以滚动0.5为一个滚动循环 超过0.5则恢复
                    if progress <= 0.5{  //宽度变宽
                        if direction == .right{
                            deltaX =  currentLabel.x - (margin + nextDeltaW + nextLabelRealWidth)*progress*2
                        }else{
                            deltaX = currentLabel.x + currentDeltaW
                        }
                        deltaW = currentLabelRealWidth + (nextLabel.width - nextDeltaW + margin + currentDeltaW)*progress*2

                    }else{  // x轴变大
                        if direction == .right{
                            deltaX = nextLabel.x + nextDeltaW
                        }else{
                            deltaX = currentLabel.x + (currentLabel.width + nextDeltaW + margin)*(progress - 0.5)*2
                        }
                        deltaW = nextLabelRealWidth + (currentLabel.width - currentDeltaW + nextDeltaW + margin)*(1-progress)*2
                    }
                    lineView.frame = CGRect(x: deltaX, y: lineView.y, width: self.style.isFixedLineWidth ? self.style.lineCenterWidth : deltaW , height: lineView.height)

                }else{  //跟随动画
                    deltaX = nextLabel.center.x - currentLabel.center.x
                    lineView.center.x = currentLabel.center.x + deltaX*progress

                    if style.bottomAlginLabel {
                        deltaW = nextLabel.bounds.width - currentLabel.bounds.width
                    }else{
                        deltaW = widthForContent(nextLabel) - widthForContent(currentLabel)
                    }
                    lineView.frame.size.width = self.style.isFixedLineWidth ? self.style.lineCenterWidth : ((style.bottomAlginLabel ? currentLabel.frame.size.width : widthForContent(currentLabel)) + deltaW*progress)
                }
            }
        }
        
        //设置字体大小渐变
        if style.isShowFontScale {
            let deltaSize = style.labelSelFont - style.labelFont
            let currentSize = style.labelSelFont - deltaSize*progress
            let nextSize = style.labelFont + deltaSize*progress
            //目标字体 大小变化
            currentLabel.font = UIFont.systemFont(ofSize: currentSize)
            //下一个目标 大小变化
            nextLabel.font = UIFont.systemFont(ofSize: nextSize)
        }
    }
    
    /// 滚动结束 重试字体颜色 防止字体颜色出现异常
    func reloadColor(){
        let currentLabel = titleLabels[currentIndex]
        //未选中的使用默认颜色
        for lb in titleLabels {
            lb.textColor = style.normalColor
        }
        currentLabel.textColor = style.selectColor;
    }
    
    func pageViewScrollEnd(pageIndex:Int){
        
        //拿到选中的label
        let selectLabel = titleLabels[pageIndex]
        ajustViewPostion(selectLabel)
        reloadColor()
    }
    
    private func getGRBValue(_ color : UIColor) -> (CGFloat, CGFloat, CGFloat) {
        guard  let components = color.cgColor.components else {
            fatalError("文字颜色请按照RGB方式设置")
        }
        
        return (components[0], components[1], components[2])
    }
}
