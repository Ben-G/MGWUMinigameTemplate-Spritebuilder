//
//  GameState.h
//  PivotVividGGJ14
//
//  Created by Benjamin Encz on 26/01/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject

+ (id)sharedInstance;

@property (nonatomic, strong) NSString *currentLevel;

@end
