//
//  UARRoute.h
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/6/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UARInstruction;

@interface UARRoute : NSObject

@property (assign, nonatomic) CLLocationCoordinate2D initialLocation;
@property (assign, nonatomic) CLLocationCoordinate2D destinationLocation;
@property (strong, nonatomic) MKPolyline *routePolyline;
@property (assign, nonatomic) CLLocationCoordinate2D *allCoordinates;

- (NSArray *)allInstructions;

- (void)addInstructionToRoute:(UARInstruction *)instruction;

- (UARInstruction *)instructionWithIndex:(NSInteger)index;

- (NSInteger)leftDistanceFromLocation:(CLLocation *)location toNextInstruction:(NSInteger)instructionIndex;

- (NSInteger)fullDistanceFromLocation:(CLLocation *)location instructionIndex:(NSInteger)instructionIndex;

- (NSInteger)leftTimeFromLocation:(CLLocation *)location instructionIndex:(NSInteger)instructionIndex;

@end
