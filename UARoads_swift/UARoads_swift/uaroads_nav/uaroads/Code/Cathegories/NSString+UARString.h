//
//  NSString+UARString.h
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/27/15.
//  Copyright © 2015 mind-studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UARString)

+ (NSString *)stringFromDistance:(NSInteger)distance;

+ (NSString *)stringFromTime:(NSInteger)time;

@end
