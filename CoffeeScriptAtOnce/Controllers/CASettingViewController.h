//
//  CASettingViewController.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NADView.h"

@interface CASettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NADViewDelegate>

@property (nonatomic, assign) id delegate;

@end

@interface NSObject (CASettingViewControllerDelegate)

- (void)settingControllerDidCancel:(CASettingViewController *)controller;
- (void)settingControllerDidSave:(CASettingViewController *)controller;

@end
