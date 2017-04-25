//
//  UARMapDataProvider.m
//  uaroads
//
//  Created by Kryzhanovskyi Anton on 9/6/15.
//  Copyright (c) 2015 mind-studios. All rights reserved.
//

#import "UARMapDataProvider.h"
#import "UARRoute.h"
#import "UARInstruction.h"

#define DEGREES_TO_RADIANS(degrees) ((degrees / 180.0) * (M_PI))
static const NSInteger kInitialZoomLevel = 16;
static const NSInteger kMaxZoomLevel = 16;
static const NSInteger kRoadWidth = 10;
static const CGFloat kCoordinateDelta = 0.00016;
static const NSInteger kUndefinedPoint = 999999;
static const double kCorrectionAngle = 3;

@interface UARMapDataProvider () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKAnnotationView *userLocationView;
@property (strong, nonatomic) CLLocation *location;
@property (assign, nonatomic) BOOL isInitialLocationSetup;
@property (assign, nonatomic) BOOL mapChangedFromUserInteraction;
@property (assign, nonatomic) NSInteger currentInstructionIndex;
@property (assign, nonatomic) NSInteger zoomLevel;

@end

@implementation UARMapDataProvider

- (instancetype)initWithMapView:(MKMapView *)mapView delegate:(id <UARMapDataProviderDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
        self.mapView.delegate = self;
        self.mapView.userTrackingMode = MKUserTrackingModeFollow;
        self.mapView.rotateEnabled = NO;
        self.delegate = delegate;
        self.zoomLevel = kInitialZoomLevel;
        [self setupLocationManager];
        
// This is done for reloading user loaction annotation
        self.mapView.showsUserLocation = NO;
        self.mapView.showsUserLocation = YES;
    }
    return self;
}

- (void)setRoute:(UARRoute *)route {
    _route = route;
    [self setupRoute];
}

- (void)setupRoute {
    [self.locationManager startUpdatingLocation];
    [self setupInstructionsWithIndex:self.currentInstructionIndex];
    
    for (id polyline in self.mapView.overlays) {
        if ([polyline isKindOfClass:[MKPolyline class]]) {
            [self.mapView removeOverlay:polyline];
        }
    }
    
    [self.mapView addOverlay:self.route.routePolyline];
}

- (void)setupLocationManager {
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.headingFilter = 15;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}

- (void)setPositionWithCoordinate:(CLLocationCoordinate2D)initialCoordinate {
    
    [self.mapView setCenterCoordinate:initialCoordinate zoomLevel:self.zoomLevel animated:YES];
}

- (void)setupOverlays {
    
    MKTileOverlay *openStreetMapOverlay = [[MKTileOverlay alloc] initWithURLTemplate:UARDefines.openStreetMapTemplate];
    openStreetMapOverlay.canReplaceMapContent = YES;
    [self.mapView addOverlay:openStreetMapOverlay level:MKOverlayLevelAboveLabels];
    
    MKTileOverlay *roadOverlay = [[MKTileOverlay alloc] initWithURLTemplate:UARDefines.uaroadTemplate];
    roadOverlay.canReplaceMapContent = YES;
    [self.mapView addOverlay:roadOverlay level:MKOverlayLevelAboveLabels];
}

- (void)setupInstructionsWithIndex:(NSInteger)index {
    [self.delegate mapDataProvider:self
         didFindCurrentInstruction:[self.route instructionWithIndex:index]
                  nextInstruction:[self.route instructionWithIndex:index + 1]];
}

- (UARInstruction *)instructionForCoordinates:(CLLocationCoordinate2D)coordinates {
    for (UARInstruction *instruction in [self.route allInstructions]) {
        
        if (fabs(instruction.coordinate.latitude - coordinates.latitude) <= kCoordinateDelta &&
             fabs(instruction.coordinate.longitude - coordinates.longitude) <= kCoordinateDelta) {
            return instruction;
        }
    }
    
    NSInteger currentPointIndex = [self currentPointIndexForCoordinates:coordinates];
    if (currentPointIndex != kUndefinedPoint && [self.route allInstructions].count > self.currentInstructionIndex + 1) {
        UARInstruction *currentInstruction = [[self.route allInstructions] objectAtIndex:self.currentInstructionIndex + 1];
        if (currentPointIndex > currentInstruction.coordinateIndex) {
            for (UARInstruction *instruction in [self.route allInstructions]) {
                if (instruction.coordinateIndex < currentPointIndex) {
                    currentInstruction = instruction;
                } else {
                    return currentInstruction;
                }
            }
        }
    }
    return nil;
}

- (void)clearPolylineForCoordinates:(CLLocationCoordinate2D)coordinates {
    
    NSInteger currentIndex = [self currentPointIndexForCoordinates:coordinates];
    
    if (currentIndex != kUndefinedPoint) {
        NSInteger newRoutPointsCount = self.route.routePolyline.pointCount - currentIndex;
        
        CLLocationCoordinate2D *routeCoordinates = malloc(newRoutPointsCount * sizeof(CLLocationCoordinate2D));
        [self.route.routePolyline getCoordinates:routeCoordinates range:NSMakeRange(currentIndex, newRoutPointsCount)];
        MKPolyline *newPolyline = [MKPolyline polylineWithCoordinates:routeCoordinates count:newRoutPointsCount];
        [self.mapView addOverlay:newPolyline];
        
        for (id polyline in self.mapView.overlays) {
            if ([polyline isKindOfClass:[MKPolyline class]] && polyline != newPolyline) {
                [self.mapView removeOverlay:polyline];
            }
        }
    }
}

- (NSInteger)currentPointIndexForCoordinates:(CLLocationCoordinate2D)currentCoordinates {
    if (self.route.routePolyline.pointCount) {
        for (NSInteger index = 0; index < self.route.routePolyline.pointCount; index++) {
            CLLocationCoordinate2D coordinate = self.route.allCoordinates[index];
            if (fabs(coordinate.latitude - currentCoordinates.latitude) <= kCoordinateDelta &&
                fabs(coordinate.longitude - currentCoordinates.longitude) <= kCoordinateDelta) {
                return index;
            }
        }
    }
    
    return kUndefinedPoint;
}

- (void)moveToCurrentLocation {

    [self setPositionWithCoordinate:self.locationManager.location.coordinate];
    self.mapChangedFromUserInteraction = NO;
    [self.delegate mapDataProvider:self didChangeToMapFollowing:YES];
}

- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    UIView *view = self.mapView.subviews.firstObject;
    //  Look through gesture recognizers to determine whether this region change is from user interaction
    for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
            return YES;
        }
    }
    
    return NO;
}

- (void)increaseZoomLevel {
    if (self.zoomLevel < kMaxZoomLevel) {
        self.zoomLevel++;
    }
    [self setPositionWithCoordinate:self.mapView.centerCoordinate];
}

- (void)decreaseZoomLevel {
    if (self.zoomLevel > 0) {
        self.zoomLevel--;
    }
    [self setPositionWithCoordinate:self.mapView.centerCoordinate];
}

- (void)updateDistanceForCurrentInstruction:(NSInteger)index {

    NSInteger leftDistance = [self.route fullDistanceFromLocation:self.location instructionIndex:index];
    NSInteger leftTime = [self.route leftTimeFromLocation:self.location instructionIndex:index];
    NSInteger instructionDistance = [self.route leftDistanceFromLocation:self.location toNextInstruction:index + 1];
    
    [self.delegate mapDataProvider:self didUpdateFullDistance:leftDistance time:leftTime currentInstructionDistance:instructionDistance];
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay {
    if ([overlay isKindOfClass:[MKTileOverlay class]]) {
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    } else {
        MKPolylineRenderer *lineView = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        lineView.strokeColor = [UIColor roadColor];
        lineView.lineWidth = kRoadWidth;
        return lineView;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString* annotationIdentifier = @"annotation";
    if (annotation == mapView.userLocation) {
        self.userLocationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        self.userLocationView.image = [UIImage imageNamed:UARImages.userLocation];
        return self.userLocationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];
    if (self.mapChangedFromUserInteraction) {
        [self.delegate mapDataProvider:self didChangeToMapFollowing:NO];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.location = [locations lastObject];
    
    // Setup overlays on the map after first getting current user location
    if (!self.isInitialLocationSetup) {
        self.isInitialLocationSetup = YES;
        [self setupOverlays];
    }
    
    // Make user location always in the center of the screen
    if (!self.mapChangedFromUserInteraction) {
        
        [self setPositionWithCoordinate:self.location.coordinate];
    }

    if (self.route && self.route.allInstructions.count) {
        UARInstruction *currentInstruction = [self instructionForCoordinates:self.location.coordinate];
        if (currentInstruction) {
            self.currentInstructionIndex = [[self.route allInstructions] indexOfObject:currentInstruction];
            [self setupInstructionsWithIndex:self.currentInstructionIndex];
        }
        
        [self updateDistanceForCurrentInstruction:self.currentInstructionIndex];
        
        [self clearPolylineForCoordinates:self.location.coordinate];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {

    if (newHeading.headingAccuracy > 0) {
        double degrees = newHeading.magneticHeading + kCorrectionAngle > 360 ? newHeading.magneticHeading + kCorrectionAngle - 360 : newHeading.magneticHeading + kCorrectionAngle;
        double radians = DEGREES_TO_RADIANS(degrees);
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.mapView setTransform:CGAffineTransformMakeRotation(-radians)];
            [self.userLocationView setTransform:CGAffineTransformMakeRotation(radians)];
        }];
    }
}

@end
