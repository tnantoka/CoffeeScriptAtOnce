//
//  CAProjectManager.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CAProject;

@interface CAProjectManager : NSObject {
    NSMutableArray *_projects;
}

@property (nonatomic, readonly) NSArray *projects;

// Initialization
+ (CAProjectManager *)sharedManager;

// Management Projects
- (void)addProject:(CAProject*)project;
- (void)insertProject:(CAProject*)project atIndex:(unsigned int)index;
- (void)removeProjectAtIndex:(unsigned int)index;
- (void)moveProjectAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex;

// Persistence
- (void)load;
- (void)save;

// Utility
- (BOOL)isExists:(NSString *)name;
- (CAProject *)projectNamed:(NSString *)name;
- (NSString*)projectsPath;

// Samples
- (void)makeSamples;

@end
