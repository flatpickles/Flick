//
//  FLAppDelegate.m
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

// todo:
//  bugs:
//      shake doesn't dismiss current pasteview
//      pasteview over settings
//      pasteview should display doesn't wait for dropbox sync (should it?)
//      weird bounce lag when pulling up from bottom of list
//      speed up startup after install / start up after kill
//      shadow flash after resize
//      unexpected flentity type
//      delete disappearance weirdness
//  cleanup:
//      remove unnecessary defines and imports
//      rewrite tips & tricks in settings?
//      read over stuff for stupidity, maybe
//  app icon
//  address all other todos in code

// someday:
//  update list upon filesystem change?
//  tilt on swipe to dismiss (a la jelly)
//  max image size: fullscreen?
//  make text trimming in cells look better (truncate by words?)
//  paste URLs, tappable in detail view to open a browser

#import <Crashlytics/Crashlytics.h>

#import "FLAppDelegate.h"
#import "FLDropboxHelper.h"
#import "FLEntity.h"
#import "FLMainViewController.h"

@implementation FLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.applicationSupportsShakeToEdit = YES;
    [Crashlytics startWithAPIKey:@"a8db15f1dabcebca77d2386285856a4a0c5c482b"];

    FLMainViewController *main = [[FLMainViewController alloc] init];
    self.window.rootViewController = main;

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
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
