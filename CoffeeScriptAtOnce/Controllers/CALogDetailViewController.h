//
//  CALogDetailViewController.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CALogDetailViewController : UIViewController

@property (nonatomic, retain) NSString *detail;
@property (nonatomic, assign) id delegate;

@end
