//
//  UARRouteJSONParser.h
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/6/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UARRoute;

@interface UARRouteJSONParser : NSObject

- (UARRoute *)routeFromJSONDictionary:(NSDictionary *)dictionary;

@end
