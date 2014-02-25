//
//  MyScene.m
//  DangerousBirds
//
//  Created by Adrian Johnson on 2/7/14.
//  Copyright (c) 2014 Adrian Johnson. All rights reserved.
//

#import "MyScene.h"
#import "SKTEffects.h"
#import "SKEmitterNode+SKTExtras.h"
#import "SKAction+SKTExtras.h"
#import "Bird.h"
#import "AppUtil.h"
//#import <AudioToolbox/AudioToolbox.h>

static const float BG_POINTS_PER_SEC = 50;

@interface MyScene () <SKPhysicsContactDelegate>
@end

@implementation MyScene{
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    SKLabelNode* _distanceLabel;
    SKLabelNode* _titleLabel;
    SKLabelNode* _companyLabel;
    SKLabelNode* _scoreLabel;
    SKLabelNode* startMsg;
    NSInteger distance;
    SKEmitterNode *_emitterPuff;
    SKEmitterNode *_emitterRain;
    SKEmitterNode *_emitterSnow;
    SKEmitterNode *_emitterFeathers;
    PCGameState _gameState;
    Bird *bird;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        _gameState = PCGameStateStartingLevel;
        
        //adding the background
        _bgLayer = [SKNode node];
        _bgLayer.name = @"background";
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
    }
    return self;
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = 0;
    //NEW* moving Y
    currentMaxAccelY = 0;
    
    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = acceleration.x;
    }
    //NEW* moving Y
    if(fabs(acceleration.y) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = acceleration.y;
    }
}

- (void)spawnBird
{
    if (_gameState == PCGameStatePlaying) {
        bird = [[Bird alloc]init];
        [bird flyWithScene:self bgLayer:_bgLayer];
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
            
            if (distance % 1500 == 0) {
                if (![[self children] containsObject:_emitterRain] && ![[self children] containsObject:_emitterSnow]) {
                
                    int lowerBound = 1;
                    int upperBound = 11;
                    int randomWeather = lowerBound + arc4random() % (upperBound - lowerBound);
                    
                    switch (randomWeather) {
                        case 1: case 6: case 8: {
                            SKAction *lightening =
                            [SKAction sequence:@[[SKAction waitForDuration:2],
                                                 [SKAction performSelector:@selector(colorGlitch) onTarget:self],
                                                 [SKAction waitForDuration:2],
                                                 [SKAction performSelector:@selector(colorGlitch) onTarget:self],
                                                 [SKAction waitForDuration:2],
                                                 [SKAction performSelector:@selector(colorGlitch) onTarget:self]]];
                            [self runAction:lightening];
                        }
                        case 3: case 4:  case 9: case 10: {
                            if (![[self children] containsObject:_emitterRain]) {
                                [self addChild:_emitterRain];
                                [_emitterRain runAction:[SKAction skt_removeFromParentAfterDelay:10]];
                                
                            }
                        }
                            break;
                        case 2: case 5: case 7: {
                            if (![[self children] containsObject:_emitterSnow]) {
                                [self addChild:_emitterSnow];
                                [_emitterSnow runAction:[SKAction skt_removeFromParentAfterDelay:10]];
                                
                            }
                        }
                        default:
                            break;
                    }
                }
            }
            break;
        }
        case PCGameStateInReloadMenu:
        {
            break;
        }
    }
    
    //Previous static Y
    /*float maxY = screenRect.size.width - _plane.size.width/2;
    float minY = _plane.size.width/2;
    
    float newY = 90.0;
    float newX = 0;*/
    
    float maxY = screenRect.size.width - _plane.size.width/2;
    float minY = _plane.size.width/2;
    
    
    float maxX = screenRect.size.height - _plane.size.height/2;
    float minX = _plane.size.height/2;
    
    float newY = 0;
    float newX = 0;
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed: @"plane"];
    
    SKTexture *textureBase = [atlas textureNamed:@"planeBase"];
    SKTexture *textureLeft = [atlas textureNamed:@"planeLeft"];
    SKTexture *textureRight = [atlas textureNamed:@"planeRight"];
    
    textureBase.filteringMode = SKTextureFilteringNearest;
    textureLeft.filteringMode = SKTextureFilteringNearest;
    textureRight.filteringMode = SKTextureFilteringNearest;
    
    if(currentMaxAccelX > 0.05){
        newX = currentMaxAccelX * 10;
        _plane.texture = textureRight;
    }
    else if(currentMaxAccelX < -0.05){
        newX = currentMaxAccelX*10;
        _plane.texture = textureLeft;
    }
    else{
        newX = currentMaxAccelX*10;
        _plane.texture = textureBase;
    }
    
    //NEW* Moving Y
    newY = 6.0 + currentMaxAccelY *10;
    
    float newXshadow = newX+_planeShadow.position.x;
    float newYshadow = 73.5;
    
    newXshadow = MIN(MAX(newXshadow,minY+15),maxY+15);
    
    newX = MIN(MAX(newX+_plane.position.x,minY),maxY);
    //NEW* Moving Y
    newY = MIN(MAX(newY+_plane.position.y,minX),maxX);
    
    _plane.position = CGPointMake(newX, newY);
    _planeShadow.position = CGPointMake(newXshadow, newYshadow);
    
    [self moveBg];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        if (_gameState == PCGameStateStartingLevel) {
            _gameState = PCGameStatePlaying;
            [self childNodeWithName:@"titleLabel"].hidden = YES;
            [self childNodeWithName:@"companyLabel"].hidden = YES;
            [self childNodeWithName:@"msgLabel"].hidden = YES;
            [self childNodeWithName:@"scoreLabel"].hidden = YES;
            [self childNodeWithName:@"distanceLabel"].hidden = NO;
            
            self.gameStartBlock(YES);
            [self runAction:[SKAction repeatActionForever:
                             [SKAction sequence:@[
                                                  [SKAction performSelector:@selector(spawnBird)
                                                                   onTarget:self],
                                                  [SKAction waitForDuration:0.25]]]]];
        } else if (_gameState == PCGameStateInReloadMenu) {
            //MyScene *newScene = [[MyScene alloc] initWithSize:self.size];
            //newScene.userData = self.userData; // High score challenge
            //[self.view presentScene:newScene transition:nil];//[SKTransition flipVerticalWithDuration:0.5]];
            _gameState = PCGameStateStartingLevel;
            [self StartLevel];
            self.gameStartBlock(NO);
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
    SKPhysicsBody *other1 =
    (contact.bodyA.categoryBitMask == PCEngine1Category ?
     contact.bodyB : contact.bodyA); // || PCEngine1Category
    
    SKPhysicsBody *other2 =
    (contact.bodyA.categoryBitMask == PCEngine2Category ?
     contact.bodyB : contact.bodyA);
    

    if (other1.categoryBitMask == PCBirdCategory) {
        [self engineCollision:other1.node engineNumber:EngineNumber1];
    }

    if (other2.categoryBitMask == PCBirdCategory) {
        [self engineCollision:other2.node engineNumber:EngineNumber2];
    }
    
    
    
    
}

-(void)engineCollision:(SKNode*)node engineNumber:(EngineNumber)engineNumber
{
    _emitterFeathers = [SKEmitterNode skt_emitterNamed:[NSString stringWithFormat:@"feathers%@",[node.userData objectForKey:@"birdColor"]]];
    _emitterFeathers.name = @"feathers";
    _emitterFeathers.targetNode = self;
    _emitterFeathers.zPosition = 5;
    
    CGPoint amount;
    
    if(engineNumber == EngineNumber1) {
        _emitterFeathers.position = CGPointMake(-70, 70);
        amount = CGPointMake(-1.0f, 0.0f);
    }else {
        _emitterFeathers.position = CGPointMake(70, 70);
        amount = CGPointMake(1.0f, 0.0f);
    }
    
    [_plane addChild:_emitterFeathers];
    [_emitterFeathers runAction:[SKAction skt_removeFromParentAfterDelay:1]];
    Bird *hitBird = (Bird *)node;
    [hitBird feathersPuff];
    [_plane engineSmokeEngineNumber:engineNumber];
    
    amount.x *= 20;
    amount.y *= 20;
    SKAction *action = [SKAction skt_screenShakeWithNode:_plane amount:amount oscillations:3 duration:1.0];
    [_plane runAction:action];
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

-(void)birdHitEffects:(SKSpriteNode *)birdHit
{
    birdHit.physicsBody = nil;
    [birdHit removeAllActions];
    
    SKNode *newNode = [SKNode node];
    [_bgLayer addChild:newNode];
    newNode.position = birdHit.position;
    birdHit.position = CGPointZero;
    [birdHit removeFromParent];
    [newNode addChild:birdHit];
    
    const NSTimeInterval Duration = 1.3;
    [newNode runAction:
     [SKAction skt_removeFromParentAfterDelay:Duration]];
    
    [self scaleBird:newNode duration:Duration];
    [self rotateBird:newNode duration:Duration];
    [self fadeBird:newNode duration:Duration];
}

- (void)scaleBird:(SKNode *)node
        duration:(NSTimeInterval)duration
{
    const CGFloat ScaleFactor = 1.5f + 2 * 0.25f;
    
    SKAction *scaleUp = [SKAction scaleTo:ScaleFactor
                                 duration:duration * 0.16667];
    scaleUp.timingMode = SKActionTimingEaseIn;
    
    SKAction *scaleDown = [SKAction scaleTo:0.0f
                                   duration:duration * 0.83335];
    scaleDown.timingMode = SKActionTimingEaseIn;
    
    [node runAction:[SKAction sequence:@[scaleUp, scaleDown]]];
}

- (void)rotateBird:(SKNode *)node
         duration:(NSTimeInterval)duration
{
    SKAction *rotateAction = [SKAction rotateByAngle:M_PI*6.0f
                                            duration:duration];
    [node runAction:rotateAction];
}

- (void)fadeBird:(SKNode *)node duration:(NSTimeInterval)duration
{
    SKAction *fadeAction =
    [SKAction fadeOutWithDuration:duration * 0.75];
    fadeAction.timingMode = SKActionTimingEaseIn;
    [node runAction:[SKAction skt_afterDelay:duration * 0.25
                                     perform:fadeAction]];
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    /*SKPhysicsBody *other =
    (contact.bodyA.categoryBitMask == PCPlaneCategory ?
     contact.bodyB : contact.bodyA);
    
    if (other.categoryBitMask &
        _plane.physicsBody.collisionBitMask) {
        //Make plane span down towards engine hit
    }*/
}

- (void)createUserInterface
{
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    
    [self StartLevel];
    
    _emitterRain = [SKEmitterNode skt_emitterNamed:@"rain"];
    _emitterRain.name = @"rain";
    _emitterRain.targetNode = self;
    _emitterRain.position = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) + 10);
    _emitterRain.zPosition = 10;
    
    _emitterSnow = [SKEmitterNode skt_emitterNamed:@"snow"];
    _emitterSnow.name = @"snow";
    _emitterSnow.targetNode = self;
    _emitterSnow.position = CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) + 10);
    _emitterSnow.zPosition = 20;
    
    _distanceLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    _distanceLabel.name = @"distanceLabel";
    _distanceLabel.text = [NSString stringWithFormat:@"Distance: %li",(long)distance];
    _distanceLabel.fontSize = 18;
    _distanceLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _distanceLabel.position = CGPointMake(2, 5);
    _distanceLabel.zPosition = 20;
    _distanceLabel.hidden = YES;
    [self addChild:_distanceLabel];
    
    //adding airplane shadow
    /*_planeShadow = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 SHADOW.png"];
    _planeShadow.scale = 0.6;
    _planeShadow.zPosition = 1;
    _planeShadow.position = CGPointMake(screenWidth/2+15, 0+_planeShadow.size.height/2);
    [self addChild:_planeShadow];*/
}

-(void)StartLevel{
    [self removeAllActions];
    distance = 0;
    _distanceLabel.text = [NSString stringWithFormat:@"Distance: %li",(long)distance];
    _distanceLabel.hidden = YES;
    
    //adding the airplane
    _plane = [[Plane alloc]initWithScreenWidth:screenWidth];
    [self addChild:_plane];
    
    if (!_titleLabel) {
        _titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _titleLabel.text = [NSString stringWithFormat:@"Dangerous Birds"];
        _titleLabel.name = @"titleLabel";
        _titleLabel.fontSize = 30;
        _titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _titleLabel.position = CGPointMake(screenWidth/2, screenHeight-120);
        _companyLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        _companyLabel.text = [NSString stringWithFormat:@"Angry Jackal Studios"];
        _companyLabel.name = @"companyLabel";
        _companyLabel.fontSize = 18;
        _companyLabel.fontColor = [UIColor redColor];
        _companyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _companyLabel.position = CGPointMake(screenWidth/2, screenHeight-143);
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        _scoreLabel.text = [NSString stringWithFormat:@"High Score: %li",(long)[[AppUtil defaultHighScore] integerValue]];
        _scoreLabel.name = @"scoreLabel";
        _scoreLabel.fontSize = 20;
        _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _scoreLabel.position = CGPointMake(screenWidth/2, 30);
        [self addChild:_titleLabel];
        [self addChild:_companyLabel];
        [self addChild:_scoreLabel];
    } else {
        _titleLabel.hidden = NO;
        _companyLabel.hidden = NO;
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
        _scoreLabel.text = [NSString stringWithFormat:@"High Score: %li",(long)[[AppUtil defaultHighScore] integerValue]];
        _scoreLabel.hidden = NO;
    }
    
    if ([[self children] containsObject:_emitterRain])
        [[self childNodeWithName:@"rain"] removeFromParent];
    if ([[self children] containsObject:_emitterSnow])
        [[self childNodeWithName:@"snow"] removeFromParent];
}

-(void)EndLevel{
    //[self removeAllActions];
    _gameState = PCGameStateInReloadMenu;
    
    if ([[AppUtil defaultHighScore]integerValue]<distance) {
        [AppUtil setDefaultHighScore:[NSNumber numberWithInteger:distance]];
        SKLabelNode* label = (SKLabelNode*)[self childNodeWithName:@"scoreLabel"];
        label.text = @"New High Score!!!";
        label.hidden = NO;
    }
    
    
    SKLabelNode* label = (SKLabelNode*)[self childNodeWithName:@"msgLabel"];
    label.text = @"Try Again?";
    label.hidden = NO;
    
    
    
    [_bgLayer enumerateChildNodesWithName:@"bird" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    _emitterPuff = [SKEmitterNode skt_emitterNamed:@"puff"];
    _emitterPuff.name = @"puff";
    _emitterPuff.targetNode = self;
    _emitterPuff.zPosition = 3;
    _emitterPuff.position = _plane.position;
    [self addChild:_emitterPuff];
    [_emitterPuff runAction:[SKAction skt_removeFromParentAfterDelay:2]];
    _plane = nil;
}

- (void)colorGlitch
{
    _bgLayer.hidden = YES;
    
    [self runAction:[SKAction sequence:@[
                                         [SKAction skt_colorGlitchWithScene:self
                                                              originalColor:SKColorWithRGB(89, 133, 39)
                                                                   duration:0.1],
                                         [SKAction runBlock:^{
        _bgLayer.hidden = NO;
    }]]]];
}

@end
