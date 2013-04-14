//
//  CAMasterViewController.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <iAd/iAd.h>

@class CADetailViewController;

@interface CAMasterViewController : UITableViewController <ADBannerViewDelegate>

@property (strong, nonatomic) CADetailViewController *detailViewController;

@end
