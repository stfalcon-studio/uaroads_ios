//
//  UARCircleButton.m
//  
//
//  Created by Kryzhanovskyi Anton on 9/19/15.
//
//

#import "UARCircleButton.h"

@implementation UARCircleButton

- (void)awakeFromNib
{
    CGRect oldFrame = self.frame;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.path = maskPath.CGPath;
    
    self.frame = oldFrame;
    
    self.layer.mask = maskLayer;
    self.layer.masksToBounds = YES;
}

@end
