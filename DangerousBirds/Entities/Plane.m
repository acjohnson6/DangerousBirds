//
//  Plane.m
//  DangerousBirds
//
//  Created by Adrian Johnson on 2/10/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "Plane.h"
#import "MyScene.h"
#import "SKAction+SKTExtras.h"
#import "SKEmitterNode+SKTExtras.h"
#import "SKTEffects.h"
#import "SKSpriteNode+DebugDraw.h"

static SKAction *flyPlaneSound;

@implementation Plane
{
    SKEmitterNode *_emitterSmoke1;
    SKEmitterNode *_emitterSmoke2;
    SKEmitterNode *_emitterFire1;
    SKEmitterNode *_emitterFire2;
    CGFloat _screenWidth;
    SKSpriteNode *engine1;
    SKSpriteNode *engine2;
    SKSpriteNode *cockPit;
}

+ (void)initialize
{
    flyPlaneSound = [SKAction playSoundFileNamed:@"biplane-flying.mp3" waitForCompletion:NO];
}
- (instancetype)initWithScreenWidth:(CGFloat)screenWidth{
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed: @"plane"];
    SKTexture *texture = [atlas textureNamed:@"planeBase"];
    texture.filteringMode = SKTextureFilteringNearest;
    if (self = [super initWithTexture:texture]) {
        self.scale = 0.5;
        self.name = @"plane";
        //self.zPosition = 2; - now emitter is above the plane
        self.position = CGPointMake(screenWidth/2, 15+self.size.height/2);
        _screenWidth = screenWidth;
        
        engine1 = [SKSpriteNode new];
        CGSize contactSize = CGSizeMake(30, 5);
        engine1.name = @"engine1";
        engine1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
        [engine1 attachDebugRectWithSize:contactSize];
        engine1.physicsBody.usesPreciseCollisionDetection = YES;
        engine1.physicsBody.allowsRotation = NO;
        engine1.physicsBody.restitution = 1;
        engine1.physicsBody.friction = 0;
        engine1.physicsBody.categoryBitMask = PCEngine1Category;
        engine1.physicsBody.contactTestBitMask = 0xFFFFFFFF;
        engine1.physicsBody.collisionBitMask = 0;
        engine1.position = CGPointMake(-70, 40);
        [self addChild:engine1];
        
        engine2 = [SKSpriteNode new];
        engine2.name = @"engine2";
        engine2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
        [engine2 attachDebugRectWithSize:contactSize];
        engine2.physicsBody.usesPreciseCollisionDetection = YES;
        engine2.physicsBody.allowsRotation = NO;
        engine2.physicsBody.restitution = 1;
        engine2.physicsBody.friction = 0;
        engine2.physicsBody.categoryBitMask = PCEngine2Category;
        engine2.physicsBody.contactTestBitMask = 0xFFFFFFFF;
        engine2.physicsBody.collisionBitMask = 0;
        engine2.position = CGPointMake(70, 40);
        [self addChild:engine2];
        
        contactSize = CGSizeMake(30, 40);
        
        cockPit = [SKSpriteNode new];
        cockPit.name = @"cockPit";
        cockPit.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
        [cockPit attachDebugRectWithSize:contactSize];
        cockPit.physicsBody.usesPreciseCollisionDetection = YES;
        cockPit.physicsBody.allowsRotation = NO;
        cockPit.physicsBody.restitution = 1;
        cockPit.physicsBody.friction = 0;
        cockPit.physicsBody.categoryBitMask = PCCockPitCategory;
        cockPit.physicsBody.contactTestBitMask = 0xFFFFFFFF;
        cockPit.physicsBody.collisionBitMask = 0;
        cockPit.position = CGPointMake(0, 60);
        [self addChild:cockPit];
        
        _emitterSmoke1 = [SKEmitterNode skt_emitterNamed:@"smoke"];
        _emitterSmoke1.name = @"smoke1";
        _emitterSmoke1.targetNode = self;
        _emitterSmoke1.zPosition = 3;
        _emitterSmoke1.position = CGPointMake(-70.0, 30);
        
        _emitterSmoke2 = [SKEmitterNode skt_emitterNamed:@"smoke"];
        _emitterSmoke2.name = @"smoke2";
        _emitterSmoke2.targetNode = self;
        _emitterSmoke2.zPosition = 3;
        _emitterSmoke2.position = CGPointMake(70.0, 30);
        
        _emitterFire1 = [SKEmitterNode skt_emitterNamed:@"fire"];
        _emitterFire1.name = @"fire1";
        _emitterFire1.targetNode = self;
        _emitterFire1.zPosition = 3;
         _emitterFire1.position = CGPointMake(-70.0, 30);
        _emitterFire1.hidden = YES;
        
        _emitterFire2 = [SKEmitterNode skt_emitterNamed:@"fire"];
        _emitterFire2.name = @"fire2";
        _emitterFire2.targetNode = self;
        _emitterFire2.zPosition = 3;
        _emitterFire2.position = CGPointMake(70.0, 30);
        _emitterFire2.hidden = YES;
        
        /*_emitterFire1.hidden = YES;
        _emitterFire2.hidden = YES;
        [self addChild:_emitterFire1];
        [self addChild:_emitterFire2];*/
        
        /*CGFloat minDiam = MIN(self.size.width, self.size.height);
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:minDiam/2.0];*/
        
        //CGMutablePathRef engine1Path = CGPathCreateMutable();
        
        /*CGPathMoveToPoint(trianglePath, nil, -_triangle.size.width/2, -
                          _triangle.size.height/2);
        //3
        CGPathAddLineToPoint(trianglePath, nil, _triangle.size.width/2, -_triangle.size.height/2); CGPathAddLineToPoint(trianglePath, nil, 0, _triangle.size.height/2);
        
        CGPathAddLineToPoint(trianglePath, nil, -_triangle.size.width/2, - _triangle.size.height/2);*/
        
        
        /*self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
        [self attachDebugRectWithSize:contactSize];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.restitution = 1;
        self.physicsBody.friction = 0;
        self.physicsBody.categoryBitMask = PCPlaneCategory;
        self.physicsBody.contactTestBitMask = 0xFFFFFFFF;
        self.physicsBody.collisionBitMask = PCBirdCategory;*/
    }
    return self;
}

- (void)crashPlane{
    [self removeAllActions];

    CGPoint oldScale = CGPointMake(self.xScale,self.yScale);
    CGPoint newScale = CGPointMultiplyScalar(oldScale, 0.0f);
    engine1.physicsBody.categoryBitMask = 0;
    engine2.physicsBody.categoryBitMask = 0;
    
    SKTScaleEffect *scaleEffect =
    [SKTScaleEffect effectWithNode:self duration:.75
                        startScale:oldScale endScale:newScale];
    
    scaleEffect.timingFunction = SKTTimingFunctionSmoothstep;
    
    SKAction *scaleDown = [SKAction actionWithEffect:scaleEffect];
    
    SKAction *removePlane = [SKAction performSelector:@selector(removeFromParent)
                     onTarget:self];
    
    [self runAction:[SKAction sequence:@[scaleDown, removePlane]]];
}

-(void)engineSmokeEngineNumber:(EngineNumber)engineNumber{
    switch (engineNumber) {
        case EngineNumber1:
            _engine1Hit++;
            if (_engine1Hit == 1) {
                if (![[self children]containsObject:_emitterSmoke1]) {
                    [self addChild:_emitterSmoke1];
                }
            } else if(_engine1Hit == 2) {
                if (![[self children]containsObject:_emitterFire1]) {
                    [self addChild:_emitterFire1];
                }
            }
            break;
        case EngineNumber2:
            _engine2Hit++;
            if (_engine2Hit == 1) {
                _emitterSmoke2.hidden = NO;
                if (![[self children]containsObject:_emitterSmoke2]) {
                    [self addChild:_emitterSmoke2];
                }
            } else if(_engine2Hit == 2) {
                if (![[self children]containsObject:_emitterFire2]) {
                    [self addChild:_emitterFire2];
                }
            }
            break;
        /*case EngineNumber3:
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
            break;*/
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
