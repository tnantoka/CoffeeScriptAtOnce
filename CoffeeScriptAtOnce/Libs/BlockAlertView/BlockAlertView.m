//
//  BlockAlertView.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BlockAlertView.h"

@implementation BlockAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)showWithCompletionHandler:(void(^)(NSInteger buttonIndex))completionHandler {
    _completionHandler = [completionHandler copy];
    [self show];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    _completionHandler(buttonIndex);
}

- (void)dealloc
{
    [_completionHandler release];
    [super dealloc];
}

@end
