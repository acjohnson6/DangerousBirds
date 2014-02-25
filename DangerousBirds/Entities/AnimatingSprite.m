//
//  AnimatingSprite.m
//  DangerousBirds
//
//  Created by Adrage on 2/8/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "AnimatingSprite.h"

@implementation AnimatingSprite

+ (SKAction*)createAnimWithName:(NSString*)name{
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"birds"];
    
    NSArray *textures =
    @[[atlas textureNamed:[NSString stringWithFormat:@"%@01",
                           name]],
      [atlas textureNamed:[NSString stringWithFormat:@"%@02",
                           name]]];
    
    [textures[0] setFilteringMode:SKTextureFilteringNearest];
    [textures[1] setFilteringMode:SKTextureFilteringNearest];
    
    return [SKAction repeatActionForever:
            [SKAction animateWithTextures:textures
                             timePerFrame:0.1]];
}

-(void)moveTowards{
    [self runAction:self.moveDown];
}
@end
