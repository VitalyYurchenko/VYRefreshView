//
//  VYAppDelegate.m
//  Refresh
//
//  Created by Vitaly Yurchenko on 20.02.12.
//  Copyright (c) 2012 Vitaly Yurchenko. All rights reserved.
//
// ********************************************************************************************************************************************************** //

#import "VYAppDelegate.h"

#import "VYRefreshTableViewController.h"

// ********************************************************************************************************************************************************** //

@implementation VYAppDelegate

@synthesize window = _window;

#pragma mark -
#pragma mark <UIApplicationDelegate>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    VYRefreshTableViewController *rootViewController = [[VYRefreshTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootViewController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
