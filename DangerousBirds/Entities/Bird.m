//
//  Bird.m
//  DangerousBirds
//
//  Created by Adrage on 2/8/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "Bird.h"
#import "MyScene.h"
#import "SKEmitterNode+SKTExtras.h"

@implementation Bird
{
    
}

#pragma mark Animating Sprite Creation
+ (void)initialize
{
    /*static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMoveDown =
        [Bird createAnimWithPrefix:@"bird" suffix:@"ft"];
    });*/
}

- (instancetype)init
{
    SKTextureAtlas *atlas =
    [SKTextureAtlas atlasNamed: @"birds"];
    SKTexture *texture = [atlas textureNamed:@"bird"];
    texture.filteringMode = SKTextureFilteringNearest;
    
    if (self = [super initWithTexture:texture]) {
        self.name = @"bird";
        [self setScale:.5];
        self.zPosition = 4.0f;
        CGFloat minDiam = MIN(self.size.width, self.size.height);
        minDiam = MAX(minDiam-8, 8);
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:minDiam/2.0];
        self.physicsBody.categoryBitMask = PCBirdCategory;
        self.physicsBody.collisionBitMask = 0;
    }
    return self;
}

- (void)fly
{
    MyScene *scene = [[MyScene alloc] init];
    CGPoint birdScenePos = CGPointMake(ScalarRandomRange(scene.size.height/2,
                                                         scene.size.height-self.size.height/2), scene.size.height + self.size.height/2);
    //Check ito adding this
    scene.position = [scene convertPoint:birdScenePos toNode:scene.bgLayer];
    
    SKAction *actionMove =
    [SKAction moveByX:0 y:-scene.size.height + self.size.height duration:2.0];
    SKAction *actionRemove = [SKAction removeFromParent];
    [self runAction:
     [SKAction sequence:@[actionMove, actionRemove]]];
}

- (void)start
{
    [self fly];
}

static SKAction *sharedMoveDown = nil;
- (SKAction*)moveDown {
    return sharedMoveDown;
}

-(void)feathersPuff{
    //[self removeAllActions];
    [self removeFromParent];
}


@end
