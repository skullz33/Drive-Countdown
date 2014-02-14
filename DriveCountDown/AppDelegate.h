//
//  AppDelegate.h
//  DriveCountDown
//
//  Created by Matt B on 1/21/14.
//  Copyright (c) 2014 Matt Blessed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

#define kSavedToken @"TokenSaved"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic) ViewController *mainViewController;
@property (strong, nonatomic) UIWindow *window;

@end
