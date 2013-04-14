//
//  CALogsViewController.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CALogsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) id delegate;

@end

@interface NSObject (CALogsViewControllerDelegate)

- (void)logsControllerDidSave:(CALogsViewController *)controller;

@end