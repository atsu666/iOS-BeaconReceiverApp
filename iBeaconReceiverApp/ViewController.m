//
//  ViewController.m
//  iBeaconReceiverApp
//
//  Created by Atsushi Ito on 2014/03/20.
//  Copyright (c) 2014年 atsu666. All rights reserved.
//

#import "ViewController.h"

#define UUID        @"4DF4F424-546E-429C-8E3F-CE4319A9251A"
#define MAJOR       @"1"
#define MINOR       @"1"
#define IDENTIFIER  @"com.atsu666"

@interface ViewController ()

@property (strong, nonatomic) CLLocationManager     *manager;
@property (strong, nonatomic) CLBeaconRegion        *region;

@property (strong, nonatomic) NSUUID                *proximityUUID;
@property (strong, nonatomic) NSString              *identifier;
@property uint16_t                                  major;
@property uint16_t                                  minor;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if ( [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]] ) {
        
        // Create Manager
        self.manager            = [CLLocationManager new];
        self.manager.delegate   = self;
        
        // Create parameter
        self.proximityUUID      = [[NSUUID alloc]initWithUUIDString:UUID];
        self.identifier         = IDENTIFIER;
        self.major              = (uint16_t)[MAJOR integerValue];
        self.minor              = (uint16_t)[MINOR integerValue];
        
        // Create CLBeaconRegion
        self.region = [[CLBeaconRegion alloc]initWithProximityUUID:self.proximityUUID
                                                             major:self.major
                                                             minor:self.minor
                                                        identifier:self.identifier];
        self.region.notifyOnEntry               = YES;
        self.region.notifyOnExit                = YES;
        self.region.notifyEntryStateOnDisplay   = NO;
        
        [self.manager startMonitoringForRegion:self.region];
        [self.manager startRangingBeaconsInRegion:self.region];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    [self sendNotification:@"ようこそ！"];
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    [self sendNotification:@"さようなら！"];
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    // init
    NSString *uuid                          = @"unknown";
    CLProximity proximity                   = CLProximityUnknown;
    CLLocationAccuracy accuracy             = 0.0;
    NSInteger rssi                          = 0;
    NSNumber *major                         = @0;
    NSNumber *minor                         = @0;
    
    // near beacon
    CLBeacon *beacon    = beacons.firstObject;
    
    uuid                = beacon.proximityUUID.UUIDString;
    proximity           = beacon.proximity;
    accuracy            = beacon.accuracy;
    rssi                = beacon.rssi;
    major               = beacon.major;
    minor               = beacon.minor;
    
    // update view
    self.uuidLabel.text         = beacon.proximityUUID.UUIDString;
    self.majorLabel.text        = [NSString stringWithFormat:@"%@", major];
    self.minorLabel.text        = [NSString stringWithFormat:@"%@", minor];
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", accuracy];
    self.rssiLabel.text = [NSString stringWithFormat:@"%ld", (long)rssi];
    
    switch (proximity) {
        case CLProximityUnknown:
            self.proximityLabel.text    = @"CLProximityUnknown";
            break;
        case CLProximityImmediate:
            self.proximityLabel.text    = @"CLProximityImmediate";
            break;
        case CLProximityNear:
            self.proximityLabel.text    = @"CLProximityNear";
            break;
        case CLProximityFar:
            self.proximityLabel.text    = @"CLProximityFar";
            break;
        default:
            break;
    }
    
    if ( proximity == CLProximityUnknown ) {
        self.beconStateLabel.text   = @"UNKNOWN";
    } else {
        self.beconStateLabel.text   = @"ENTER";
    }
    
    if ( proximity == CLProximityImmediate && rssi > -40 ) {
        self.beconStateLabel.text   = @"TOUCH";
//        [self sendNotification:@"チェックアウトしました。"];
    }
}


- (void)sendNotification:(NSString*)message
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [[NSDate date] init];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = message;
    notification.alertAction = @"Open";
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
