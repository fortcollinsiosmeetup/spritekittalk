//
//  MyScene.m
//  demo
//
//  Created by Rodger on 3/31/14.
//  Copyright (c) 2014 Rodger Wilson. All rights reserved.
//

#import "MyScene.h"
#import "flyingPlane.h"
#import <ImageIO/ImageIO.h>

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
        
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-1000, 0) toPoint:CGPointMake(2000, 0)];//##3
        self.physicsBody.node.name = @"ground";//##3
        self.physicsWorld.contactDelegate = self;//##3
        self.physicsBody.contactTestBitMask = 0x01;//##5
        
        
        flyingPlane *p = [[flyingPlane alloc] init];
        p.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:p];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.position = location;
        sprite.size = CGSizeMake(30, 30);
        sprite.physicsBody = [[SKPhysicsBody alloc] init]; //##2 add
        sprite.physicsBody.mass = 10000;
        sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:15]; //##4
        sprite.physicsBody.contactTestBitMask = 0x01;//##5
        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1]; // ##1 comment out
//        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

- (void) didBeginContact:(SKPhysicsContact *)contact{
    NSLog(@"%@ -->  %@", contact.bodyA.node.name, contact.bodyB.node.name);
    SKNode * nodeA = contact.bodyA.node;
    SKNode * nodeB = contact.bodyB.node;
    
    if ([nodeA.name isEqualToString:@"plane"]) {
        [self blowUpSprite:nodeA];
    } else {
        [self blowUpSprite:nodeB];
    }
}

















- (void) blowUpSprite:(SKNode*)sprite{
    //    [self findAndBlowupNodeOfType:@"gift" closerThan:50 toRefNode:sprite];
    [self removeChildrenInArray:@[sprite]];
    //NSLog(@"exploding sprite %p", sprite);
    
    SKTexture * imageTexture;
    SKSpriteNode * explosion;
    CGSize nodeSize = CGSizeMake(sprite.frame.size.width, sprite.frame.size.height);
    NSString * path = [[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"gif" inDirectory:nil];
    NSArray * imageArray = [self getImageWithPath:path];
    NSMutableArray * textureArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [imageArray count]; i++) {
        imageTexture = [SKTexture textureWithImage:[imageArray objectAtIndex:i]];
        [textureArray addObject:imageTexture];
    }
    if ([imageArray count] == 1) {
        explosion = [SKSpriteNode spriteNodeWithTexture:imageTexture size:nodeSize];
    } else {
        explosion = [SKSpriteNode spriteNodeWithTexture:[textureArray objectAtIndex:0] size:nodeSize];
    }
    explosion.position = sprite.position;
    explosion.physicsBody.contactTestBitMask = 0x01;;
    explosion.physicsBody.collisionBitMask = 0x01;
    SKAction * animateGIF = [SKAction animateWithTextures:textureArray timePerFrame:0.05 resize:YES restore:YES];
    SKAction * repeatingAction = [SKAction repeatAction:animateGIF count:1];
    [explosion runAction:repeatingAction completion:^{
        [self removeChildrenInArray:@[explosion]];
    }];
    [self addChild:explosion];
    [explosion.physicsBody applyForce:CGVectorMake(100, 0) ];
    
    //    [self playSound:explosionSound];
    [self runAction:[SKAction playSoundFileNamed:@"explosion.wav" waitForCompletion:NO]];
}

- (NSArray*) getImageWithPath:(NSString*)path{
    //NSLog(@"%s", __FUNCTION__);
    
    NSArray * images = [imageDictionary objectForKey:path];
    NSArray * parts = [path componentsSeparatedByString:@"/"];
    NSString * fileType = [[[parts objectAtIndex:parts.count-1] componentsSeparatedByString:@"."] objectAtIndex:1];
    
    if (images == nil) {
        if ([fileType isEqualToString:@"gif"] || [fileType isEqualToString:@"GIF"]) {
            images = [self loadGifNamed:path];
            [imageDictionary setObject:images forKey:path];
        } else { // for the mac I need an if for png and one for jpg
            UIImage *image = [UIImage imageNamed:path];
            images = @[image];
            [imageDictionary setObject:images forKey:path];
        }
    }
    
    return images;
}

- (NSArray*) loadGifNamed:(NSString*)gifPath{
    //NSLog(@"%s", __FUNCTION__);
    
    NSError* error = nil;
    NSData *gifData = [NSData dataWithContentsOfFile:gifPath options:NSDataReadingMappedIfSafe error:&error];
    if (!gifData) {
        NSLog(@"error: %@", error);
    }
    
    NSMutableArray * frames = nil;
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, NULL);
    if (src) {
        size_t l = CGImageSourceGetCount(src);
        frames = [NSMutableArray arrayWithCapacity:l];
        for (size_t i = 0; i < l; i++) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            if (img) {
                UIImage * cursorImage = [UIImage imageWithCGImage:img];
                [frames addObject:cursorImage];
                CGImageRelease(img);
            }
        }
    }
    return frames;
}

@end
