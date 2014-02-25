//
//  AppUtil.h
//  DangerousBirds
//
//  Created by Adrian Johnson on 2/25/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtil : NSObject
+ (void)setDefaultHighScore:(NSNumber *)highScore;
+ (NSNumber *)defaultHighScore;
@end
