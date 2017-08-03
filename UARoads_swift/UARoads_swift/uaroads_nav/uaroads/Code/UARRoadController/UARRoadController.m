//
//  ViewController.m
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/5/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import "UARRoadController.h"
#import "UARMapDataProvider.h"
#import "UARRouteJSONParser.h"
#import "UARInstruction.h"
#import "NSString+UARString.h"

@interface UARRoadController () <UARMapDataProviderDelegate>

@property (strong, nonatomic) UARMapDataProvider *mapDataProvider;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *nextStreetLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousStreetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nextInstructionImageView;
@property (weak, nonatomic) IBOutlet UILabel *nextInstructionDistanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapWidth;

@end

@implementation UARRoadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger mapSize = [[UIScreen mainScreen] bounds].size.height;
    self.mapWidth.constant = mapSize;
    self.mapHeight.constant = mapSize;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancel_icon.pdf"] style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
    [closeButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = closeButton;

    [self requestRouteWithCoordinates:@"loc=48.423400,35.008870&loc=48.435977,35.051813"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)requestRouteWithCoordinates:(NSString *)coordinates {
    
    NSString *routeURL = [NSString stringWithFormat:@"http://route.uaroads.com/viaroute?output=json&instructions=true&alt=false&%@", coordinates];
    
    __weak UARRoadController *weakSelf = self;
    
    self.mapDataProvider = [[UARMapDataProvider alloc] initWithMapView:weakSelf.mapView delegate:self];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:routeURL]
                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UARRouteJSONParser *parser = [UARRouteJSONParser new];
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
        
        UARRoute *route = [parser routeFromJSONDictionary:responseObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.mapDataProvider.route = route;
        });
    }] resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    self.mapDataProvider = nil;
    
    if ([keyPath isEqualToString:@"location"]) {
        NSString *newLocation = [change objectForKey:@"new"];
        [self requestRouteWithCoordinates:newLocation];
    }
}

- (IBAction)plusButtonAction:(id)sender {
    [self.mapDataProvider increaseZoomLevel];
}

- (IBAction)minusButtonAction:(id)sender {
    [self.mapDataProvider decreaseZoomLevel];
}

- (IBAction)currentLocationButtonAction:(id)sender {
    [self.mapDataProvider moveToCurrentLocation];
}

- (IBAction)closeAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

#pragma mark - UARMapDataProviderDelegate

- (void)mapDataProvider:(UARMapDataProvider *)dataProvider didFindCurrentInstruction:(UARInstruction *)currentInstruction
        nextInstruction:(UARInstruction *)nextInstruction {

    self.previousStreetLabel.text = currentInstruction ? currentInstruction.streetName : @"";
    self.nextStreetLabel.text = nextInstruction ? nextInstruction.streetName : @"";
    self.nextInstructionImageView.image = nextInstruction ? nextInstruction.instructionImage : nil;
    self.nextInstructionDistanceLabel.text = currentInstruction ? [NSString stringFromDistance:currentInstruction.distance] : @"";
}

- (void)mapDataProvider:(UARMapDataProvider *)dataProvider didUpdateFullDistance:(NSInteger)distance
                   time:(NSInteger)time currentInstructionDistance:(NSInteger)instructionDistance {
    
    NSString *leftDistance = [NSString stringFromDistance:distance];
    NSString *leftTime = [NSString stringFromTime:time];
    self.navigationItem.title = [NSString stringWithFormat:@"%@, %@", leftTime, leftDistance];
    self.nextInstructionDistanceLabel.text = [NSString stringFromDistance:instructionDistance];
}

- (void)mapDataProvider:(UARMapDataProvider *)dataProvider didChangeToMapFollowing:(BOOL)following {
    self.currentLocationButton.hidden = following;
}

@end
