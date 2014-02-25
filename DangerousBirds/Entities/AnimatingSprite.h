//
//  AnimatingSprite.h
//  DangerousBirds
//
//  Created by Adrage on 2/8/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

static inline CGFloat ScalarRandomRange(CGFloat min,
                                        CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) *
                  (max - min) + min);
}

@interface AnimatingSprite : SKSpriteNode
@property (strong,nonatomic) SKAction *moveDown;

+ (SKAction*)createAnimWithName:(NSString *)name;
@end
