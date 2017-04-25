//
//  UARInstruction.m
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/12/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import "UARInstruction.h"

static const NSString *kTitleKey = @"title";
static const NSString *kImageKey = @"image";

@implementation UARInstruction

- (instancetype)initWithData:(NSArray *)dataArray coordinates:(CLLocationCoordinate2D *)coordinates {
    self = [super init];
    if (self) {
        [self parseData:dataArray coordinates:coordinates];
    }
    return self;
}

- (void)parseData:(NSArray *)dataArray coordinates:(CLLocationCoordinate2D *)coordinates {
    NSInteger directionNumber = [[dataArray firstObject] integerValue];
    self.instructionTitle = [[self.directions objectAtIndex:directionNumber] objectForKey:kTitleKey];
    self.instructionImage = [UIImage imageNamed:[[self.directions objectAtIndex:directionNumber] objectForKey:kImageKey]];
    self.coordinateIndex = [dataArray[3] integerValue];
    self.coordinate = coordinates[self.coordinateIndex];
    self.streetName = dataArray[1];
    self.distance = [dataArray[2] integerValue];
    self.expectedTime = [dataArray[4] integerValue];
    
    if (directionNumber == 15) {
        self.streetName = @"Пункт призначення";
    }
}

- (NSArray *)directions {
    
    return @[@{kTitleKey : @"Неизвестная инструкция", kImageKey : @""},
             @{kTitleKey : @"Продолжайте движение", kImageKey : @"sign_streight"},
             @{kTitleKey : @"Примите вправо", kImageKey : @"sign_righter"},
             @{kTitleKey : @"Поверните направо", kImageKey : @"sign_right"},
             @{kTitleKey : @"Поверните резко направо", kImageKey : @"sign_sharp_right"},
             @{kTitleKey : @"U­образный разворот", kImageKey : @"sign_turnaround"},
             @{kTitleKey : @"Поверните резко налево", kImageKey : @"sign_slightly_left"},
             @{kTitleKey : @"Поверните налево", kImageKey : @"sign_left"},
             @{kTitleKey : @"Примите влево", kImageKey : @"sign_lefter"},
             @{kTitleKey : @"Направляйтесь на %@", kImageKey : @"sign_streight"},
             @{kTitleKey : @"Начальное положение", kImageKey : @"final_destination"},
             @{kTitleKey : @"EnterRoundAbout", kImageKey : @"sign_cricle"},
             @{kTitleKey : @"LeaveRoundAbout", kImageKey : @"sign_cricle"},
             @{kTitleKey : @"StayOnRoundAbout", kImageKey : @"sign_cricle"},
             @{kTitleKey : @"StartAtEndOfStreet", kImageKey : @"sign_cricle"},
             @{kTitleKey : @"Конечное местоположение", kImageKey : @"final_destination"},
             @{kTitleKey : @"ReachedYourDestination", kImageKey : @""},
             @{kTitleKey : @"EnterAgainstAllowedDirection", kImageKey : @""},
             @{kTitleKey : @"LeaveAgainstAllowedDirection", kImageKey : @""},
             @{kTitleKey : @"InverseAccessRestrictionFlag", kImageKey : @""},
             @{kTitleKey : @"AccessRestrictionFlag", kImageKey : @""}
             ];
}

@end
