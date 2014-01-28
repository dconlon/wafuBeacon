//
//  BeaconViewController.m
//  simpeBeacon
//
//  Created by uehara akihiro on 2013/10/19.
//  Copyright (c) 2013年 REINFORCE Lab. All rights reserved.
//

#import "BeaconViewController.h"

@interface BeaconViewController () {
    CBPeripheralManager *_peripheralManager;
}
@property (weak, nonatomic) IBOutlet UISwitch *beaconSwitch;
@end

@implementation BeaconViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // ビーコン信号を発信する、ペリフェラルマネージャーを組み立てます
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self stopBeacon];
}
#pragma mark Private methods
-(void)startBeacon {
    [self stopBeacon];
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc]
                              initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:kBeaconUUID]
                              major:1 minor:2 identifier:kIdentifier];
    NSNumber *rssi = [NSNumber numberWithInteger:(int) self.rssiSlideBar.value];
    NSDictionary *advertisementData = [region peripheralDataWithMeasuredPower:rssi];
    
/* ビーコンのバイナリデータをみたいときは、これでダンプする
    for(id key in [advertisementData allKeys]) {
        NSLog(@"\tkey:%@ data:%@", key, [advertisementData objectForKey:key]);
    }
*/
    [_peripheralManager startAdvertising:advertisementData];
}
-(void)stopBeacon {
    if(_peripheralManager.isAdvertising) {
        [_peripheralManager stopAdvertising];
    }
}

#pragma mark Event handlers
- (IBAction)beaconSwitchValueChanged:(id)sender {
    // BTの電源がONになっているかを、確認します。
    if (_peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        [self showAleart:@"Bleutoothの電源が入っていません"];
        self.beaconSwitch.on = NO;
        return;
    }
    
    if(self.beaconSwitch.on) {
        [self startBeacon];
    } else {
        [self stopBeacon];
    }
}
- (IBAction)passButtonTouchUpInside:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPassBookURL]];
}

- (IBAction)rssiSliderValueChanged:(id)sender {
    self.rssiLabel.text = [NSString stringWithFormat:@"%d", (int)self.rssiSlideBar.value];
    
    if(_peripheralManager.isAdvertising) {
        [self startBeacon];
    }
}

#pragma mark CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    [self writeLog:[NSString stringWithFormat:@"%s\n", __PRETTY_FUNCTION__]];
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            break;
        case CBPeripheralManagerStatePoweredOff:
        case CBPeripheralManagerStateResetting:
        case CBPeripheralManagerStateUnauthorized:
        case CBPeripheralManagerStateUnknown:
        case CBPeripheralManagerStateUnsupported:
            _beaconSwitch.on = NO;
        default:
            break;
    }
}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    if(error != nil) {
        [self writeLog:[NSString stringWithFormat:@"%s\n%@", __PRETTY_FUNCTION__, error]];
    }
}
@end
