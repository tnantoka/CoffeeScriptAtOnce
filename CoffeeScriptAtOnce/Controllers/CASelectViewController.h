//
//  CASelectViewController.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NADView.h"

@interface CASelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NADViewDelegate>

@property (nonatomic, assign) NSArray *items;
@property (nonatomic, assign) UILabel *target;

@end
