//
//  CAProjectManager.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CAProjectManager.h"
#import "CAProject.h"
#import "CAUtil.h"

@implementation CAProjectManager

@synthesize projects = _projects;

static CAProjectManager *_sharedInstance = nil;

# pragma mark - Initialization

+ (CAProjectManager *)sharedManager {
    if (!_sharedInstance) {
        _sharedInstance = [[CAProjectManager alloc] init];
    }    
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _projects = [[NSMutableArray array] retain];
#ifdef DEBUG
//        [self _reset];
#endif
    }
    return self;
}

- (void)dealloc
{
    [_projects release], _projects = nil;
    
    [super dealloc];
}

# pragma mark - Management Projects

- (void)addProject:(CAProject*)project {
    if (!project) {
        return;
    }
    [_projects addObject:project];
    LOG(@"_projects = %@", _projects);
}

- (void)insertProject:(CAProject*)project atIndex:(unsigned int)index {
    if (!project) {
        return;
    }
    //if (index < 0 || index > _projects.count) {
    if (index > _projects.count) {
        return;
    }
    
    [_projects insertObject:project atIndex:index];
}

- (void)removeProjectAtIndex:(unsigned int)index {
    //if (index < 0 || index > _projects.count - 1) {
    if (index > _projects.count - 1) {
        return;
    }
    
    CAProject *project = [_projects objectAtIndex:index];
                          
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [project projectPath];
    [fileManager removeItemAtPath:path error:&error];
    
    if (error) {
        [CAUtil showError:[error localizedDescription]];
        return;
    }
    
    [_projects removeObjectAtIndex:index];
}

- (void)moveProjectAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex {
    //if (fromIndex < 0 || fromIndex > _projects.count - 1) {
    if (fromIndex > _projects.count - 1) {
        return;
    }
    //if (toIndex < 0 || toIndex > _projects.count) {
    if (toIndex > _projects.count) {
        return;
    }
    
    CAProject *project = [_projects objectAtIndex:fromIndex];
    [project retain];
    [_projects removeObject:project];
    [_projects insertObject:project atIndex:toIndex];
    [project release];
}

# pragma mark - Persistence

- (NSString*)_projectDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1) {
        return nil;
    }
    NSString *path = [paths objectAtIndex:0];
    
    //path = [path stringByAppendingPathComponent:@".project"];
    path = [path stringByAppendingPathComponent:@"meta"];
    LOG(@"%@", path);
    return path;
}

- (NSString*)_projectPath {
    NSString *path = [[self _projectDir] stringByAppendingPathComponent:@"project.dat"];
    LOG(@"%@", path);
    return path;
}

- (void)load {
    NSString *projectPath = [self _projectPath];
    if (!projectPath || ![[NSFileManager defaultManager] fileExistsAtPath:projectPath]) {
        return;
    }
    
    NSArray *projects = [NSKeyedUnarchiver unarchiveObjectWithFile:projectPath];
    if (!projects) {
        return;
    }
    
    [_projects setArray:projects];
    LOG(@"projects: %@", _projects);
}

- (void)save {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *projectDir = [self _projectDir];
    if (![fileManager fileExistsAtPath:projectDir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:projectDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [CAUtil showError:[error localizedDescription]];
            return;
        }
    }
    
    NSString *projectPath = [self _projectPath];
    LOG(@"saved: %@", projectPath);
    [NSKeyedArchiver archiveRootObject:_projects toFile:projectPath];
}

- (void)_reset {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self _projectDir] error:&error];    

    if (error) {
        [CAUtil showError:[error localizedDescription]];
    }

}


# pragma mark - Utility

- (BOOL)isExists:(NSString *)name {
    if ([self projectNamed:name]) {
        return YES;
    } else {
        return NO;
    }
}

- (CAProject *)projectNamed:(NSString *)name {
    for (CAProject *project in _projects) {
        if ([project.name isEqualToString:name]) {
            return project;
        }
    }    
    return nil;
}

- (NSString*)projectsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1) {
        return nil;
    }
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@"projects"];
    LOG(@"%@", path);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            [CAUtil showError:[error localizedDescription]];
            return nil;
        }
    }
    
    return path;
}


- (void)makeSamples {
 
    CAProject *project;
    NSString *jsContent;
    NSString *fromPath;
    NSString *toPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    project = [[CAProject alloc] initWithIsCoffeeScript:YES isJQuery:YES];
    [self addProject:project];
    [project release];
    project.name = @"Hello, CS At Once!";
    project.isOnError = ![CAUtil isIOS4];
    project.isConsoleLog = YES;
    project.updatedAt = [NSDate date];        

    project = [[CAProject alloc] initWithIsCoffeeScript:YES isJQuery:YES];
    [self addProject:project];
    [project release];
    project.name = @"console.log";
    project.isOnError = ![CAUtil isIOS4];
    project.isConsoleLog = YES;
    project.updatedAt = [NSDate date];
    jsContent = [project loadJs];
    jsContent = [jsContent stringByAppendingString:@"\nconsole.log 'Hello'"];
    [project saveJs:jsContent];

    project = [[CAProject alloc] initWithIsCoffeeScript:NO isJQuery:YES];
    [self addProject:project];
    [project release];
    project.name = @"With jQuery";
    project.isOnError = ![CAUtil isIOS4];
    project.isConsoleLog = YES;
    project.updatedAt = [NSDate date];        

    project = [[CAProject alloc] initWithIsCoffeeScript:NO isJQuery:NO];
    [self addProject:project];
    [project release];
    project.name = @"Plain JS";
    project.isOnError = ![CAUtil isIOS4];
    project.isConsoleLog = YES;
    project.updatedAt = [NSDate date];        

    project = [[CAProject alloc] initWithIsCoffeeScript:YES isJQuery:YES];
    [self addProject:project];
    [project release];
    project.name = @"Keywords";
    project.isOnError = ![CAUtil isIOS4];
    project.isConsoleLog = YES;
    project.updatedAt = [NSDate date];   
    
    fromPath = [[NSBundle mainBundle] pathForResource:@"keywords" ofType:nil];
    toPath = [project projectPath];
    [fileManager removeItemAtPath:toPath error:&error];
    [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];

    project = [[CAProject alloc] initWithIsCoffeeScript:YES isJQuery:YES];
    [self addProject:project];
    [project release];
    project.name = @"Processing.js";
    project.isOnError = ![CAUtil isIOS4];
    project.isConsoleLog = YES;
    project.updatedAt = [NSDate date];   
    
    fromPath = [[NSBundle mainBundle] pathForResource:@"processingjs" ofType:nil];
    toPath = [project projectPath];
    [fileManager removeItemAtPath:toPath error:&error];
    [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];

    LOG(@"before save");
    [self save];
    LOG(@"after save");
}


@end
