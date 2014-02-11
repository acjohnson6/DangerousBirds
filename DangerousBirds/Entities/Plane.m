//
//  Plane.m
//  DangerousBirds
//
//  Created by Adrian Johnson on 2/10/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "Plane.h"
#import "MyScene.h"
#import "SKEmitterNode+SKTExtras.h"
#import "SKTEffects.h"

@implementation Plane
{
    SKEmitterNode *_emitterSmoke;
    CGFloat _screenWidth;
}

- (instancetype)initWithScreenWidth:(CGFloat)screenWidth{
    SKTextureAtlas *atlas =
    [SKTextureAtlas atlasNamed: @"plane"];
    SKTexture *texture = [atlas textureNamed:@"PLANE 8 N"];
    texture.filteringMode = SKTextureFilteringNearest;
    if (self = [super initWithTexture:texture]) {
        //self.scale = 0.6;
        self.zPosition = 2;
        self.position = CGPointMake(screenWidth/2, 15+self.size.height/2);
        _screenWidth = screenWidth;
        CGFloat minDiam = MIN(self.size.width, self.size.height);
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:minDiam/2.0];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.restitution = 1;
        self.physicsBody.friction = 0;
        self.physicsBody.categoryBitMask = PCPlaneCategory;
        self.physicsBody.contactTestBitMask = 0xFFFFFFFF;
        self.physicsBody.collisionBitMask = PCBirdCategory;
    }
    return self;
}

- (void)crashPlane{
    CGPoint oldScale = CGPointMake(self.xScale,
                                   self.yScale);
    CGPoint newScale = CGPointMultiplyScalar(oldScale, 0.5f);
    
    SKTScaleEffect *scaleEffect =
    [SKTScaleEffect effectWithNode:self duration:2.0
                        startScale:newScale endScale:oldScale];
    
    scaleEffect.timingFunction = SKTTimingFunctionSmoothstep;
    
    [self runAction:[SKAction actionWithEffect:scaleEffect]];
    NSLog(@"PlaneNodes:\n %@",[self children]);
    [_emitterSmoke removeFromParent];
    [[self childNodeWithName:@"smoke"] removeFromParent];
    self.position = CGPointMake(_screenWidth/2, 15+self.size.height/2);
}

-(void)engineSmokeEngineNumber:(EngineNumber)engineNumber{
    if (_engine1Hit == 0 || _engine2Hit == 0) {
        _emitterSmoke = [SKEmitterNode skt_emitterNamed:@"smoke"];
        _emitterSmoke.name = @"smoke";
        _emitterSmoke.targetNode = self;
        _emitterSmoke.zPosition = 3;
    }
    
    switch (engineNumber) {
        case EngineNumber1:
            _engine1Hit++;
            if (_engine1Hit == 1) {
                [self addChild:_emitterSmoke];
                _emitterSmoke.position = CGPointMake(-30.0, 0);
            } else if(_engine1Hit == 2) {
                //Make fire on engine
            }
            break;
        case EngineNumber2:
            _engine2Hit++;
            if (_engine2Hit == 1) {
                [self addChild:_emitterSmoke];
                //_emitterSmoke.position = blah blah
            } else if(_engine2Hit == 2) {
                //Make fire on engine
            }
            break;
        case EngineNumber3:
            _engine3Hit++;
            if (_engine3Hit == 1) {
                [self addChild:_emitterSmoke];
                //_emitterSmoke.position = blah blah
            } else if(_engine3Hit == 2) {
                //Make fire on engine
            }
            break;
        case EngineNumber4:
            _engine4Hit++;
            if (_engine4Hit == 1) {
                [self addChild:_emitterSmoke];
                //_emitterSmoke.position = blah blah
            } else if(_engine4Hit == 2) {
                //Make fire on engine
            }
            break;
        default:
            break;
    }
    
    if (_engine1Hit >= 2 || _engine2Hit >=2) {
        [self crashPlane];
    } else if (_engine3Hit >= 2 || _engine4Hit >= 2) {
        //crashRight Method, or take parameter and direction
    }
}
@end
