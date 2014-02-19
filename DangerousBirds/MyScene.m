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

static const float BG_POINTS_PER_SEC = 50;

@interface MyScene () <SKPhysicsContactDelegate>
@end

@implementation MyScene{
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    SKLabelNode* _distanceLabel;
    SKLabelNode* _titleLabel;
    SKLabelNode* _companyLabel;
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
        
        /*[self runAction:[SKAction repeatActionForever:
                         [SKAction sequence:@[
                                              [SKAction performSelector:@selector(spawnBird)
                                                               onTarget:self],
                                              [SKAction waitForDuration:0.25]]]]];*/
        
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
        bird = [[Bird alloc]init];
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
                    int upperBound = 10;
                    int randomWeather = lowerBound + arc4random() % (upperBound - lowerBound);
                    
                    switch (randomWeather) {
                        case 1: case 6: case 8:
                        {
                            SKAction *lightening =
                            [SKAction sequence:@[[SKAction waitForDuration:2],
                                                 [SKAction performSelector:@selector(colorGlitch) onTarget:self],
                                                 [SKAction waitForDuration:2],
                                                 [SKAction performSelector:@selector(colorGlitch) onTarget:self],
                                                 [SKAction waitForDuration:2],
                                                 [SKAction performSelector:@selector(colorGlitch) onTarget:self]]];
                            [self runAction:lightening];
                        }
                         case 3: case 4:  case 9: case 10:
                        {
                            if (![[self children] containsObject:_emitterRain]) {
                                [self addChild:_emitterRain];
                                [_emitterRain runAction:[SKAction skt_removeFromParentAfterDelay:10]];
                            }
                        }
                            break;
                        case 2: case 5: case 7:
                        {
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
     contact.bodyB : contact.bodyA);
    
    if (other1.categoryBitMask == PCBirdCategory) {
        _emitterFeathers = [SKEmitterNode skt_emitterNamed:@"feathers"];
        _emitterFeathers.name = @"feathers";
        _emitterFeathers.targetNode = self;
        _emitterFeathers.zPosition = 5;
        CGPoint point = CGPointMake(-30, 70);
        _emitterFeathers.position = point;
        [_plane addChild:_emitterFeathers];
        Bird *hitBird = (Bird *)other1.node;
        [hitBird feathersPuff];
        [_plane engineSmokeEngineNumber:EngineNumber1];
    }
    
    SKPhysicsBody *other2 =
    (contact.bodyA.categoryBitMask == PCEngine2Category ?
     contact.bodyB : contact.bodyA);
    
    if (other2.categoryBitMask == PCBirdCategory) {
        _emitterFeathers = [SKEmitterNode skt_emitterNamed:@"feathers"];
        _emitterFeathers.name = @"feathers";
        _emitterFeathers.targetNode = self;
        _emitterFeathers.zPosition = 5;
        CGPoint point = CGPointMake(30, 70);
        _emitterFeathers.position = point;
        [_plane addChild:_emitterFeathers];
        Bird *hitBird = (Bird *)other2.node;
        [hitBird feathersPuff];
        [_plane engineSmokeEngineNumber:EngineNumber2];
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
    [self addChild:_distanceLabel];
    
    //adding airplane shadow
    /*_planeShadow = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 SHADOW.png"];
    _planeShadow.scale = 0.6;
    _planeShadow.zPosition = 1;
    _planeShadow.position = CGPointMake(screenWidth/2+15, 0+_planeShadow.size.height/2);
    [self addChild:_planeShadow];*/
}

-(void)StartLevel{
    distance = 0;
    _distanceLabel.text = [NSString stringWithFormat:@"Distance: %li",(long)distance];
    
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
        [self addChild:_titleLabel];
        [self addChild:_companyLabel];
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
    }
    
    if ([[self children] containsObject:_emitterRain])
        [[self childNodeWithName:@"rain"] removeFromParent];
    if ([[self children] containsObject:_emitterSnow])
        [[self childNodeWithName:@"snow"] removeFromParent];
    
}

-(void)EndLevel{
    [self removeAllActions];
    _gameState = PCGameStateInReloadMenu;
    
    SKLabelNode* label = (SKLabelNode*)[self childNodeWithName:@"msgLabel"];
    label.text = @"Try Again?";
    label.hidden = NO;
    
    _emitterPuff = [SKEmitterNode skt_emitterNamed:@"puff"];
    _emitterPuff.name = @"puff";
    _emitterPuff.targetNode = self;
    _emitterPuff.zPosition = 3;
    _emitterPuff.position = _plane.position;
    [_emitterPuff runAction:[SKAction skt_removeFromParentAfterDelay:1]];
    //[self addChild:_emitterPuff];
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
