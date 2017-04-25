//
//  UARMapDataProvider.h
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/6/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UARRoute;
@class UARMapDataProvider;
@class UARInstruction;

@protocol UARMapDataProviderDelegate

- (void)mapDataProvider:(UARMapDataProvider *)dataProvider didFindCurrentInstruction:(UARInstruction *)currentInstruction
        nextInstruction:(UARInstruction *)nextInstruction;

- (void)mapDataProvider:(UARMapDataProvider *)dataProvider
  didUpdateFullDistance:(NSInteger)distance
                   time:(NSInteger)time
currentInstructionDistance:(NSInteger)instructionDistance;

- (void)mapDataProvider:(UARMapDataProvider *)dataProvider didChangeToMapFollowing:(BOOL)following;

@end

@interface UARMapDataProvider : NSObject

@property (strong, nonatomic) UARRoute *route;

@property (weak, nonatomic) id <UARMapDataProviderDelegate> delegate;

- (instancetype)initWithMapView:(MKMapView *)mapView delegate:(id <UARMapDataProviderDelegate>)delegate;

- (void)moveToCurrentLocation;

- (void)increaseZoomLevel;

- (void)decreaseZoomLevel;


@end
