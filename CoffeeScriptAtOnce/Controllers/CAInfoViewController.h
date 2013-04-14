//
//  CAInfoViewController.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NADView.h"

@class CAProject;

@interface CAInfoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NADViewDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) CAProject *project;

@end


@interface NSObject (CAInfoViewControllerDelegate)

- (void)infoControllerDidCancel:(CAInfoViewController *)controller;
- (void)infoController:(CAInfoViewController *)controller didSave:(CAProject *)project;

@end