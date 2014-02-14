//
//  ViewController.m
//  DriveCountDown
//
//  Created by Matt B on 1/21/14.
//  Copyright (c) 2014 Matt Blessed. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    driveTotalInt = 0.0;
    
    [self displaySavedSellers];
    [self displaySavedHomerooms];
    
    dayIsFirstDay = NO;
    dayIsFirstWeekend = NO;
    dayIsLastWeekend = NO;
    dayIsWeekDay = NO;
    
    driveTotalIncreaseBy = 0;
    oldBaseDriveTotal = 0;
    
    self.driveTotalLabel.alpha = 0.0f;
    
   // [self determineWhenToIncrease];
    [self getBaseDriveTotal];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(refreshSellers) userInfo:Nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(refreshHomerooms) userInfo:Nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(determineWhenToIncrease) userInfo:nil repeats:YES]; // if app is running when time is correct, will start running
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(increaseTotal) userInfo:Nil repeats:YES];
   // [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(increaseTime) userInfo:Nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDriveTotal) name:kNotificationNameRefreshTotal object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAlertBOOLs) name:kNotificationNameResetAlerts object:Nil];
    
    self.error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    
    self.easterEggAlertShown = NO;
    self.tooEarlyAlertShown = NO;
}

-(void)resetAlertBOOLs {
    self.tooEarlyAlertShown = NO;
    self.easterEggAlertShown = NO;
}

-(void)refreshDriveTotal {
    self.driveTotalLabel.alpha = 0.0f;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSInteger second = [components second];
    NSInteger minute = [components minute];
    NSInteger hour = [components hour];
    
    [self getBaseDriveTotal];
    
    BOOL timeToIncrease = [self determineWhenToIncrease];
  //  timeToIncrease = YES; //testing ONLY
    
  //  dayIsFirstDay = YES; //testing ONLY
    
    float trueDriveTotal = 0.0;
    
    if (timeToIncrease == YES) {
        if (dayIsFirstDay == YES || dayIsWeekDay == YES) {
            hour -= 15; // gets true hour of drive
            NSLog(@"Hour:%i Minute:%i Second:%i",hour,minute,second);
            trueDriveTotal += (second * kAverageDriveSecondIncrease);
            trueDriveTotal += (minute * kAverageDriveMinuteIncrease);
            trueDriveTotal += (hour   * kAverageDriveHourIncrease);
            
        } else if (dayIsFirstWeekend == YES) {
            hour -= 8; // gets true hour of drive
            NSLog(@"Hour:%i Minute:%i Second:%i",hour,minute,second);
            trueDriveTotal += (second * kAverageDriveSecondIncrease);
            trueDriveTotal += (minute * kAverageDriveMinuteIncrease);
            trueDriveTotal += (hour   * kAverageDriveHourIncrease);
        }
        
        trueDriveTotal += baseDriveTotal;
        
        driveTotalInt = trueDriveTotal;
      //  NSLog(@"Drive Total Int: %f trueDriveTotal:%f",driveTotalInt,trueDriveTotal);
        [self fadeTotalIn];
        
        NSLog(@"trueTotal: %f",trueDriveTotal);
    //    NSLog(@"driveTotal: %f",driveTotalInt);
    }
}

-(void)increaseTime {
    timeSeconds++; // For testing purposes only
    NSLog(@"%i - $%0.02f",timeSeconds,driveTotalInt);
}

-(void)increaseTotal {
    driveTotalInt += driveTotalIncreaseBy; // should be used when released
  //  driveTotalInt += 0.102f;
    
    NSNumberFormatter *format = [NSNumberFormatter new];
    [format setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSString *numbers = [format stringFromNumber:[NSNumber numberWithFloat:driveTotalInt]];
    
    driveTotalString = [NSString stringWithFormat:@"%@",numbers];
    
    //  NSLog(driveTotalString);
    [UIView animateWithDuration:0.1f animations:^{ // Animates the update, kinda idk if it really works, but looks good anyways
        self.driveTotalLabel.text = driveTotalString;
    }];
    
}

-(void)getBaseDriveTotal {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://bob4appls.com/Drive.php?action=5"]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   NSLog(@"The connection error is: %@",[connectionError localizedDescription]);
                                   [self displayErrorMessage:[connectionError localizedDescription]];
                               } else {
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   baseDriveTotal = [responseString intValue];
                                   NSLog(@"Base:%i",baseDriveTotal);
                                   
                                   if (baseDriveTotal == oldBaseDriveTotal) {
                                       return;
                                   } else {
                                       oldBaseDriveTotal = baseDriveTotal;
                                       
                                     //  driveTotalInt -= oldBaseDriveTotal;
                                       
                                       driveTotalInt = baseDriveTotal;
                                       
                                       NSLog(@"Drive total:%f",driveTotalInt);
                                       [self refreshDriveTotal];
                                       
                                   }
                                  // NSLog(@"baseDriveTotal: %i",baseDriveTotal);
                                   
                                   
                               }
                           }];

}

-(void)fadeTotalIn {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger day = [components day];
    
    if (day == 21 || day == 22 || day == 23) {
        self.driveTotalLabel.alpha = 0.0f;
        [self displayErrorMessage:@"This is the last weekend of drive, and due to the point of drive, we cant show our estimated realtime total... Sorry!"];
        NSLog(@"Day is last weekend of drive");
        return;
    }
    if (self.driveTotalLabel.alpha == 1.0f) {
        // Drive Label has already faded in
        return;
    }
    [UIView animateWithDuration:0.5f animations:^{
        self.driveTotalLabel.alpha = 1.0f;
    }];
}

-(BOOL)determineWhenToIncrease {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger hour = [components hour];
    NSInteger day = [components day];
    NSInteger month = [components month];
   /*
     // Just testing the algorithm
    NSDateFormatter *minuteFormatter = [[NSDateFormatter alloc] init];// Not nessesary
    [minuteFormatter setDateFormat:@"mm"];// Not nessesary
    NSString *minuteOfHour = [minuteFormatter stringFromDate:today]; //todays day ex. 1, 5, 28// Not nessesary
    int minute = [minuteOfHour intValue];// Not nessesary
    
    NSDateFormatter *secondFormatter = [[NSDateFormatter alloc] init];
    [secondFormatter setDateFormat:@"ss"];
    NSString *secondOfMinute = [secondFormatter stringFromDate:today]; //todays day ex. 1, 5, 28
    int second = [secondOfMinute intValue];
    
    NSLog(@"minute: %i second: %i",minute,second);
    
    if (month == 1 && day == 29 && hour == 21 && minute == 05 && second == 00) {
        NSLog(@"test Complete1, first day increase by 0.10203333333f");
        driveTotalIncreaseBy = 0.10203333333f;
        dayIsFirstDay = YES;
        return YES;
    }
    
    if (month == 1 && day == 29 && hour == 21 && minute == 05 && second == 10) {
        NSLog(@"test Complete2, none day increase by 0");
        driveTotalIncreaseBy = 0;
        dayIsFirstDay = NO;
        return NO;
    }
    if (month == 1 && day == 29 && hour == 21 && minute == 05 && second == 20) {
        NSLog(@"test Complete3, first day increase by 0.10203333333f");
        driveTotalIncreaseBy = 0.10203333333f;
        dayIsFirstDay = YES;
        return YES;
    }
    
    if (month == 1 && day == 29 && hour == 21 && minute == 05 && second == 30) {
        NSLog(@"test Complete4, none day increase by 0");
        driveTotalIncreaseBy = 0;
        dayIsFirstDay = NO;
        return NO;
    }
    */
//    NSLog(@"Month:%i Day:%i",month,day);
    if (month < 2) {
        [self displayErrorMessage:@"You are a month early!"];
        [self fadeTotalIn];
        return NO;
    } else if (month > 2) {
        [self displayErrorMessage:@"Month late dude."];
        [self fadeTotalIn];
        return NO;
    }
    
    if (day < 14) {
        if (self.tooEarlyAlertShown == NO) {
            [self displayErrorMessage:@"Drive has not started yet. Comeback Friday, the 14th."];
            self.tooEarlyAlertShown = YES;
        }
        
        [self fadeTotalIn];
        return NO;
    }
    
    // Drive dates First-14, 17, 18, 19, 20, 21, Last-24
    // 14th - 16th = $0.102/0.1sec
    
    if(day == 14){ // First day of drive
        if (hour >= 15 && hour <= 22) { // Between 3PM and 10PM
            driveTotalIncreaseBy = 0.10203333333f;
            dayIsFirstDay = YES;
            return YES;
        } else {
            driveTotalIncreaseBy = 0;
            dayIsFirstDay = NO;
            return NO;
        }
    } else if (day == 15 || day == 16) { // Weekend of Start
        if (hour >= 8 && hour <= 22) { // Between 8AM and 10PM
            driveTotalIncreaseBy = 0.10203333333f;
            dayIsFirstWeekend = YES;
            return YES;
        } else {
            driveTotalIncreaseBy = 0;
            dayIsFirstWeekend = NO;
            return NO;
        }
    } else if (day == 17 || day == 18 || day == 19 || day == 20 || day == 21) { // Week Days of Drive
        if (hour >= 15 && hour <= 22) { // Between 3PM and 10PM
            driveTotalIncreaseBy = kAverageDriveTotalIncrease;
            dayIsWeekDay = YES;
            return YES;
        } else {
            driveTotalIncreaseBy = 0;
            dayIsWeekDay = NO;
            return NO;
        }
    } else if (day == 22 || day == 23) {
        self.driveTotalLabel.alpha = 0.0f;
        driveTotalIncreaseBy = 0;
        dayIsLastWeekend = YES;
        return NO;
    } else {
        driveTotalIncreaseBy = 0;
        return NO;
    }
    return NO;
}

-(void)displaySavedHomerooms {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *dictData = [defaults objectForKey:kKeyHomeroomDict];
    
    if (dictData != NULL) {
        
        NSMutableDictionary *dict = [[NSKeyedUnarchiver unarchiveObjectWithData:dictData] mutableCopy];
        
        [self updateHomeroomLabels:dict];
    }
}

-(void)refreshHomerooms {
    NSString *urlString;
    
    // NSLog(@"Request sent");
    
    urlString = [NSString stringWithFormat:@"http://bob4appls.com/Drive.php?action=4"]; // Gets all homeroom stuffs
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   NSLog(@"The connection error is: %@",[connectionError localizedDescription]);
                                   [self displayErrorMessage:[connectionError localizedDescription]];
                               } else {
                                   [self decodeHomeroomData:data];
                               }
                               
                           }];
}

-(void)decodeHomeroomData:(NSData*)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //  NSLog(@"Response = %@",responseString);
    
    NSString *allHomeroomsString = @"";
    NSString *allHomeroomQuotaString = @"";
    
    NSScanner *scanner = [NSScanner scannerWithString:responseString];
    [scanner scanUpToString:@"**" intoString:nil]; // Scan all characters before *
    while(![scanner isAtEnd]) {
        NSString *substring = nil;
        [scanner scanString:@"**" intoString:nil]; // Scan the # character
        if([scanner scanUpToString:@"**" intoString:&substring]) {
            // If the space immediately followed the #, this will be skipped
            if ([allHomeroomsString isEqualToString:@""]) {
                allHomeroomsString = substring;
            } else if ([allHomeroomQuotaString isEqualToString:@""]) {
                allHomeroomQuotaString = substring;
            }
        }
        [scanner scanUpToString:@"**" intoString:nil]; // Scan all characters before next *
    }
    
    //   NSLog(@"All Sellers: %@",allSellersString);
    //   NSLog(@"All Sold:    %@",allSellersSoldString);
    
    
    NSMutableDictionary *sellerInfo = [[NSMutableDictionary alloc] init];
    
    int index = 1;
    NSScanner *scanner2 = [NSScanner scannerWithString:allHomeroomsString];
    [scanner2 scanUpToString:@"*" intoString:nil]; // Scan all characters before *
    while(![scanner2 isAtEnd]) {
        NSString *substring = nil;
        [scanner2 scanString:@"*" intoString:nil]; // Scan the # character
        if([scanner2 scanUpToString:@"*" intoString:&substring]) {
            
            // If the space immediately followed the #, this will be skipped
            
            [sellerInfo setValue:substring forKey:[NSString stringWithFormat:@"Homeroom%iName",index]];
            
            index++;
        }
        [scanner2 scanUpToString:@"*" intoString:nil]; // Scan all characters before next *
    }
    
    index = 1;
    
    NSScanner *scanner3 = [NSScanner scannerWithString:allHomeroomQuotaString];
    [scanner3 scanUpToString:@"*" intoString:nil]; // Scan all characters before *
    while(![scanner3 isAtEnd]) {
        NSString *substring = nil;
        [scanner3 scanString:@"*" intoString:nil]; // Scan the # character
        if([scanner3 scanUpToString:@"*" intoString:&substring]) {
            
            // If the space immediately followed the #, this will be skipped
            
            [sellerInfo setValue:substring forKey:[NSString stringWithFormat:@"Homeroom%iQuota",index]];
            
            index++;
        }
        [scanner3 scanUpToString:@"*" intoString:nil]; // Scan all characters before next *
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:data];
    if (dictData != NULL) {
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:sellerInfo] forKey:kKeyHomeroomDict];
        [defaults synchronize];
    }
    
    [self updateHomeroomLabels:sellerInfo];
}

-(void)updateHomeroomLabels:(NSMutableDictionary *)sellerDict {
    self.TopHomeroom1.text = [NSString stringWithFormat:@"1. %@ - %@%%",[sellerDict valueForKey:@"Homeroom1Name"],[sellerDict valueForKey:@"Homeroom1Quota"]];
    self.TopHomeroom2.text = [NSString stringWithFormat:@"2. %@ - %@%%",[sellerDict valueForKey:@"Homeroom2Name"],[sellerDict valueForKey:@"Homeroom2Quota"]];
    self.TopHomeroom3.text = [NSString stringWithFormat:@"3. %@ - %@%%",[sellerDict valueForKey:@"Homeroom3Name"],[sellerDict valueForKey:@"Homeroom3Quota"]];
    self.TopHomeroom4.text = [NSString stringWithFormat:@"4. %@ - %@%%",[sellerDict valueForKey:@"Homeroom4Name"],[sellerDict valueForKey:@"Homeroom4Quota"]];
    self.TopHomeroom5.text = [NSString stringWithFormat:@"5. %@ - %@%%",[sellerDict valueForKey:@"Homeroom5Name"],[sellerDict valueForKey:@"Homeroom5Quota"]];
}

-(void)displaySavedSellers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *dictData = [defaults objectForKey:kKeySellerDict];
    
    if (dictData != NULL) {
        
        NSMutableDictionary *dict = [[NSKeyedUnarchiver unarchiveObjectWithData:dictData] mutableCopy];
        
        [self updateSellerLabels:dict];
    }
}

-(void)refreshSellers { // Just doing sellers for now
    NSString *urlString;
    
    // NSLog(@"Request sent");
    
    urlString = [NSString stringWithFormat:@"http://bob4appls.com/Drive.php?action=3"]; // Gets all sellers stuffs
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   NSLog(@"The connection error is: %@",[connectionError localizedDescription]);
                                   [self displayErrorMessage:[connectionError localizedDescription]];
                               } else {
                                   [self decodeSellersData:data];
                               }
                               
                           }];
    
}

-(void)decodeSellersData:(NSData*)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //  NSLog(@"Response = %@",responseString);
    if ([responseString isEqualToString:@"Message"]) { // EASTER EGG Message
        NSString *urlString;
        
        urlString = [NSString stringWithFormat:@"http://bob4appls.com/Drive.php?action=6"]; // Easter Egg
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               //    NSLog(@"%@",responseString);
                                   if (self.easterEggAlertShown == NO) {
                                  //     NSLog(@"111111");
                                       [self displayErrorMessage:responseString];
                                       
                                       self.easterEggAlertShown = YES;
                                   }
                               }];
    }
    
    NSString *allSellersString = @"";
    NSString *allSellersSoldString = @"";
    
    NSScanner *scanner = [NSScanner scannerWithString:responseString];
    [scanner scanUpToString:@"**" intoString:nil]; // Scan all characters before *
    while(![scanner isAtEnd]) {
        NSString *substring = nil;
        [scanner scanString:@"**" intoString:nil]; // Scan the # character
        if([scanner scanUpToString:@"**" intoString:&substring]) {
            // If the space immediately followed the #, this will be skipped
            if ([allSellersString isEqualToString:@""]) {
                allSellersString = substring;
            } else if ([allSellersSoldString isEqualToString:@""]) {
                allSellersSoldString = substring;
            }
        }
        [scanner scanUpToString:@"**" intoString:nil]; // Scan all characters before next *
    }
    
    //   NSLog(@"All Sellers: %@",allSellersString);
    //   NSLog(@"All Sold:    %@",allSellersSoldString);
    
    
    NSMutableDictionary *sellerInfo = [[NSMutableDictionary alloc] init];
    
    int index = 1;
    NSScanner *scanner2 = [NSScanner scannerWithString:allSellersString];
    [scanner2 scanUpToString:@"*" intoString:nil]; // Scan all characters before *
    while(![scanner2 isAtEnd]) {
        NSString *substring = nil;
        [scanner2 scanString:@"*" intoString:nil]; // Scan the # character
        if([scanner2 scanUpToString:@"*" intoString:&substring]) {
            
            // If the space immediately followed the #, this will be skipped
            
            [sellerInfo setValue:substring forKey:[NSString stringWithFormat:@"Seller%iName",index]];
            
            index++;
        }
        [scanner2 scanUpToString:@"*" intoString:nil]; // Scan all characters before next *
    }
    
    index = 1;
    
    NSScanner *scanner3 = [NSScanner scannerWithString:allSellersSoldString];
    [scanner3 scanUpToString:@"*" intoString:nil]; // Scan all characters before *
    while(![scanner3 isAtEnd]) {
        NSString *substring = nil;
        [scanner3 scanString:@"*" intoString:nil]; // Scan the # character
        if([scanner3 scanUpToString:@"*" intoString:&substring]) {
            
            // If the space immediately followed the #, this will be skipped
            
            [sellerInfo setValue:substring forKey:[NSString stringWithFormat:@"Seller%iSold",index]];
            
            index++;
        }
        [scanner3 scanUpToString:@"*" intoString:nil]; // Scan all characters before next *
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:data];
    if (dictData != NULL) {
        [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:sellerInfo] forKey:kKeySellerDict];
        [defaults synchronize];
    }
    
    [self updateSellerLabels:sellerInfo];
}

-(void)updateSellerLabels:(NSMutableDictionary *)sellerDict {
    self.TopSeller1.text = [NSString stringWithFormat:@"1. %@ - %@",[sellerDict valueForKey:@"Seller1Name"],[sellerDict valueForKey:@"Seller1Sold"]];
    self.TopSeller2.text = [NSString stringWithFormat:@"2. %@ - %@",[sellerDict valueForKey:@"Seller2Name"],[sellerDict valueForKey:@"Seller2Sold"]];
    self.TopSeller3.text = [NSString stringWithFormat:@"3. %@ - %@",[sellerDict valueForKey:@"Seller3Name"],[sellerDict valueForKey:@"Seller3Sold"]];
    self.TopSeller4.text = [NSString stringWithFormat:@"4. %@ - %@",[sellerDict valueForKey:@"Seller4Name"],[sellerDict valueForKey:@"Seller4Sold"]];
    self.TopSeller5.text = [NSString stringWithFormat:@"5. %@ - %@",[sellerDict valueForKey:@"Seller5Name"],[sellerDict valueForKey:@"Seller5Sold"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayErrorMessage:(NSString *)errorMessage {
    if (self.error.isVisible == YES) {
  //      NSLog(@"The Error message is already visible");
        return;
    }
    
    self.error.message = errorMessage;
    
    [self.error show];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


@end
