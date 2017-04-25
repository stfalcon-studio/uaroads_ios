//
//  MKPolyline+UARPolylineEncodedString.h
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/5/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolyline (UARPolylineEncodedString)

+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;

@end
