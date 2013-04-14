//
//  BNLineNumbersTextView.h
//  BNLineNumbersTextView
//
//  Created by Tatsuya Tobioka on 12/09/05.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNLineNumbersTextView : UIView <UITextViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id originalDelegate;

@property (nonatomic, assign) UITextView *mainTextView;
@property (nonatomic, retain) UITextView *numTextView;
@property (nonatomic, retain) UILabel *infoLabel;

@property (nonatomic, assign) BOOL hasInfo;
@property (nonatomic, assign) BOOL hasNum;


- (id)initWithTextView:(UITextView *)textView;

- (void)updateFrame:(CGRect)frame;
- (void)syncStyle;

@end
