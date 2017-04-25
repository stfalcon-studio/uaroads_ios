//
//  UARRoute.m
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/6/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import "UARRoute.h"
#import "UARInstruction.h"

@interface UARRoute ()

@property (strong, nonatomic) NSMutableArray *routeInstructions;

@end

@implementation UARRoute

- (void)addInstructionToRoute:(UARInstruction *)instruction {
    if (!self.routeInstructions) {
        self.routeInstructions = [NSMutableArray new];
    }

    [self.routeInstructions addObject:instruction];
}

- (NSArray *)allInstructions {
    return [NSArray arrayWithArray:self.routeInstructions];
}

// Distance from current location to next instruction

- (NSInteger)leftDistanceFromLocation:(CLLocation *)location toNextInstruction:(NSInteger)instructionIndex {
    UARInstruction *nextInstruction = [self instructionWithIndex:instructionIndex];
    
    NSInteger leftInstructionDistance = [self leftDistanceToInstruction:nextInstruction fromlocation:location];
    return leftInstructionDistance;
}

// Distance from instruction to the end of route

- (NSInteger)fullDistanceFromLocation:(CLLocation *)location instructionIndex:(NSInteger)instructionIndex {
    
    NSArray *leftInstructions = [self leftInstructionFromIndex:instructionIndex];
    
    NSInteger leftDistance = 0;
    for (UARInstruction *instruction in leftInstructions) {
        leftDistance += instruction.distance;
    }
    leftDistance = leftDistance + [self leftDistanceFromLocation:location toNextInstruction:instructionIndex + 1];
    
    return leftDistance;
}

// Time from instruction to the end of route

- (NSInteger)leftTimeFromLocation:(CLLocation *)location instructionIndex:(NSInteger)instructionIndex {
    
    NSArray *leftInstructions = [self leftInstructionFromIndex:instructionIndex];
    
    NSInteger leftTime = 0;
    for (UARInstruction *instruction in leftInstructions) {
        leftTime += instruction.expectedTime;
    }
    UARInstruction *currentInstruction = [self instructionWithIndex:instructionIndex];
    NSInteger leftInstructionDistance = [self leftDistanceFromLocation:location toNextInstruction:instructionIndex + 1];
    NSInteger leftInstructionTime = 0;
    if (currentInstruction.distance > 0) {
        leftInstructionTime = leftInstructionDistance * currentInstruction.expectedTime / currentInstruction.distance;
    }
    leftTime = leftTime + leftInstructionTime;
    
    if (leftTime > 5 && leftTime < 60) {
        leftTime = 60;
    }
    
    return leftTime;
}

- (UARInstruction *)instructionWithIndex:(NSInteger)index {
    return self.allInstructions.count > index ? [self allInstructions][index] : nil;
}

- (NSArray *)leftInstructionFromIndex:(NSInteger)index {
    return [[self allInstructions] subarrayWithRange:NSMakeRange(index + 1, self.allInstructions.count - index - 1)];
}

// Distance from location to instruction

- (NSInteger)leftDistanceToInstruction:(UARInstruction *)instruction fromlocation:(CLLocation *)location {

    if (instruction) {
        CLLocation *instructionLocation = [[CLLocation alloc] initWithLatitude:instruction.coordinate.latitude
                                                                     longitude:instruction.coordinate.longitude];
        
        NSInteger leftInstructionDistance = [location distanceFromLocation:instructionLocation];
        
        return leftInstructionDistance;
    } else {
        return 0;
    }
}

@end
