//
//  CAImportViewController.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CAImportViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CAProject.h"
#import "CAUtil.h"


@interface CAImportViewController () {
    int downloads;
    int downloaded;
}

@property (nonatomic, retain) UIScrollView *scrollView;

@property (nonatomic, retain) UIView *htmlView;
@property (nonatomic, retain) UITextField *htmlField;
@property (nonatomic, retain) UILabel *htmlLabel;
@property (nonatomic, retain) UILabel *htmlErrorLabel;

@property (nonatomic, retain) UIView *cssView;
@property (nonatomic, retain) UITextField *cssField;
@property (nonatomic, retain) UILabel *cssLabel;
@property (nonatomic, retain) UILabel *cssErrorLabel;

@property (nonatomic, retain) UIView *jsView;
@property (nonatomic, retain) UITextField *jsField;
@property (nonatomic, retain) UILabel *jsLabel;
@property (nonatomic, retain) UILabel *jsErrorLabel;

@property (nonatomic, retain) UIButton *importButton;

@end

@implementation CAImportViewController

@synthesize project = _project;
@synthesize delegate = _delegate;
@synthesize scrollView = _scrollView;

@synthesize htmlView = _htmlView;
@synthesize htmlField = _htmlField;
@synthesize htmlLabel = _htmlLabel;
@synthesize htmlErrorLabel = _htmlErrorLabel;

@synthesize cssView = _cssView;
@synthesize cssField = _cssField;
@synthesize cssLabel = _cssLabel;
@synthesize cssErrorLabel = _cssErrorLabel;

@synthesize jsView = _jsView;
@synthesize jsField = _jsField;
@synthesize jsLabel = _jsLabel;
@synthesize jsErrorLabel = _jsErrorLabel;

@synthesize importButton = _importButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Bar Style
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.navigationController.toolbar.barStyle = UIBarStyleBlackOpaque;
    }
    
    // Init NavigationBar
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = doneButton;
    

    self.scrollView = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scrollView];
    
    self.title = @"Import from Web";
    
    int margin = 5;
    
    self.htmlLabel = [[[UILabel alloc] initWithFrame:CGRectMake(margin, margin, 0, 0)] autorelease];
    _htmlLabel.text = @"HTML";
    [_htmlLabel sizeToFit];
    
    self.htmlErrorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(_htmlLabel.frame.size.width + 10, margin, _scrollView.bounds.size.width - _htmlLabel.frame.size.width, _htmlLabel.frame.size.height)] autorelease];
    
    self.htmlField = [[[UITextField alloc] initWithFrame:CGRectMake(margin, _htmlLabel.frame.size.height + margin * 2, _scrollView.bounds.size.width - margin * 2 * 2, 31)] autorelease];
    _htmlField.borderStyle = UITextBorderStyleLine;
    _htmlField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _htmlField.keyboardType = UIKeyboardTypeURL;
    _htmlField.returnKeyType = UIReturnKeyDone;
    _htmlField.autocorrectionType = UITextAutocorrectionTypeNo;
    _htmlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _htmlField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _htmlField.text = _htmlField.placeholder = @"http://";
    _htmlField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _htmlField.delegate = self;
    _htmlField.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    self.htmlView = [[[UIView alloc] initWithFrame:CGRectMake(margin, margin, _scrollView.bounds.size.width - margin * 2, _htmlField.frame.size.height + _htmlLabel.frame.size.height + margin * 3)] autorelease];
    _htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //_htmlView.backgroundColor = [UIColor grayColor];
    //_htmlView.layer.borderColor = [UIColor blackColor].CGColor;
    //_htmlView.layer.borderWidth = 1.0f;
    //_htmlView.layer.cornerRadius = 5.0f;
    
    
    self.cssLabel = [[[UILabel alloc] initWithFrame:CGRectMake(margin, margin, 0, 0)] autorelease];
    _cssLabel.text = @"CSS";
    [_cssLabel sizeToFit];
    
    self.cssErrorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(_cssLabel.frame.size.width + 10, margin, _scrollView.bounds.size.width - _cssLabel.frame.size.width, _cssLabel.frame.size.height)] autorelease];

    self.cssField = [[[UITextField alloc] initWithFrame:CGRectMake(margin, _cssLabel.frame.size.height + margin * 2, _scrollView.bounds.size.width - margin * 2 * 2, 31)] autorelease];
    _cssField.borderStyle = UITextBorderStyleLine;
    _cssField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _cssField.keyboardType = UIKeyboardTypeURL;
    _cssField.returnKeyType = UIReturnKeyDone;
    _cssField.autocorrectionType = UITextAutocorrectionTypeNo;
    _cssField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _cssField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _cssField.text = _cssField.placeholder = @"http://";
    _cssField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _cssField.delegate = self;
    _cssField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.cssView = [[[UIView alloc] initWithFrame:CGRectMake(margin, _htmlView.frame.size.height + margin * 2, _scrollView.bounds.size.width - margin * 2, _cssField.frame.size.height + _cssLabel.frame.size.height + margin * 3)] autorelease];
    _cssView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //_cssView.backgroundColor = [UIColor grayColor];


    self.jsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(margin, margin, 0, 0)] autorelease];
    _jsLabel.text = @"JS";
    [_jsLabel sizeToFit];
    
    self.jsErrorLabel = [[[UILabel alloc] initWithFrame:CGRectMake(_jsLabel.frame.size.width + margin * 2, margin, _scrollView.bounds.size.width - _jsLabel.frame.size.width, _jsLabel.frame.size.height)] autorelease];

    self.jsField = [[[UITextField alloc] initWithFrame:CGRectMake(margin, _jsLabel.frame.size.height + margin * 2, _scrollView.bounds.size.width - margin * 2 * 2, 31)] autorelease];
    _jsField.borderStyle = UITextBorderStyleLine;
    _jsField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _jsField.keyboardType = UIKeyboardTypeURL;
    _jsField.returnKeyType = UIReturnKeyDone;
    _jsField.autocorrectionType = UITextAutocorrectionTypeNo;
    _jsField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _jsField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _jsField.text = _jsField.placeholder = @"http://";
    _jsField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _jsField.delegate = self;
    _jsField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.jsView = [[[UIView alloc] initWithFrame:CGRectMake(margin, _htmlView.frame.size.height + _cssView.frame.size.height + margin * 3, _scrollView.bounds.size.width - margin * 2, _jsField.frame.size.height + _jsLabel.frame.size.height + margin * 3)] autorelease];
    _jsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //_jsView.backgroundColor = [UIColor grayColor];
    
    self.importButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_importButton setTitle:@"Download" forState:UIControlStateNormal];
    [_importButton setImage:[UIImage imageNamed:@"arrow_down_24.png"] forState:UIControlStateNormal];
    [_importButton sizeToFit];
    _importButton.frame = CGRectMake(0, _htmlView.frame.size.height + _cssView.frame.size.height + _jsView.frame.size.height + margin * 5, _importButton.frame.size.width + margin * 3, _importButton.frame.size.height + margin * 2);
    [_importButton addTarget:self action:@selector(importAction:) forControlEvents:UIControlEventTouchUpInside];
    _importButton.center = CGPointMake(_scrollView.center.x, _importButton.center.y);
    
    [_importButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_importButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _importButton.imageEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    _importButton.titleEdgeInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    _importButton.layer.borderColor = [UIColor blackColor].CGColor;
    _importButton.layer.borderWidth = 1.0f;
    _importButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [_htmlView addSubview:_htmlLabel];
    [_htmlView addSubview:_htmlField];
    [_htmlView addSubview:_htmlErrorLabel];
    
    [_cssView addSubview:_cssLabel];
    [_cssView addSubview:_cssField];
    [_cssView addSubview:_cssErrorLabel];

    [_jsView addSubview:_jsLabel];
    [_jsView addSubview:_jsField];
    [_jsView addSubview:_jsErrorLabel];

    [_scrollView addSubview:_htmlView];
    [_scrollView addSubview:_cssView];
    [_scrollView addSubview:_jsView];
    [_scrollView addSubview:_importButton];

    LOG(@"view frame %f, %f", self.view.frame.size.width, self.view.frame.size.height);
    LOG(@"scroll frame %f, %f", _scrollView.frame.size.width, _scrollView.frame.size.height);
    LOG(@"html frame %f, %f", _htmlView.frame.size.width, _htmlView.frame.size.height);
    _scrollView.contentSize = CGSizeMake(0, _importButton.frame.origin.y + _importButton.frame.size.height + self.navigationController.navigationBar.frame.size.height + margin * 2);

    // restore url
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *projectDic = [userDefaults objectForKey:_project.identifier];
    if (projectDic) {
        NSDictionary *importUrls = [projectDic objectForKey:kCAKeyImportUrls];
        NSString *htmlUrl = [importUrls objectForKey:kCAKeyImportHtml];
        if (htmlUrl) {
            _htmlField.text = htmlUrl;
        }
        NSString *cssUrl = [importUrls objectForKey:kCAKeyImportCss];
        if (cssUrl) {
            _cssField.text = [importUrls objectForKey:kCAKeyImportCss];            
        }
        NSString *jsUrl = [importUrls objectForKey:kCAKeyImportJs];
        if (jsUrl) {
            _jsField.text = jsUrl;
        }
    }
    
    // avoid height bug after show keyboard in webview
    if ([CAUtil isIOS4]) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [_htmlField becomeFirstResponder];
        }
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.scrollView = nil;
    
    self.htmlView = nil;
    self.htmlField = nil;
    self.htmlLabel = nil;
    self.htmlErrorLabel = nil;
    
    self.cssView = nil;
    self.cssField = nil;
    self.cssLabel = nil;
    self.cssErrorLabel = nil;
    
    self.jsView = nil;
    self.jsField = nil;
    self.jsLabel = nil;
    self.jsErrorLabel = nil;
}

- (void)dealloc {
    
    _project = nil;
    _delegate = nil;
    
    _htmlView = nil;
    _htmlField = nil;
    _htmlLabel = nil;
    _htmlErrorLabel = nil;

    _cssView = nil;
    _cssField = nil;
    _cssLabel = nil;
    _cssErrorLabel = nil;
    
    _jsView = nil;
    _jsField = nil;
    _jsLabel = nil;
    _jsErrorLabel = nil;
    
    [_scrollView release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center;
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(projectDidFinishImportHtml:) 
                   name:CAProjectDidFinishImportHtml object:nil];    
    [center addObserver:self selector:@selector(projectDidFinishImportCss:) 
                   name:CAProjectDidFinishImportCss object:nil];    
    [center addObserver:self selector:@selector(projectDidFinishImportJs:) 
                   name:CAProjectDidFinishImportJs object:nil];    

    [center addObserver:self selector:@selector(projectDidFailImportHtml:) 
                   name:CAProjectDidFailImportHtml object:nil];    
    [center addObserver:self selector:@selector(projectDidFailImportCss:) 
                   name:CAProjectDidFailImportCss object:nil];    
    [center addObserver:self selector:@selector(projectDidFailImportJs:) 
                   name:CAProjectDidFailImportJs object:nil];    

    // Bar Style
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUIKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUIKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
        
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /*
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
     return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
     } else {
     return YES;
     }
     */
    return YES;
}

# pragma mark - Button Actions

- (void)doneAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(importControllerDidSave:)]) {
        [_delegate importControllerDidSave:self];
    }
}

- (void)importAction:(id)sender {

    
    [self _clear:_htmlErrorLabel];
    [self _clear:_cssErrorLabel];
    [self _clear:_jsErrorLabel];
    
    [_htmlField resignFirstResponder];
    [_cssField resignFirstResponder];
    [_jsField resignFirstResponder];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *projectDic = [[[userDefaults objectForKey:_project.identifier] mutableCopy] autorelease];
    NSMutableDictionary *importUrls = [[[projectDic objectForKey:kCAKeyImportUrls] mutableCopy] autorelease];
    if (!projectDic) {
        importUrls = [NSMutableDictionary dictionary];
        projectDic = [NSMutableDictionary dictionaryWithObject:importUrls forKey:kCAKeyImportUrls];
    }
    if (!importUrls) {
        importUrls = [NSMutableDictionary dictionary];
        [projectDic setObject:importUrls forKey:kCAKeyImportUrls];
    }
    [projectDic setObject:importUrls forKey:kCAKeyImportUrls];

    NSString *htmlUrl = _htmlField.text;    
    if (htmlUrl.length > 7) {
        [_project importHtml:htmlUrl];
        downloads += 1;
        [importUrls setObject:htmlUrl forKey:kCAKeyImportHtml];
    }
    
    NSString *cssUrl = _cssField.text;    
    if (cssUrl.length > 7) {
        [_project importCss:cssUrl];
        downloads += 1;
        [importUrls setObject:cssUrl forKey:kCAKeyImportCss];
    }

    NSString *jsUrl = _jsField.text;    
    if (jsUrl.length > 7) {
        [_project importJs:jsUrl];
        downloads += 1;
        [importUrls setObject:jsUrl forKey:kCAKeyImportJs];
    }

    if (downloads > 0) {
        [userDefaults setObject:projectDic forKey:_project.identifier];
        [self _loading:YES];
    }
}

# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

# pragma mark - Utility

- (void)_loading:(BOOL)isLoading {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = isLoading;
    self.navigationItem.rightBarButtonItem.enabled = !isLoading;
}

# pragma mark - CAProject Notifications

- (void)projectDidFinishImportHtml:(NSNotification*)notification
{
    CAProject *project = [[notification userInfo] objectForKey:@"project"];
    
    if (project == _project) {
        LOG(@"done html import");
        [self _success:_htmlErrorLabel];
    }

    [self _downloaded];
}

- (void)projectDidFinishImportCss:(NSNotification*)notification
{
    CAProject *project = [[notification userInfo] objectForKey:@"project"];
    
    if (project == _project) {
        LOG(@"done css import");
        [self _success:_cssErrorLabel];
    }
    
    [self _downloaded];
}

- (void)projectDidFinishImportJs:(NSNotification*)notification
{
    CAProject *project = [[notification userInfo] objectForKey:@"project"];
    
    if (project == _project) {
        LOG(@"done css import");
        [self _success:_jsErrorLabel];
    }
    
    [self _downloaded];
}

- (void)projectDidFailImportHtml:(NSNotification*)notification
{
    CAProject *project = [[notification userInfo] objectForKey:@"project"];
    
    if (project == _project) {
        LOG(@"fail html import");
        [self _error:_htmlErrorLabel];
    }
    
    [self _downloaded];
}

- (void)projectDidFailImportCss:(NSNotification*)notification
{
    CAProject *project = [[notification userInfo] objectForKey:@"project"];
    
    if (project == _project) {
        LOG(@"fail css import");
        [self _error:_cssErrorLabel];
    }
    
    [self _downloaded];
}

- (void)projectDidFailImportJs:(NSNotification*)notification
{
    CAProject *project = [[notification userInfo] objectForKey:@"project"];
    
    if (project == _project) {
        LOG(@"fail css import");
        [self _error:_jsErrorLabel];
    }
    
    [self _downloaded];
}

- (void)_downloaded {
    if (++downloaded >= downloads) {
        [self _loading:NO];
        downloads = 0;
        //[self doneAction:nil];
    }    
}

- (void)_error:(UILabel *)label {
    label.text = @"Error";
    label.textColor = [UIColor redColor];
}

- (void)_success:(UILabel *)label {
    label.text = @"OK";
    label.textColor = [UIColor greenColor];
}

- (void)_clear:(UILabel *)label {
    label.text = @"";
    label.textColor = [UIColor blackColor];
}

# pragma mark -- Keyboard Notifications

- (void)onUIKeyboardWillShowNotification:(NSNotification *)notification
{
    
    //float beginHeight;
    float endHeight;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            //beginHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
            endHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            //beginHeight = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.width;
            endHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
            break;
    }
    
    CGRect scrollFrame = _scrollView.frame;
    scrollFrame.size.height = self.view.frame.size.height - endHeight + self.navigationController.toolbar.frame.size.height;    
    
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration
                     animations:^{
                         _scrollView.frame = scrollFrame;
                     }];
}

- (void)onUIKeyboardWillHideNotification:(NSNotification *)notification
{
    //float endHeight;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            //endHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            //endHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
            break;
    }
    
    CGRect scrollFrame = _scrollView.frame;
    scrollFrame.size.height = self.view.frame.size.height;    
    
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration
                     animations:^{
                         _scrollView.frame = scrollFrame;
                     }];
    
}


@end
