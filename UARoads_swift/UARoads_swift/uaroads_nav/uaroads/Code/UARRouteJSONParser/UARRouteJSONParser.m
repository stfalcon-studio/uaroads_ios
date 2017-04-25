//
//  UARRouteJSONParser.m
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/6/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import "UARRouteJSONParser.h"
#import "UARRoute.h"
#import "UARInstruction.h"
#import "MKPolyline+UARPolylineEncodedString.h"

@implementation UARRouteJSONParser

- (UARRoute *)routeFromJSONDictionary:(NSDictionary *)dictionary {
    
    UARRoute *route = [UARRoute new];
    
    NSString *routeGeometry = [dictionary objectForKey:@"route_geometry"];
    route.routePolyline = [MKPolyline polylineWithEncodedString:routeGeometry];
    
    NSUInteger pointCount = route.routePolyline.pointCount;
    CLLocationCoordinate2D *allRouteCoordinates = malloc(pointCount * sizeof(CLLocationCoordinate2D));
    [route.routePolyline getCoordinates:allRouteCoordinates range:NSMakeRange(0, pointCount)];
    route.initialLocation = CLLocationCoordinate2DMake(allRouteCoordinates[0].latitude, allRouteCoordinates[0].longitude);
    route.allCoordinates = allRouteCoordinates;
    
    NSArray *instructions = [dictionary objectForKey:@"route_instructions"];
    for (NSArray *instructionData in instructions) {
        UARInstruction *instruction = [[UARInstruction alloc] initWithData:instructionData coordinates:allRouteCoordinates];
        [route addInstructionToRoute:instruction];
    }
    
    return route;
}

@end
