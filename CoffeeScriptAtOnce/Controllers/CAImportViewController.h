//
//  CAImportViewController.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CAProject;

@interface CAImportViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) CAProject *project;

@end

@interface NSObject (CAImportViewControllerDelegate)

- (void)importControllerDidSave:(CAImportViewController *)controller;

@end