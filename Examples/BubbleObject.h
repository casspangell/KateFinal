//
//  BubbleObject.h
//  Examples
//
//  Created by Cass Pangell on 10/21/15.
//  Copyright © 2015 com.estimote. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EstimoteSDK/EstimoteSDK.h>
#import "Bubble.h"

@interface BubbleObject : NSObject

@property Bubble *bubble;
@property NSString *uuid;
@property UIColor *color;
@property CLBeacon *beacon;
@property int position;
@property CLLocationAccuracy previousAccuracy;

@end
