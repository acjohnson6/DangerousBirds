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
#import "SKSpriteNode+DebugDraw.h"

@implementation Bird{
    SKAction *_birdAnimation;
    int randomBird;
}

#pragma mark Animating Sprite Creation
+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBlueBirdAnim = [Bird createAnimWithName:@"bluebird"];
        sharedCardinalAnim = [Bird createAnimWithName:@"cardinal"];
        sharedGreenBirdAnim = [Bird createAnimWithName:@"greenbird"];
        sharedIcterusGalbulaAnim = [Bird createAnimWithName:@"icterusGalbula"];
    });
}

- (instancetype)init
{
    SKTextureAtlas *atlas =
    [SKTextureAtlas atlasNamed: @"birds"];
    
    NSArray *arrayBirds = [NSArray arrayWithObjects:@"bluebird",@"cardinal",@"greenbird",@"icterusGalbula", nil];
    NSArray *arrayBirdColors = [NSArray arrayWithObjects:@"Blue",@"Red",@"Green",@"Brown",nil];
    
    int lowerBound = 0;
    int upperBound = (int)[arrayBirds count];
    randomBird = lowerBound + arc4random() % (upperBound - lowerBound);
    
    SKTexture *texture = [atlas textureNamed:[NSString stringWithFormat:@"%@01", arrayBirds[randomBird]]];
    
    texture.filteringMode = SKTextureFilteringNearest;
    
    if (self = [super initWithTexture:texture]) {
        self.name = @"bird";
        [self setScale:.6];
        self.zPosition = 4.0f;
        //self.zRotation = M_PI_4 * 6;
        /*CGFloat minDiam = MIN(self.size.width, self.size.height);
        minDiam = MAX(minDiam-8, 8);
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:minDiam/2.0];*/
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:arrayBirdColors[randomBird] forKey:@"birdColor"];
        self.userData = dictionary;
        
        CGSize contactSize = CGSizeMake(self.size.width *.5, self.size.height * .5);
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
        [self attachDebugRectWithSize:contactSize];
        self.physicsBody.categoryBitMask = PCBirdCategory;
        self.physicsBody.collisionBitMask = 0;
    }
    return self;
}

- (void)flyWithScene:(SKScene*)scene bgLayer:(SKNode*)bgLayer
{
    [self startBirdAnimation];
    
    CGPoint birdScenePos = CGPointMake(ScalarRandomRange(self.size.height/2,
                                                         scene.size.height-self.size.height/2),
                                       scene.size.height + self.size.height/2);
    
    self.position = [scene convertPoint:birdScenePos toNode:bgLayer];
    [bgLayer addChild:self];
    
    SKAction *actionMove =
    [SKAction moveByX:0 y:-scene.size.height + self.size.height duration:2.0];
    SKAction *actionRemove = [SKAction removeFromParent];
    [self runAction:[SKAction sequence:@[actionMove, actionRemove]]];
}

static SKAction *sharedBlueBirdAnim = nil;
static SKAction *sharedCardinalAnim = nil;
static SKAction *sharedGreenBirdAnim = nil;
static SKAction *sharedIcterusGalbulaAnim = nil;

- (SKAction*)blueBirdAnim {
    return sharedBlueBirdAnim;
}

- (SKAction*)cardinalAnim {
    return sharedCardinalAnim;
}

- (SKAction*)greenBirdAnim {
    return sharedGreenBirdAnim;
}

- (SKAction*)icterusGalbulaAnim {
    return sharedIcterusGalbulaAnim;
}

-(void)startBirdAnimation{
    switch (randomBird) {
        case 0:
            _birdAnimation = [self blueBirdAnim];
            break;
        case 1:
            _birdAnimation = [self cardinalAnim];
            break;
        case 2:
            _birdAnimation = [self greenBirdAnim];
            break;
        case 3:
            _birdAnimation = [self icterusGalbulaAnim];
            break;
        default:
            break;
    }
    
    [self runAction:
         [SKAction repeatActionForever:_birdAnimation]];
}


-(void)feathersPuff{
    //[self removeAllActions];
    [self removeFromParent];
}

@end
