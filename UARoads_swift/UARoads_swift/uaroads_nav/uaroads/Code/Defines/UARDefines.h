//
//  UARDefines.h
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/5/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const struct UARImages {
    __unsafe_unretained NSString *userLocation;
} UARImages;

extern const struct UARDefines {
    __unsafe_unretained NSString *openStreetMapTemplate;
    __unsafe_unretained NSString *uaroadTemplate;
    
} UARDefines;

typedef enum {
    UARInstructionDirectionNone,
    UARInstructionDirectionFollow,
    UARInstructionDirectionTakeRight,
    UARInstructionDirectionTurnRight,
    
    
} UARInstructionDirection;
