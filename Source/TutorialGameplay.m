//
//  TutorialGameplay.m
//  PivotVividGGJ14
//
//  Created by Benjamin Encz on 24/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "TutorialGameplay.h"
#import "TutorialFragment.h"
#import "Level.h"
#import "GameState.h"

// TODO: this can only be used for prototype
static int _currentFragmentIndex;

@implementation TutorialGameplay {
    NSMutableArray *_tutorialFragments;
    CCLabelTTF *_instructionLabel;
    NSString *_tutorialName;
    NSArray *_fragmentNames;
}

- (void)didLoadFromCCB {
    self.level = [[Level alloc] init];
    
    [super didLoadFromCCB];
    
    NSDictionary *tutorialInfo = [[GameState sharedInstance] currentLevelInfo];
    _tutorialName = tutorialInfo[@"levelName"];
    _fragmentNames = tutorialInfo[@"tutorialFragments"];
    
    [self loadCurrentTutorialFragment];
}

#pragma mark - Load Tutorial Fragement

- (NSString *)currentFragmentCCBName {
    NSString *currentFragmentName = _fragmentNames[_currentFragmentIndex];
    NSString *fragmentCCBFile = [NSString stringWithFormat:@"Tutorials/%@/%@", _tutorialName, currentFragmentName];
    
    return fragmentCCBFile;
}

- (void)loadCurrentTutorialFragment {
    NSString *fragmentCCBFile = [self currentFragmentCCBName];
    
    TutorialFragment *tutorialFragment1 = (TutorialFragment *) [CCBReader load:fragmentCCBFile];
    [self.level addChild:tutorialFragment1];
    self.delegate = tutorialFragment1;
    
    TutorialFragment *tutorialFragment2 = (TutorialFragment *) [CCBReader load:fragmentCCBFile];
    tutorialFragment2.position = ccp(tutorialFragment1.contentSize.width, 0);
    [self.level addChild:tutorialFragment2];
    
    _tutorialFragments = [@[tutorialFragment1, tutorialFragment2] mutableCopy];
    
    // update instruction
    _instructionLabel.string = NSLocalizedString(tutorialFragment1.instruction, nil);
    
    [super findBlocks:self.level];
}

#pragma mark - Next Tutorial Step

- (void)nextTutorialStep {
    if ((_currentFragmentIndex+1) < [_fragmentNames count]) {
        _currentFragmentIndex++;
    }
    _instructionLabel.string = @"Well done!";
}

#pragma mark - Inform Delegate

- (void)jump {
    [super jump];
    
    if ([self.delegate respondsToSelector:@selector(tutorialGameplayJumped:)]) {
        [self.delegate tutorialGameplayJumped:self];
    }
}

- (void)switchMood {
    [super switchMood];
    
    if ([self.delegate respondsToSelector:@selector(tutorialGameplayChangedMood:)]) {
        [self.delegate tutorialGameplayChangedMood:self];
    }
}

#pragma mark - Overriden Gameplay Methods

- (void)endGame {
    [self restartLevel];
}

- (void)restartLevel {
    // reload level
    [super stopMusic];
    CCScene *scene = [CCBReader loadAsScene:@"TutorialGameplay"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)update:(CCTime)delta {
    [super update:delta];
    
    // loop tutorial fragments
    for (int i = 0; i < [_tutorialFragments count]; i++) {
        TutorialFragment *fragment = _tutorialFragments[i];
        
        // get the world position of the fragment
        CGPoint fragmentWorldPosition = [self.level convertToWorldSpace:fragment.position];
        // get the screen position of the fragment
        CGPoint fragmentScreenPosition = [self convertToNodeSpace:fragmentWorldPosition];
        
        // if the left corner is one complete width off the screen, move it to the right
        if (fragmentScreenPosition.x <= (-1 * fragment.contentSize.width)) {
            // workaround for compound static physics objects not beeing movable
            CCNode *parent = fragment.parent;
            CGPoint fragmentPosition = fragment.position;
            CGSize fragmentSize = fragment.contentSize;
            [fragment removeFromParent];
            
            if ([fragment respondsToSelector:@selector(tutorialGameplayCompletedFragment:)]) {
                [fragment tutorialGameplayCompletedFragment:self];
            }
            
            TutorialFragment *otherFragment = (i == 0) ? _tutorialFragments[1] : _tutorialFragments[0];
            
            fragment = _tutorialFragments[i] = (TutorialFragment *) [CCBReader load:[self currentFragmentCCBName]];
            fragment.position = ccp(otherFragment.position.x + otherFragment.contentSize.width, fragmentPosition.y);
            [parent addChild:fragment];
            self.delegate = fragment;
            _instructionLabel.string = NSLocalizedString(fragment.instruction, nil);
            
            [super findBlocks:fragment];
        }
    }
}

@end
