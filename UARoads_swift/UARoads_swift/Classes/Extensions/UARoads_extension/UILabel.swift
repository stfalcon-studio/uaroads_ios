//
//
//  Created by Roman Rybachenko on 2/21/17.
//  Copyright © 2017 UARoads. All rights reserved.
//

import UIKit

public extension UILabel {
    public func setTextWithLineSpacing(text: String, lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(kCTParagraphStyleAttributeName as NSAttributedStringKey,
                                      value: paragraphStyle,
                                      range: range)
        self.attributedText = attributedString
    }
    
    public func boundingRectForCharacterRange(range: NSRange) -> CGRect? {
        guard let attributedText = attributedText else { return nil }
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        layoutManager.addTextContainer(textContainer)

        var glyphRange = NSRange()
        
        // Convert the range for glyphs.
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }
}
