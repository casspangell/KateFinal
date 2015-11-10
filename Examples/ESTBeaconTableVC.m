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
    self.beaconsArray = [NSMutableArray new];
    
    self.colors = [self getColors];

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

    for (int i=0; i<[beacons count]; i++) {
        
        BubbleObject *bubbleObject = [BubbleObject new];

        CLBeacon *beacon = [beacons objectAtIndex:i];
        
        //if dictionary doesn't contain the found beacon add it.
        //otherwise just update the beacon
        if (!self.beaconDict[beacon.major]) {
            
            [bubbleObject setBeacon:beacon];
            [bubbleObject setUuid:[beacon.major stringValue]];
            
            //add color but remove it from the list
//            NSLog(@"%@", [self.colors lastObject]);
            [bubbleObject setColor:[self.colors lastObject]];
            [self.colors removeObject:[self.colors lastObject]];
            
            [bubbleObject setPosition:[self.beaconDict count]+1];
            
            //add beacon to dict
            [self.beaconDict setObject:bubbleObject forKey:beacon.major];
            
        }else{
            bubbleObject = [self.beaconDict objectForKey:beacon.major];
            [bubbleObject setBeacon:beacon];
            [self.beaconDict setObject:bubbleObject forKey:beacon.major];
        }
        
        NSLog(@"%@", [self.beaconDict description]);
    }
    
    [self updateBeacons];
}

- (void)utilityManager:(ESTUtilityManager *)manager didDiscoverBeacons:(NSArray *)beacons
{

}

#pragma mark - Display Beacons

- (void)updateBeacons {
    
    //Set drawing for each bubble
    [self setDiameter:70.0/2];
    
    __block int counter = 0;
    [self.beaconDict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        counter ++;
        
        self.bubbleObject = obj;
        float division = (self.view.frame.size.height / ([self.beaconDict count]+1));
        
        //Add bubble drawing
        if (!self.bubbleObject.bubble) {
            Bubble *drawing = [[Bubble alloc] initWithFrame:CGRectMake(0, division*self.bubbleObject.position, mdiameter, mdiameter) andDiameter:mdiameter andLineWidth:1 andColor:self.bubbleObject.color];
            [self.bubbleObject setBubble:drawing];
            [self.view addSubview:self.bubbleObject.bubble];
        }else{
            //update frame
            float step = mdiameter;
            self.beacon = self.bubbleObject.beacon;
            
            if (self.beacon.accuracy > 0) {
                [UIView animateWithDuration:2.0 animations:^(void) {
                    [self.bubbleObject.bubble setFrame:CGRectMake(self.beacon.accuracy*step*10, division*self.bubbleObject.position, mdiameter, mdiameter)];
                }];
                
//                NSLog(@"%@ %f v %f", bubbleObject.beacon.major, bubbleObject.previousAccuracy, beacon.accuracy);
                
                float percentage = fabs(self.bubbleObject.previousAccuracy - self.beacon.accuracy);
                NSLog(@"%f - %f = %f", self.bubbleObject.previousAccuracy, self.beacon.accuracy, percentage*10);
                
                
                if (percentage*10 >=.2 && percentage*10 <.5) {
                    [self.bubbleObject.bubble setAlpha:8.0];
                    [UIView animateWithDuration:.2 animations:^(void) {
                        [self.bubbleObject.bubble setAlpha:1.0];
                        [self.bubbleObject.bubble setFrame:CGRectMake(self.beacon.accuracy*step*10, division*self.bubbleObject.position, mdiameter, mdiameter)];
                    }];
                }else if(percentage*10 >.5 && percentage*10 <.7){
                    [self.bubbleObject.bubble setAlpha:6.0];
                    [UIView animateWithDuration:.4 animations:^(void) {
                        [self.bubbleObject.bubble setAlpha:1.0];
                        [self.bubbleObject.bubble setFrame:CGRectMake(self.beacon.accuracy*step*10, division*self.bubbleObject.position, mdiameter, mdiameter)];
                    }];
                }else if(percentage*10 >.7 && percentage*10 < 1.0){
                    [self.bubbleObject.bubble setAlpha:4.0];
                    [UIView animateWithDuration:.5 animations:^(void) {
                        [self.bubbleObject.bubble setAlpha:1.0];
                        [self.bubbleObject.bubble setFrame:CGRectMake(self.beacon.accuracy*step*10, division*self.bubbleObject.position, mdiameter, mdiameter)];
                    }];
                }else if (percentage*10 > 1.0){
                    [self.bubbleObject.bubble setAlpha:0.0];
                    [UIView animateWithDuration:1.0 animations:^(void) {
                        [self.bubbleObject.bubble setAlpha:1.0];
                        [self.bubbleObject.bubble setFrame:CGRectMake(self.beacon.accuracy*step*10, division*self.bubbleObject.position, mdiameter, mdiameter)];
                    }];
                }else{
                    
                }


            }
            
            self.bubbleObject.previousAccuracy = self.beacon.accuracy;
        }
        
    }];
    
}

-(void)setDiameter:(double)dmeter{
    mdiameter = dmeter;
}

-(double)getDiameter{
    return mdiameter;
}

-(NSMutableArray*)getColors {
    NSMutableArray *colors = [NSMutableArray new];
   
    float INCREMENT = 0.1;
    for (float hue = 0.0; hue < 1.0; hue += INCREMENT) {
        UIColor *color = [UIColor colorWithHue:hue
                                    saturation:1.0
                                    brightness:1.0
                                         alpha:1.0];
        [colors addObject:color];
        
    }
 NSLog(@"%@", colors);
    return colors;
}


@end
