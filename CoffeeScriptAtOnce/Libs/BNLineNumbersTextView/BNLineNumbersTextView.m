//
//  BNLineNumbersTextView.m
//  BNLineNumbersTextView
//
//  Created by Tatsuya Tobioka on 12/09/05.
//  Copyright (c) 2012年 Tatsuya Tobioka. All rights reserved.
//

#import "BNLineNumbersTextView.h"

#import <QuartzCore/QuartzCore.h>

#define MAX_LINE_NUM @"99999"
#define INFO_FORMAT @"L:%3d/%3d, C:%3d/%3d"
#define INFO_OPACITY_MIN 0.2f
#define INFO_OPACITY_MAX 0.5f

@implementation BNLineNumbersTextView

- (void)dealloc {
    
    _originalDelegate = nil;
    
    _mainTextView = nil;
    
#if !__has_feature(objc_arc)
    [_infoLabel release];
    [_numTextView release];
    
    [super dealloc];
#endif
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTextView:(UITextView *)textView {
    self = [super initWithFrame:textView.frame];
    if (self) {
        
        // Init view
        self.backgroundColor = textView.backgroundColor;
        self.autoresizingMask = textView.autoresizingMask;
        
        // Init text view
        NSString *maxLineNum = MAX_LINE_NUM;
        float lineNumWidth = [maxLineNum sizeWithFont:textView.font].width;
        
        CGRect textViewFrame = textView.frame;
        
        //textViewFrame.origin.x += lineNumWidth;
        textViewFrame.origin.x = lineNumWidth;
        textViewFrame.origin.y = 0;
        textViewFrame.size.width -= lineNumWidth;
        
        textView.frame = textViewFrame;
        
        self.mainTextView = textView;
        
        // Init line num view
        UITextView *numTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, textViewFrame.size.width, textViewFrame.size.height)];
        numTextView.editable = NO;
        numTextView.font = textView.font;
        numTextView.userInteractionEnabled = NO;
        numTextView.autoresizingMask = textView.autoresizingMask;
        numTextView.textColor = [UIColor whiteColor];
        numTextView.backgroundColor = [UIColor grayColor];
        
        self.numTextView = numTextView;
        
        // Info
        UILabel *infoLabel = [[UILabel alloc] init];
        NSString *maxInfo = [NSString stringWithFormat:INFO_FORMAT, 999, 999, 999, 999];
        infoLabel.text = maxInfo;
        _infoLabel.font = [UIFont fontWithName:[textView.font fontName] size:textView.font.pointSize];
        [_infoLabel sizeToFit];
        _infoLabel.font = [UIFont fontWithName:[textView.font fontName] size:textView.font.pointSize - 2.0f];
        infoLabel.textAlignment = UITextAlignmentCenter;
        infoLabel.frame = CGRectMake(self.bounds.size.width - infoLabel.frame.size.width, self.bounds.size.height - infoLabel.frame.size.height - 44, infoLabel.frame.size.width, infoLabel.frame.size.height);
        infoLabel.backgroundColor = [UIColor blackColor];
        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.layer.opacity = INFO_OPACITY_MAX;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInfoAction:)];
        infoLabel.userInteractionEnabled = YES;
        [infoLabel addGestureRecognizer:tapRecognizer];
        
        self.infoLabel = infoLabel;
        
        // Add subviews and set properties
        [self addSubview:numTextView];
        [self addSubview:textView];
        [self addSubview:infoLabel];
        
        // Delegate
        self.originalDelegate = textView.delegate;
        textView.delegate = self;
        
        // Set default to properties
        _hasInfo = YES;
        _hasNum = YES;
        [self _updateInfo];
        
        self.hasInfo = NO;
        self.hasInfo = YES;
        self.hasNum = NO;
        self.hasNum = YES;
        
#if !__has_feature(objc_arc)
        [numTextView release];
        [infoLabel release];
        [tapRecognizer release];
#endif
        
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

# pragma mark - Actions

- (void)tapInfoAction:(id)sender {
    
    float opacity = _infoLabel.layer.opacity;
    float newOpacity = opacity;
    
    if (opacity == INFO_OPACITY_MAX) {
        newOpacity = INFO_OPACITY_MIN;
    } else if (opacity == INFO_OPACITY_MIN) {
        newOpacity = INFO_OPACITY_MAX;
    }
    
    if (opacity != newOpacity) {
        [UIView animateWithDuration:0.3 animations:^{
            _infoLabel.layer.opacity = newOpacity;
        }];
    }
}

# pragma mark - Properties

- (void)setHasInfo:(BOOL)hasInfo {
    _hasInfo = hasInfo;
    _infoLabel.hidden = !hasInfo;
}

- (void)setHasNum:(BOOL)hasNum {
    _hasNum = hasNum;
    _numTextView.hidden = !hasNum;
    
    if (_hasNum) {
        NSString *maxLineNum = MAX_LINE_NUM;
        float lineNumWidth = [maxLineNum sizeWithFont:_mainTextView.font].width;
        
        _mainTextView.frame = CGRectMake(lineNumWidth, 0, self.bounds.size.width - lineNumWidth, _mainTextView.frame.size.height);
    } else {
        _mainTextView.frame = CGRectMake(0, 0, self.bounds.size.width, _mainTextView.frame.size.height);
    }
}

# pragma mark - UITextViewDelegate

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    if (_hasInfo) {
        [self _updateInfo];
    }
    
    if ([_originalDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
        [_originalDelegate textViewDidChangeSelection:textView];
    }
    
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (_hasNum) {
        
        NSMutableString *text = [NSMutableString stringWithString:textView.text];
        
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^.*$" options:NSRegularExpressionAnchorsMatchLines error:nil];
        NSArray *results = [regexp matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        NSInteger offset = 0;
        
        
        for (int i = 0; i < results.count; i++) {
            NSTextCheckingResult *result = [results objectAtIndex:i];
            
            NSRange resultRange = [result range];
            resultRange.location += offset;
            
            NSMutableString *spacer = [NSMutableString stringWithString:@""];
            
            if (resultRange.length > 0) {
                for (int j = 0; j < resultRange.length - 1; j++) {
                    if (j < 3) continue;
                    NSString *s = [text substringWithRange:NSMakeRange(resultRange.location + j, 1)];
                    if ([self _isHalfChar:s]) {
                        [spacer appendString:@"-"];
                        //[spacer appendString:([self _isSpace:s] ? @" " : @"-")];
                    } else {
                        [spacer appendString:@"ー"];
                        //[spacer appendString:([self _isSpace:s] ? @"　" : @"ー")];
                    }
                }
            }
            
            NSString *space = [self _isHalfChar:[text substringWithRange:resultRange]] ? @"-" : @"ー";
            NSString *replacement = [NSString stringWithFormat:@"%03d%@%@", i + 1, space, spacer];
            
            //[regexp replacementStringForResult:result inString:text offset:offset template:replacement];
            [text replaceCharactersInRange:resultRange withString:replacement];
            
            offset += ([replacement length] - resultRange.length);
        }
        
        _numTextView.text = [NSString stringWithString:text];
    }
    
    if (_hasInfo) {
        [self _updateInfo];
    }
    
    if ([_originalDelegate respondsToSelector:@selector(textViewDidChange:)]) {
        [_originalDelegate textViewDidChange:textView];
    }
}

# pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_hasNum) {
        _numTextView.contentOffset = _mainTextView.contentOffset;
    }
    
    if ([_originalDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_originalDelegate scrollViewDidScroll:scrollView];
    }
}

# pragma mark - Private methods

- (void)_updateInfo {
    
    int selectedLocation = _mainTextView.selectedRange.location;
    NSString *allText = _mainTextView.text;
    
    if (allText.length < 1 || selectedLocation > allText.length) {
        _infoLabel.text = [NSString stringWithFormat:INFO_FORMAT, 0, 0, 0, 0];
        return;
    }
    
    NSString *beforeText = [allText substringToIndex:selectedLocation];
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\n" options:0 error:nil];
    int beforeLines = [regexp matchesInString:beforeText options:0 range:NSMakeRange(0, beforeText.length)].count + 1;
    int allLines = [regexp matchesInString:allText options:0 range:NSMakeRange(0, allText.length)].count + 1;
    
    regexp = [NSRegularExpression regularExpressionWithPattern:@"^.*$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    NSArray *results = [regexp matchesInString:allText options:0 range:NSMakeRange(0, allText.length)];
    
    int beforeChars = 0;
    int allChars = 0;
    
    for (NSTextCheckingResult *result in results) {
        int location = [result range].location;
        int length = [result range].length;
        if (location <= selectedLocation && location + length >= selectedLocation) {
            beforeChars = beforeText.length - location;
            allChars = length;
        }
    }
    
    _infoLabel.text = [NSString stringWithFormat:INFO_FORMAT, beforeLines, allLines, beforeChars, allChars];
}

- (BOOL)_isHalfChar:(NSString *)string {
    NSRange match = [string rangeOfString:@"[一-龠々〆ヵヶ]+|[ぁ-ん]+|[ァ-ヴー]+|[ａ-ｚＡ-Ｚ０-９]+|[、。！？（）「」『』]" options:NSRegularExpressionSearch];
    return match.location == NSNotFound;
}

- (BOOL)_isSpace:(NSString *)string {
    NSRange match = [string rangeOfString:@"\\s|　" options:NSRegularExpressionSearch];
    return match.location != NSNotFound;
}


# pragma mark - Public methods

- (void)updateFrame:(CGRect)frame {
    _mainTextView.frame = frame;
    
    CGRect numRect = _numTextView.frame;
    numRect.size.height = _mainTextView.frame.size.height;
    _numTextView.frame = numRect;
    
    CGRect infoRect = _infoLabel.frame;
    infoRect.origin.y = frame.size.height - infoRect.size.height;
    _infoLabel.frame = infoRect;

    [self textViewDidChange:_mainTextView];
}

- (void)syncStyle {
    _numTextView.font = _mainTextView.font;
    
    NSString *maxLineNum = MAX_LINE_NUM;
    float lineNumWidth = [maxLineNum sizeWithFont:_mainTextView.font].width;
    
    _mainTextView.frame = CGRectMake(lineNumWidth, 0, self.bounds.size.width - lineNumWidth, _mainTextView.frame.size.height);
    
    float size = _mainTextView.font.pointSize;
    NSString *name = [_mainTextView.font fontName];
    _infoLabel.font = [UIFont fontWithName:name size:size];
    [_infoLabel sizeToFit];
    _infoLabel.font = [UIFont fontWithName:name size:size - 2.0f];
    _infoLabel.frame = CGRectMake(self.bounds.size.width - _infoLabel.frame.size.width, self.bounds.size.height - _infoLabel.frame.size.height - 44, _infoLabel.frame.size.width, _infoLabel.frame.size.height);

    [self textViewDidChange:_mainTextView];
}

@end
