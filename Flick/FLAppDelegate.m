//
//  FLAppDelegate.m
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

// todo:
//  use NSCache for entities so they're not refectched on reloadData - does DB do this for us?
//  update list upon filesystem change?
//  double tap for cell action -> visit URL, view image in fullscreen
//  display:
//      pasteview images are scaled to the space, cellview images are always cropped
//      make it not look dumb for fast actions (maybe just a delay for guide?)
//      message for upload success - what happens if you copy during? need a message queue?
//      make text trimming in cells look better (truncate by words?)
//      tilt on swipe to dismiss (a la jelly)
//  settings:
//      copy link on upload (only for photos?)
//      connect dropbox if unconnected
//      use last photo in camera roll if (what?)
//      report a bug
//  cleanup:
//      order defines
//      double check imports
//      remove unnecessary default declarations
//  app icon
//  address all other todos in code
//  handle all error cases... network, dropbox, unrecognized type
//  make sure dropbox is connected on launch

#import "FLAppDelegate.h"
#import "FLMainViewController.h"
#import "FLDropboxHelper.h"
#import "FLEntity.h"

@implementation FLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    FLMainViewController *main = [[FLMainViewController alloc] init];
    self.window.rootViewController = main;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FLDropboxHelper sharedHelper] finishLinking:url];
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
