//
//  UARInstruction.h
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/12/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UARInstruction : NSObject

@property (strong, nonatomic) NSString *instructionTitle;
@property (strong, nonatomic) UIImage *instructionImage;
@property (strong, nonatomic) NSString *azimuth;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSString *streetName;
@property (assign, nonatomic) NSInteger distance;
@property (assign, nonatomic) NSInteger expectedTime;
@property (assign, nonatomic) NSInteger coordinateIndex;

- (instancetype)initWithData:(NSArray *)dataArray coordinates:(CLLocationCoordinate2D *)coordinates;

@end
