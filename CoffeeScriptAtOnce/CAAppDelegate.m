//
//  CAAppDelegate.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CAAppDelegate.h"

#import "CAMasterViewController.h"

#import "CADetailViewController.h"

#import "CAProjectManager.h"
#import "CAUtil.h"

@implementation CAAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (void)dealloc
{
    [_window release];
    [_navigationController release];
    [_splitViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[CAProjectManager sharedManager] load];
    
    // Set default to user default
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defautValues = [NSMutableDictionary dictionary];
    
    [defautValues setObject:[NSNumber numberWithBool:YES] forKey:kCAKeyDefaultIsCoffeeScript];
    [defautValues setObject:[NSNumber numberWithBool:YES] forKey:kCAKeyDefaultIsJQuery];
    [defautValues setObject:[NSNumber numberWithBool:YES] forKey:kCAKeyDefaultIsConsoleLog];

    if ([CAUtil isIOS4]) {
        [defautValues setObject:[NSNumber numberWithBool:NO] forKey:kCAKeyDefaultIsOnError];
    } else {
        [defautValues setObject:[NSNumber numberWithBool:YES] forKey:kCAKeyDefaultIsOnError];
    }
        
    [defautValues setObject:[NSNumber numberWithBool:YES] forKey:kCAKeySettingIsBodyText];
    [defautValues setObject:[NSNumber numberWithBool:YES] forKey:kCAKeySettingIsAttachment];
    [defautValues setObject:[NSNumber numberWithBool:NO] forKey:kCAKeySettingIsZipball];

    [defautValues setObject:[NSNumber numberWithInt:0] forKey:kCAKeySettingTextColor];
    [defautValues setObject:[NSNumber numberWithInt:3] forKey:kCAKeySettingBgColor];
    [defautValues setObject:[NSNumber numberWithInt:[CAUtil fontIndex:@"Courier"]] forKey:kCAKeySettingFontName];
    [defautValues setObject:[NSNumber numberWithInt:5] forKey:kCAKeySettingFontSize];
    [defautValues setObject:[NSNumber numberWithBool:YES] forKey:kCAKeySettingIsCustomKeyboard];
    [defautValues setObject:@"{};:<>/*-+[]()'\"$_=!?.," forKey:kCAKeySettingCustomKeys];
    
    [defautValues setObject:[NSNumber numberWithBool:NO] forKey:kCAKeySettingIsLineNums];
    [defautValues setObject:[NSNumber numberWithBool:NO] forKey:kCAKeySettingIsLineInfo];
    
    [defautValues setObject:@"" forKey:kCAKeySettingUsername];
    [defautValues setObject:@"" forKey:kCAKeySettingPassword];
    
    [defautValues setObject:[NSNumber numberWithBool:YES] forKey:kCAKeyIsFirst];

    [userDefaults registerDefaults:defautValues];
    
    if ([userDefaults boolForKey:kCAKeyIsFirst]) {
        [[CAProjectManager sharedManager] makeSamples];
        [userDefaults setBool:NO forKey:kCAKeyIsFirst];
    }
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //CAMasterViewController *masterViewController = [[[CAMasterViewController alloc] initWithNibName:@"CAMasterViewController_iPhone" bundle:nil] autorelease];
        CAMasterViewController *masterViewController = [[[CAMasterViewController alloc] init] autorelease];
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        self.window.rootViewController = self.navigationController;
        
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.navigationController.toolbar.barStyle = UIBarStyleBlackOpaque;

    } else {
        //CAMasterViewController *masterViewController = [[[CAMasterViewController alloc] initWithNibName:@"CAMasterViewController_iPad" bundle:nil] autorelease];
        CAMasterViewController *masterViewController = [[[CAMasterViewController alloc] init] autorelease];
        UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        
        //CADetailViewController *detailViewController = [[[CADetailViewController alloc] initWithNibName:@"CADetailViewController_iPad" bundle:nil] autorelease];
        CADetailViewController *detailViewController = [[[CADetailViewController alloc] init] autorelease];                                                
        UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailViewController] autorelease];
    	
    	masterViewController.detailViewController = detailViewController;
    	
        self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
        
        self.window.rootViewController = self.splitViewController;        
    }
    [self.window makeKeyAndVisible];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
