//
//  dragonNode.m
//  Santa
//
//  Created by Rodger on 12/21/13.
//  Copyright (c) 2013 Rodger Wilson. All rights reserved.
//



#import "flyingPlane.h"


#define COL_TYPE_1 1
#define COL_TYPE_2 2

@implementation flyingPlane{
    SKEmitterNode *smokeEmitter;
    SKEmitterNode *fireEmitter;
    NSMutableArray * headOpenTextures;
    NSMutableArray * headCloseTextures;
    SKSpriteNode * head;
    float oldBirthrate;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        SKSpriteNode * body = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        body.size = CGSizeMake(30, 30);
        body.position = CGPointMake(0, 0);
        body.name = @"plane";
        [self addChild:body];
        self.name = @"plane";
        
        [self addFire];
    }
    return self;
}

- (void) addFire{
    if (fireEmitter == nil) {
        fireEmitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"dragonFire" ofType:@"sks"]];
        oldBirthrate = fireEmitter.particleBirthRate;
        fireEmitter.position = CGPointMake(0,0);
        fireEmitter.name = @"dragonFire";
        fireEmitter.targetNode = self;
        fireEmitter.zPosition=20.0;
        fireEmitter.position = CGPointMake(0, -20);
        fireEmitter.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(30, 30)];
        fireEmitter.physicsBody.affectedByGravity = NO;
        fireEmitter.physicsBody.mass = 10000000000000;
        [self addChild:fireEmitter];
    }
    fireEmitter.particleBirthRate = oldBirthrate;
}

@end






