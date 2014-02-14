//
//  AppDelegate.m
//  DriveCountDown
//
//  Created by Matt B on 1/21/14.
//  Copyright (c) 2014 Matt Blessed. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.mainViewController = [[ViewController alloc] init];
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"Application Entered Background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"Application Entered Forground");
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"Application Became Active");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameRefreshTotal object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameResetAlerts object:nil];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error registering for remote notifications: %@",[error localizedDescription]);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //	NSLog(@"My token is: %@", deviceToken);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:kSavedToken] isEqualToString:@"YES"]) {
        NSLog(@"Already Saved this token");
        return;
    }
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *name;
    name = [[UIDevice currentDevice] name];
    
    name = [name stringByReplacingOccurrencesOfString:@"'" withString:@""];
    
    
    
    NSString* onlyName = [[name componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    NSLog(@"token = %@ name = %@",token,onlyName);
    name = @"name";
    NSString *urlString;
    
    
    urlString = [NSString stringWithFormat:@"http://bob4appls.com/savetoken.php?name=%@&token=%@",onlyName,token]; // If not local
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog(@"%@",responseString);
                               
                               if ([responseString isEqualToString:@"Success"]) {
                                   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                   [defaults setObject:@"YES" forKey:kSavedToken];
                                   [defaults synchronize];
                               }
                           }];
    
}


@end
