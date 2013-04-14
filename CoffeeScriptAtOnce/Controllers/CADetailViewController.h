//
//  CADetailViewController.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import <QuickLook/QuickLook.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

//@interface CADetailViewController : UIViewController <UISplitViewControllerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UITextViewDelegate, UITextFieldDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@interface CADetailViewController : UIViewController <UISplitViewControllerDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UITextViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@end
