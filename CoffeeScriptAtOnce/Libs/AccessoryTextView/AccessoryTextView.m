//
//  AccessoryTextView.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccessoryTextView.h"
#import <QuartzCore/QuartzCore.h>

#import "BlockAlertView.h"

@interface AccessoryTextView()

@property (nonatomic, retain) UITextField *beforeField;
@property (nonatomic, retain) UITextField *afterField;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIView *accessoryView;

@end

@implementation AccessoryTextView

@synthesize keys = _keys;
@synthesize beforeField = _beforeField;
@synthesize afterField = _afterField;
@synthesize overlayView = _overlayView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.overlayView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height * 2)] autorelease];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlayView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3];
        [self addSubview:_overlayView];
        _overlayView.hidden = YES;
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

- (void)dealloc {
    
    [_keys release];
    [_beforeField release];
    [_afterField release];
    [_overlayView release];
    [_accessoryView release];
    
    [super dealloc];
}

# pragma mark - Button Actions

- (void)keyAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSString *key = [[_keys objectAtIndex:button.tag] objectAtIndex:1];
    [self _insertString:key];
    
    [self _resign];
}

- (void)undoAction:(id)sender {
    [[self undoManager] undo];

    [self _resign];
}

- (void)redoAction:(id)sender {
    [[self undoManager] redo];    

    [self _resign];
}

- (void)replaceAction:(id)sender {
    NSString *before = _beforeField.text;
    NSString *after = _afterField.text;
    
    BlockAlertView *blockAlert = [[BlockAlertView alloc] initWithTitle:@"Replace Strings" message:[NSString stringWithFormat:@"Replace \"%@\" with \"%@\", OK?\n(Cannot redo!)", before, after] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    [blockAlert showWithCompletionHandler:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0: {
             
                NSMutableString *text = [self.text mutableCopy];
                
                NSRange range = self.selectedRange;
                [text replaceOccurrencesOfString:before withString:after options:0 range:NSMakeRange(0, text.length)];
                 
                // restore cursor and scroll position
                self.scrollEnabled = NO;
                self.text = text;
                [text release];
                self.scrollEnabled = YES;
                self.selectedRange = range;
                
                [self _resign];
                
                if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
                    [self.delegate textViewDidChange:self];
                }
                
                break;
            }
            case 1:
                
                break;
        }
    }];
    [blockAlert release];
}

# pragma mark -- Insert string with Undo, Redo

- (void)_insertString:(NSString *)string {
    
	NSMutableString *text = [self.text mutableCopy];
    
    //NSLog(@"before %d, %d", self.selectedRange.location, self.selectedRange.length);
    
	NSRange range = self.selectedRange;
	[text replaceCharactersInRange:range withString:string];
    
    // restore cursor and scroll position
    self.scrollEnabled = NO;
	self.text = text;
    [text release];
    self.scrollEnabled = YES;
	self.selectedRange = NSMakeRange(range.location + string.length, range.length);
    //[self scrollRangeToVisible:self.selectedRange]; // doesn't work?
     
    //NSLog(@"after %d, %d", self.selectedRange.location, self.selectedRange.length);
    

	[[self undoManager] registerUndoWithTarget:self selector:@selector(_backSpace:) object:string];
}

- (void)_backSpace:(NSString *)string {
	
	NSMutableString *text = [self.text mutableCopy];

	NSRange range = self.selectedRange;
	self.selectedRange = NSMakeRange(range.location - string.length, string.length);
	[text replaceCharactersInRange:self.selectedRange withString:@""];

    // restore cursor and scroll position
    self.scrollEnabled = NO;
	self.text = text;
    [text release];
    self.scrollEnabled = YES;
	self.selectedRange = NSMakeRange(range.location - string.length, 0);
    //[self scrollRangeToVisible:self.selectedRange]; // doesn't work?
    
	[[self undoManager] registerUndoWithTarget:self selector:@selector(_insertString:) object:string];
}

# pragma mark - Cursor

- (void)leftAction:(id)sender {
	NSRange range = self.selectedRange;
	self.selectedRange = NSMakeRange(range.location - 1, range.length);
	[[self undoManager] registerUndoWithTarget:self selector:@selector(rightAction:) object:nil];

    [self _resign];
}

- (void)rightAction:(id)sender {
	NSRange range = self.selectedRange;
	self.selectedRange = NSMakeRange(range.location + 1, range.length);
	[[self undoManager] registerUndoWithTarget:self selector:@selector(leftAction:) object:nil];

    [self _resign];
}

# pragma mark - Public method

- (void)setUserKeys:(NSString *)userKeys {

    int viewHeight = 40;
    int margin = 5;
    int buttonHeight = viewHeight - margin * 2;
    int buttonWidth = 40;
    
    int buttonX = margin;
    UIFont *buttonFont = [UIFont boldSystemFontOfSize:18.0f];

    UIScrollView *accessoryView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, viewHeight)];
    accessoryView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.7f];
    
    self.keys = [NSMutableArray arrayWithObjects:
                 [NSArray arrayWithObjects:@"\\t", @"  ", nil], 
                 nil];
    
    for (int i = 0; i < userKeys.length; i++) {
        NSString *key = [userKeys substringWithRange:NSMakeRange(i, 1)];
        [_keys addObject:[NSArray arrayWithObjects:key, key, nil]];
    }
    
    for (int i = 0; i < _keys.count; i++) {
        NSString *title = [[_keys objectAtIndex:i] objectAtIndex:0];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(keyAction:) forControlEvents:UIControlEventTouchUpInside];
        
        button.frame = CGRectMake(buttonX, margin, buttonWidth, buttonHeight);
        button.tag = i;
        
        buttonX += buttonWidth + margin;
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        button.titleEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1.0f;
        
        button.titleLabel.font = buttonFont;
        
        [accessoryView addSubview:button];
    }
    
    
    UIButton *button;
    
    // undo, redo
    int undoButtonWidth = buttonWidth + 10;
    UIFont *undoFont = [UIFont boldSystemFontOfSize:14.0f];
    
    // undo
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Undo" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];        
    button.frame = CGRectMake(buttonX, margin, undoButtonWidth, buttonHeight);
    [accessoryView addSubview:button];        
    buttonX += undoButtonWidth + margin;
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.titleEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1.0f;
    
    button.titleLabel.font = undoFont;
    
    // redo
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Redo" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(redoAction:) forControlEvents:UIControlEventTouchUpInside];        
    button.frame = CGRectMake(buttonX, margin, undoButtonWidth, buttonHeight);
    [accessoryView addSubview:button];
    buttonX += undoButtonWidth + margin;
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.titleEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1.0f;
    
    button.titleLabel.font = undoFont;
    
    // cursor
    int cursorButtonWidth = buttonWidth;
    UIFont *cursorButtonFont = [UIFont boldSystemFontOfSize:26.0f];
    
    // left
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"←" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];        
    button.frame = CGRectMake(buttonX, margin, cursorButtonWidth, buttonHeight);
    [accessoryView addSubview:button];
    buttonX += cursorButtonWidth + margin;
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.titleEdgeInsets = UIEdgeInsetsMake(margin, margin * 1.5, margin, margin * 0.5);
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1.0f;
    
    button.titleLabel.font = cursorButtonFont;
    
    // right
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"→" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];        
    button.frame = CGRectMake(buttonX, margin, cursorButtonWidth, buttonHeight);
    [accessoryView addSubview:button];
    buttonX += cursorButtonWidth + margin;
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.titleEdgeInsets = UIEdgeInsetsMake(margin, margin * 1.5, margin, margin * 0.5);
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1.0f;
    
    button.titleLabel.font = cursorButtonFont;
    
    // Replace
    NSString *maxString;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        maxString = @"123456789012";
    } else {
        maxString = @"1234567890123456789012";        
    }
    CGSize labelSize = [maxString sizeWithFont:[UIFont boldSystemFontOfSize:16]];

    // before
    self.beforeField = [[[UITextField alloc] initWithFrame:CGRectMake(buttonX, margin, labelSize.width, buttonHeight)] autorelease];
    [accessoryView addSubview:_beforeField];
    buttonX += labelSize.width + margin;

    _beforeField.borderStyle = UITextBorderStyleRoundedRect;
    _beforeField.placeholder = @"Before";
    _beforeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //_beforeField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _beforeField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _beforeField.autocorrectionType = UITextAutocorrectionTypeNo;
    _beforeField.delegate = self;
    _beforeField.returnKeyType = UIReturnKeyDone;
    _beforeField.text = @"";
    
    // after
    self.afterField = [[[UITextField alloc] initWithFrame:CGRectMake(buttonX, margin, labelSize.width, buttonHeight)] autorelease];
    [accessoryView addSubview:_afterField];
    buttonX += labelSize.width + margin;
    
    _afterField.borderStyle = UITextBorderStyleRoundedRect;
    _afterField.placeholder = @"After";
    _afterField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //_beforeField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _afterField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _afterField.autocorrectionType = UITextAutocorrectionTypeNo;
    _afterField.delegate = self;
    _afterField.returnKeyType = UIReturnKeyDone;
    _afterField.text = @"";

    // replace all
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Replace" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(replaceAction:) forControlEvents:UIControlEventTouchUpInside];        
    button.frame = CGRectMake(buttonX, margin, 70, buttonHeight);
    [accessoryView addSubview:button];
    buttonX += button.frame.size.width + margin;
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    button.titleEdgeInsets = UIEdgeInsetsMake(margin, margin * 1.0, margin, margin * 0.5);
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1.0f;
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];

    
    accessoryView.contentSize = CGSizeMake(buttonX, viewHeight);
    self.inputAccessoryView = accessoryView;
    self.accessoryView = accessoryView;
    [accessoryView release];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapRecognizer.numberOfTapsRequired = 1;
    //[self addGestureRecognizer:tapRecognizer];
    [_overlayView addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
}

# pragma mark - UITextField in accessoryView can't resign firstresponder in default

- (void)_resign {
    [_beforeField resignFirstResponder];
    [_afterField resignFirstResponder];    
    _overlayView.hidden = YES;
    self.scrollEnabled = YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _overlayView.hidden = NO;
    self.scrollEnabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self _resign];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self _resign];
    return NO;
}

- (BOOL)resignFirstResponder {
    
    [self _resign];
    
    return [super resignFirstResponder];
}

- (void)tapAction:(id)sender {
    [self _resign];
}

- (void)hideAccessory:(BOOL)hidden {
    NSLog(@"hide accessory %d", hidden);
    if (hidden) {
        self.inputAccessoryView = nil;        
    } else {
        self.inputAccessoryView = _accessoryView;
    }
}

@end
