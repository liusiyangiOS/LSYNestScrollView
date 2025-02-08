//
//  AppDelegate.m
//  LSYNestScrollViewDemo
//
//  Created by liusiyang on 2025/2/6.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UINavigationBar appearance] setTintColor:UIColor.blackColor];
//    [[UINavigationBar appearance] setBackgroundColor:UIColor.whiteColor];
    [UINavigationBar appearance].translucent = NO;
    
    ViewController *controller = [[ViewController alloc] init];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:controller];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        navC.navigationBar.scrollEdgeAppearance = appearance;
    }
    self.window.rootViewController = navC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
