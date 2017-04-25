//
//  NSString+UARString.m
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/27/15.
//  Copyright © 2015 mind-studios. All rights reserved.
//

#import "NSString+UARString.h"

@implementation NSString (UARString)

+ (NSString *)stringFromDistance:(NSInteger)distance {
    NSMutableString *distanceString = [NSMutableString new];
    NSInteger kilometers = distance / 1000;
    if (kilometers) {
        [distanceString appendString:[NSString stringWithFormat:@"%li км ", kilometers]];
    }
    NSInteger meters = distance - kilometers * 1000;
    [distanceString appendString:[NSString stringWithFormat:@"%li м", meters]];
    return [NSString stringWithString:distanceString];
}

+ (NSString *)stringFromTime:(NSInteger)time {
    NSMutableString *timeString = [NSMutableString new];
    NSInteger hours = time / 3600;
    if (hours) {
        [timeString appendString:[NSString stringWithFormat:@"%li г", hours]];
    }
    NSInteger minutes = (time - hours * 3600) / 60;
    [timeString appendString:[NSString stringWithFormat:@"%li хв", minutes]];
    return [NSString stringWithString:timeString];
}

@end
