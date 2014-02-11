//
//  AnimatingSprite.m
//  DangerousBirds
//
//  Created by Adrage on 2/8/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "AnimatingSprite.h"

@implementation AnimatingSprite

+ (SKAction*)createAnimWithPrefix:(NSString *)prefix
                           suffix:(NSString *)suffix
{
    SKTextureAtlas *atlas =
    [SKTextureAtlas atlasNamed:@"characters"];
    
    NSArray *textures =
    @[[atlas textureNamed:[NSString stringWithFormat:@"%@_%@1",
                           prefix, suffix]],
      [atlas textureNamed:[NSString stringWithFormat:@"%@_%@2",
                           prefix, suffix]]];
    
    [textures[0] setFilteringMode:SKTextureFilteringNearest];
    [textures[1] setFilteringMode:SKTextureFilteringNearest];
    
    return [SKAction repeatActionForever:
            [SKAction animateWithTextures:textures
                             timePerFrame:0.20]];
}

-(void)moveTowards{
    [self runAction:self.moveDown];
}
@end
