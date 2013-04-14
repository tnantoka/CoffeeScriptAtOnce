//
//  BlockAlertView.h
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockAlertView : UIAlertView {
    void    (^_completionHandler)(NSInteger buttonIndex);
}
- (void)showWithCompletionHandler:(void(^)(NSInteger buttonIndex))_completionHandler;
@end
