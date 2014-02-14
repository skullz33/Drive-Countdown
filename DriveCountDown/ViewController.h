//
//  ViewController.h
//  DriveCountDown
//
//  Created by Matt B on 1/21/14.
//  Copyright (c) 2014 Matt Blessed. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kRefreshSellers   0
#define kRefreshHomerooms 1

#define kAverageDriveTotalIncrease 0.10613611111111f

#define kAverageDriveHourIncrease   3820.5f
#define kAverageDriveMinuteIncrease 64.84f
#define kAverageDriveSecondIncrease 1.0613611111111f

#define kNotificationNameRefreshTotal @"refreshTotal"
#define kNotificationNameResetAlerts @"resetAlerts"

#define kKeySellerDict @"SellerDict"
#define kKeyHomeroomDict @"HomeroomDict"

@interface ViewController : UIViewController {
    int currentRefresh;
    NSString *driveTotalString;
    
    float driveTotalIncreaseBy;
    int timeSeconds;
    int baseDriveTotal;
    int oldBaseDriveTotal;
    
    BOOL dayIsFirstDay;
    BOOL dayIsFirstWeekend;
    BOOL dayIsWeekDay;
    BOOL dayIsLastWeekend;
    
    float driveTotalInt;
    
}

@property (weak, nonatomic) IBOutlet UILabel *TopSeller1;
@property (weak, nonatomic) IBOutlet UILabel *TopSeller2;
@property (weak, nonatomic) IBOutlet UILabel *TopSeller3;
@property (weak, nonatomic) IBOutlet UILabel *TopSeller4;
@property (weak, nonatomic) IBOutlet UILabel *TopSeller5;

@property (weak, nonatomic) IBOutlet UILabel *TopHomeroom1;
@property (weak, nonatomic) IBOutlet UILabel *TopHomeroom2;
@property (weak, nonatomic) IBOutlet UILabel *TopHomeroom3;
@property (weak, nonatomic) IBOutlet UILabel *TopHomeroom4;
@property (weak, nonatomic) IBOutlet UILabel *TopHomeroom5;

@property (weak, nonatomic) IBOutlet UILabel *driveTotalLabel;

@property (nonatomic) BOOL tooEarlyAlertShown;
@property (nonatomic) BOOL easterEggAlertShown;

@property (strong,nonatomic) UIAlertView *error;

-(void)refreshDriveTotal;
@end
