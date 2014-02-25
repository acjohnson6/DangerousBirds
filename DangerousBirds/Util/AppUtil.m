//
//  AppUtil.m
//  DangerousBirds
//
//  Created by Adrian Johnson on 2/25/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "AppUtil.h"
#import "Constants.h"

@implementation AppUtil

+ (void)setDefaultHighScore:(NSNumber *)highScore {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:highScore forKey:kHighScoreKey];
    [defaults synchronize];
}

+ (NSNumber *)defaultHighScore {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (NSNumber *) [defaults valueForKey:kHighScoreKey];
}

@end
