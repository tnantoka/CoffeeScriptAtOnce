//
//  CAProject.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *CAProjectDidFinishAddLib;
extern NSString *CAProjectDidFinishImportHtml;
extern NSString *CAProjectDidFinishImportCss;
extern NSString *CAProjectDidFinishImportJs;

extern NSString *CAProjectDidFailImportHtml;
extern NSString *CAProjectDidFailImportCss;
extern NSString *CAProjectDidFailImportJs;

@interface CAProject : NSObject <NSCoding>

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *gistId;

@property (nonatomic) BOOL isCoffeeScript;
@property (nonatomic) BOOL isJQuery;
@property (nonatomic) BOOL isOnError;
@property (nonatomic) BOOL isConsoleLog;

- (NSString*)projectPath;

- (id)initWithIsCoffeeScript:(BOOL)isCoffeeScript isJQuery:(BOOL)isJQuery;
- (id)initFromProject:(CAProject *)project;

- (NSString *)loadHtml;
- (NSString *)loadBuildHtml;
- (void)saveHtml:(NSString *)content;

- (NSString *)loadCss;
- (void)saveCss:(NSString *)content;

- (NSString *)loadJs;
- (void)saveJs:(NSString *)content;

- (NSURLRequest *)build;

- (void)addLib:(NSString *)urlString;
- (void)removeLib:(NSString *)name;
- (NSURLRequest *)loadLib:(NSString *)lib;
- (NSArray *)libs;

- (void)importHtml:(NSString *)urlString;
- (void)importCss:(NSString *)urlString;
- (void)importJs:(NSString *)urlString;

- (NSData *)htmlData;
- (NSData *)cssData;
- (NSData *)jsData;

@end

