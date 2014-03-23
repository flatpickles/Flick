//
//  FLAppDelegate.m
//  Flick
//
//  Created by Matt Nichols on 11/18/13.
//  Copyright (c) 2013 Matt Nichols. All rights reserved.
//

// todo:
//  bugs:
//      unexpected flentity type
//      delete disappearance weirdness
//  cleanup:
//      remove unnecessary defines and imports
//      read over stuff for stupidity, maybe
//  app icon
//  address all other todos in code

// someday:
//  animate gifs
//  update list upon filesystem change?
//  tilt on swipe to dismiss (a la jelly)
//  max image size: fullscreen?
//  make text trimming in cells look better (truncate by words?)
//  paste URLs, tappable in detail view to open a browser
//  plus button - reappear when you delete whatever is in your clipboard
//  iPad
//  performance:
//      when downloading a bunch of things, want to prioritize
//      displaying already downloaded things (bug: scroll a lot
//      while downloading, some cells are temporarily hidden)

// unreproducible:
//  shadow flash after resize

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

@end
