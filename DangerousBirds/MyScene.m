//
//  MyScene.m
//  DangerousBirds
//
//  Created by Adrian Johnson on 2/7/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "MyScene.h"
#import "SKEmitterNode+SKTExtras.h"
#import "Bird.h"

static const float BG_POINTS_PER_SEC = 50;

@interface MyScene () <SKPhysicsContactDelegate>
@end

@implementation MyScene{
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    SKLabelNode* _distanceLabel;
    SKLabelNode* _titleLabel;
    SKLabelNode* startMsg;
    NSInteger distance;
    SKEmitterNode *_emitterRain;
    PCGameState _gameState;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        _gameState = PCGameStateStartingLevel;
        
        //adding the background
        _bgLayer = [SKNode node];
        [self addChild:_bgLayer];
        
        for (int i = 0; i < 2; i++) {
            SKSpriteNode * bg =
            [SKSpriteNode spriteNodeWithImageNamed:@"background"];
            bg.anchorPoint = CGPointZero;
            bg.position = CGPointMake(0, i * bg.size.height);
            bg.name = @"bg";
            [_bgLayer addChild:bg];
        }
        
        //init several sizes used in all scene
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;
        
        [self createUserInterface];
        _gameState = PCGameStateStartingLevel;
        
        
        //CoreMotion
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = .2;
        //self.motionManager.gyroUpdateInterval = .2;
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                     [self outputAccelertionData:accelerometerData.acceleration];
                                                     if(error){
                                                         
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
        
        [self runAction:[SKAction repeatActionForever:
                         [SKAction sequence:@[
                                              [SKAction performSelector:@selector(spawnBird)
                                                               onTarget:self],
                                              [SKAction waitForDuration:0.75]]]]];
        
    }
    return self;
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = 0;
    
    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = acceleration.x;
    }
}

- (void)spawnBird
{
    if (_gameState == PCGameStatePlaying) {
        Bird *bird = [[Bird alloc]init];
        CGPoint birdScenePos = CGPointMake(ScalarRandomRange(bird.size.height/2,
                                                          self.size.height-bird.size.height/2), self.size.height + bird.size.height/2);
        bird.position = [self convertPoint:birdScenePos toNode:_bgLayer];
        [_bgLayer addChild:bird];
    
        SKAction *actionMove =
        [SKAction moveByX:0 y:-self.size.height + bird.size.height duration:2.0];
        SKAction *actionRemove = [SKAction removeFromParent];
        [bird runAction:
         [SKAction sequence:@[actionMove, actionRemove]]];
    }
}

-(void)update:(NSTimeInterval)currentTime{
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    if (_plane.engine1Hit == 2 || _plane.engine2Hit == 2 || _plane.engine3Hit == 2 || _plane.engine4Hit == 2) {
        _gameState = PCGameStateInReloadMenu;
        [self EndLevel];
        //[_plane crashPlane];
    }
    
    switch (_gameState) {
        case PCGameStateStartingLevel:
        {
            
            //@"Tap the Screen to Start";
            break;
        }
        case PCGameStatePlaying:
        {
            distance++;
            _distanceLabel.text = [NSString stringWithFormat:@"Distance: %li",(long)distance];
            break;
        }
        case PCGameStateInReloadMenu:
        {
            //[self EndLevel];
            break;
        }
    }
    
    float maxY = screenRect.size.width - _plane.size.width/2;
    float minY = _plane.size.width/2;
    
    float newY = 90.0;
    float newX = 0;
    
    if(currentMaxAccelX > 0.05){
        newX = currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 R.png"];
    }
    else if(currentMaxAccelX < -0.05){
        newX = currentMaxAccelX*10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 L.png"];
    }
    else{
        newX = currentMaxAccelX*10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N.png"];
    }
    
    float newXshadow = newX+_planeShadow.position.x;
    float newYshadow = 73.5;
    
    newXshadow = MIN(MAX(newXshadow,minY+15),maxY+15);
    
    newX = MIN(MAX(newX+_plane.position.x,minY),maxY);
    
    _plane.position = CGPointMake(newX, newY);
    _planeShadow.position = CGPointMake(newXshadow, newYshadow);
    //_smokeTrail.position = CGPointMake(newX,newY-(_plane.size.height/2));
    
    [self moveBg];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        if (_gameState == PCGameStateStartingLevel) {
            _gameState = PCGameStatePlaying;
            [self childNodeWithName:@"titleLabel"].hidden = YES;
            [self childNodeWithName:@"msgLabel"].hidden = YES;
        } else if (_gameState == PCGameStateInReloadMenu) {
            _gameState = PCGameStateStartingLevel;
            [self childNodeWithName:@"msgLabel"].hidden = YES;
            [self StartLevel];
        }
    }
}

- (void)moveBg
{
    CGPoint bgVelocity = CGPointMake(0, -BG_POINTS_PER_SEC);
    CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
    _bgLayer.position = CGPointAdd(_bgLayer.position, amtToMove);
    
    [_bgLayer enumerateChildNodesWithName:@"bg"
                               usingBlock:^(SKNode *node, BOOL *stop){
                                   SKSpriteNode * bg = (SKSpriteNode *) node;
                                   CGPoint bgScreenPos = [_bgLayer convertPoint:bg.position
                                                                         toNode:self];
                                   if (bgScreenPos.y <= -bg.size.height) {
                                       bg.position = CGPointMake(bg.position.x,
                                                                 bg.position.y+bg.size.height*2);
                                       //if (distance = X amount mod = 0 then choose a new random background)
                                       //case 1,2,3 = new traine
                                   }
                               }];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *other =
    (contact.bodyA.categoryBitMask == PCPlaneCategory ?
     contact.bodyB : contact.bodyA); //Will need to make a PCEngine1Category & PCEngine2Category, and then pass to the EngineSmoke Method a 1 or 2, make a enum for each
    
    if (other.categoryBitMask == PCBirdCategory) {
        [_plane engineSmokeEngineNumber:EngineNumber1];
        //[self bugHitEffects:(SKSpriteNode *)other.node]; //make that engine smoke, and span down towards engined that was hit
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *other =
    (contact.bodyA.categoryBitMask == PCPlaneCategory ?
     contact.bodyB : contact.bodyA);
    
    // 2
    if (other.categoryBitMask &
        _plane.physicsBody.collisionBitMask) {
        // 3
        //Make plane span down towards engine hit
    }
}

- (void)createUserInterface
{
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    [self StartLevel];
    
    _emitterRain = [SKEmitterNode skt_emitterNamed:@"rain"];
    _emitterRain.targetNode = self;
    [self addChild:_emitterRain];
    _emitterRain.position = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) + 10);
    _emitterRain.zPosition = 10;
    
    _distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance: %li",(long)distance];
    _distanceLabel.fontSize = 18;
    _distanceLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _distanceLabel.position = CGPointMake(0, screenHeight-20);
    [self addChild:_distanceLabel];
    
    //adding the airplane
    _plane = [[Plane alloc]initWithScreenWidth:screenWidth];
    [self addChild:_plane];
    
    //adding airplane shadow
    _planeShadow = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 SHADOW.png"];
    _planeShadow.scale = 0.6;
    _planeShadow.zPosition = 1;
    _planeShadow.position = CGPointMake(screenWidth/2+15, 0+_planeShadow.size.height/2);
    [self addChild:_planeShadow];
}

-(void)StartLevel{
    distance = 0;
    _distanceLabel.text = [NSString stringWithFormat:@"Distance: %li",(long)distance];
    
    if (!_titleLabel) {
        _titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        _titleLabel.text = [NSString stringWithFormat:@"Dangerous Birds"];
        _titleLabel.name = @"titleLabel";
        _titleLabel.fontSize = 30;
        _titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _titleLabel.position = CGPointMake(screenWidth/2, screenHeight-120);
        [self addChild:_titleLabel];
    } else {
        _titleLabel.hidden = NO;
    }
    
    if (!startMsg) {
        startMsg = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        startMsg.name = @"msgLabel";
        startMsg.text = @"Tap Screen to Start!";
        startMsg.fontSize = 28;
        startMsg.position = CGPointMake(screenWidth/2, screenHeight/2);
        [self addChild: startMsg];
    } else {
        startMsg.text = @"Tap Screen to Start!";
        startMsg.hidden = NO;
    }
}

-(void)EndLevel{
    _gameState = PCGameStateInReloadMenu;
    SKLabelNode* label = (SKLabelNode*)[self childNodeWithName:@"msgLabel"];
    label.text = @"Try Again?";
    label.hidden = NO;
    _plane.engine1Hit = _plane.engine2Hit = _plane.engine3Hit = _plane.engine4Hit = 0;
}

@end
