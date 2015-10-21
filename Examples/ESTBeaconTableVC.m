//
//  ESTBeaconTableVC.m
//  DistanceDemo
//
//  Created by Grzegorz Krukiewicz-Gacek on 17.03.2014.
//  Copyright (c) 2014 Estimote. All rights reserved.
//

#import "ESTBeaconTableVC.h"
#import "ESTViewController.h"
#import "BubbleObject.h"

#define MAX_DISTANCE 20
#define TOP_MARGIN   150

@interface ESTBeaconTableVC () <ESTBeaconManagerDelegate, ESTUtilityManagerDelegate> {
    int count;
    double mdiameter;
    double lWidth;
}
@end

@implementation ESTBeaconTableVC

- (id)initWithScanType:(ESTScanType)scanType completion:(void (^)(id))completion
{
    self = [super init];
    if (self)
    {
        self.scanType = scanType;
        self.completion = [completion copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.utilityManager = [[ESTUtilityManager alloc] init];
    self.utilityManager.delegate = self;
    
    self.beaconDict = [NSMutableDictionary new];
//    self.colorsWithBeacon = [NSMutableDictionary new];
    self.beaconsArray = [NSMutableArray new];
//    self.beaconsDictionary = [NSDictionary new];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    /* 
     * Creates sample region object (you can additionaly pass major / minor values).
     *
     * We specify it using only the ESTIMOTE_PROXIMITY_UUID because we want to discover all
     * hardware beacons with Estimote's proximty UUID.
     */
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                      identifier:@"EstimoteSampleRegion"];

    /*
     * Starts looking for Estimote beacons.
     * All callbacks will be delivered to beaconManager delegate.
     */
    if (self.scanType == ESTScanTypeBeacon)
    {
        [self startRangingBeacons];
    }
    else
    {
        [self.utilityManager startEstimoteBeaconDiscovery];
    }
}

-(void)startRangingBeacons
{
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self.beaconManager requestAlwaysAuthorization];
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    /*
     *Stops ranging after exiting the view.
     */
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
    [self.utilityManager stopEstimoteBeaconDiscovery];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Ranging error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Monitoring error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{

    NSArray *colors = [self getColors];

    for (int i=0; i<[beacons count]; i++) {
        
        BubbleObject *bubbleObject = [BubbleObject new];
//        Bubble *bubble = [Bubble new];
        
        CLBeacon *beacon = [beacons objectAtIndex:i];
        [bubbleObject setBeacon:beacon];
        [bubbleObject setUuid:[beacon.major stringValue]];
        [bubbleObject setColor:[colors objectAtIndex:i]];
        
        [self.beaconDict setObject:bubbleObject forKey:beacon.major];
        
        [self setDiameter:35.0];
        
//        NSLog(@"%@", [self.beaconDict description]);
    }
    
    [self updateBeacons];
}

- (void)utilityManager:(ESTUtilityManager *)manager didDiscoverBeacons:(NSArray *)beacons
{

}

#pragma mark - Display Beacons

- (void)updateBeacons {

//    CLBeacon __block *beacon = [CLBeacon new];

    float division = self.view.frame.size.height / [self.beaconDict count]+1;
    [self setDiameter:70.0/2];
    
    __block int counter = 0;
    [self.beaconDict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        counter ++;
        
        BubbleObject *bubbleObject = obj;
        NSLog(@"%@ %f", bubbleObject.uuid, self.view.frame.size.height/counter);
        
        self.drawing = [[Bubble alloc] initWithFrame:CGRectMake(0, division*counter, mdiameter, mdiameter) andDiameter:mdiameter andLineWidth:3 andColor:bubbleObject.color];
        [self.view addSubview:self.drawing];
        
        
        
        
        
        
        
//        float position = self.view.frame.size.height / bubbleObject.position;
        
        
        
//        self.drawing = [[Bubble alloc] initWithFrame:CGRectMake(0, position, mdiameter, mdiameter) andDiameter:mdiameter andLineWidth:3 andColor:bubbleObject.color];
//        [self.view addSubview:self.drawing];
        
//        [UIView animateWithDuration:0.5 animations:^(void) {
//            self.drawing.alpha = 0;
//            [self.drawing removeFromSuperview];
//        }];
        
        
    }];
    
//    NSLog(@"%@", [self.beaconDict description]);
//    NSLog(@"%@", [self.colorsWithBeacon description]);
    
//    int __block counter = 0;
//    [self.beaconDict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
//        counter ++;
//        beacon = obj;
//        
//        [self setDiameter:70.0/2];
//        
//        float locationY = self.view.frame.size.height/(counter);
//        NSLog(@"position %f counter %d count %d", locationY, counter, [self.beaconsArray count]);
//        float step = (self.view.frame.size.width / mdiameter);
//        
//        float distance = beacon.accuracy*30;
//
//        float newX = (distance * step);
//        NSLog(@"#%@ distance: %f newX %f step %f", beacon.major, beacon.accuracy, newX, step);
//        self.drawing = [[Bubble alloc] initWithFrame:CGRectMake(newX, locationY, mdiameter, mdiameter) andDiameter:mdiameter andLineWidth:lWidth andColor:self.colorsWithBeacon[beacon.major]];
//
//        [self.view addSubview:self.drawing];
//        
//        self.drawing.alpha = 0;
//        [UIView animateWithDuration:0.5 animations:^(void) {
//            
//            self.drawing.alpha = 1;
//        
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:1.0 animations:^{
//                
//                self.drawing.alpha = 0;
//                
//            } completion:^(BOOL finished) {
//                [self.drawing removeFromSuperview];
//            }];
//        }];
//        
////        [UIView animateWithDuration:beacon.accuracy*70 animations:^(void) {
////            self.drawing.transform = CGAffineTransformMakeScale(4.5, 4.5);
////            
////        }];
//        
//    }];
    
}


-(void)setDiameter:(double)dmeter{
    mdiameter = dmeter;
}

-(double)getDiameter{
    return mdiameter;
}

-(NSArray*)getColors {
    NSMutableArray *colors = [NSMutableArray new];
    
    float INCREMENT = 0.1;
    for (float hue = 0.0; hue < 1.0; hue += INCREMENT) {
        UIColor *color = [UIColor colorWithHue:hue
                                    saturation:1.0
                                    brightness:1.0
                                         alpha:1.0];
        [colors addObject:color];
        
    }
    
    return colors;
}


@end