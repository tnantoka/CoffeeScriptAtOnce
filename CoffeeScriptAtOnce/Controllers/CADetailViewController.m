//
//  CADetailViewController.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CADetailViewController.h"

#import "CAUtil.h"
#import "CAProject.h"
#import "CAProjectManager.h"
#import "CALogsViewController.h"
#import "AccessoryTextView.h"
#import "CAImportViewController.h"

#import "ZKFileArchive.h"

#import "SBJson.h"

#import "SFHFKeychainUtils.h"

#import <QuartzCore/QuartzCore.h>

#import "BNLineNumbersTextView.h"

#import "CASourceViewController.h"

enum {
    CADetailTagHtmlView,  
    CADetailTagCssView,  
    CADetailTagJsView,  
    CADetailTagLibPreview,  
    CADetailTagRunView  
};

typedef enum {
    CADetailActionSheetModeMail,
    CADetailActionSheetModeSource
} CADetailActionSheetMode;

/*
@interface BlackQLPreviewController : QLPreviewController

@end

@implementation BlackQLPreviewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Bar Style
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.navigationController.toolbar.barStyle = UIBarStyleBlackOpaque;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
        LOG(@"colo %d, %d", self.navigationController.navigationBar.barStyle, UIBarStyleBlackOpaque);
    }
    
}

- (void)reloadData {
    [super reloadData];
    [self.navigationController.navigationBar setTintColor:[UIColor redColor]]; 
}

@end
*/

@interface CADetailViewController () {
    int lastSelectedRow;
    BOOL isRan;
    int lastModeIndex;
    CADetailActionSheetMode actionSheetMode;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (nonatomic, retain) UILabel *toolbarLabel;
@property (nonatomic, retain) UISegmentedControl *modeControl;

@property (nonatomic, retain) UIBarButtonItem *reloadItem;
@property (nonatomic, retain) UIBarButtonItem *importItem;
@property (nonatomic, retain) UIBarButtonItem *errorItem;
@property (nonatomic, retain) UIBarButtonItem *mailItem;
@property (nonatomic, retain) UIBarButtonItem *sourceItem;

@property (nonatomic, retain) AccessoryTextView *htmlView;
@property (nonatomic, retain) AccessoryTextView *cssView;
@property (nonatomic, retain) AccessoryTextView *jsView;

@property (nonatomic, retain) UITableView *libView;
@property (nonatomic, retain) UIWebView *runView;

@property (nonatomic, retain) NSArray *modeViews;
@property (nonatomic, retain) NSArray *libs;
@property (nonatomic, retain) UIWebView *libPreview;
//@property (nonatomic, retain) BlackQLPreviewController *qlController;

@property (nonatomic, retain) UITextField *urlField;
@property (nonatomic, retain) UIButton *dlButton;

@property (nonatomic, retain) BNLineNumbersTextView *htmlLineNumView;
@property (nonatomic, retain) BNLineNumbersTextView *jsLineNumView;
@property (nonatomic, retain) BNLineNumbersTextView *cssLineNumView;

- (void)configureView;

@end

@implementation CADetailViewController

@synthesize masterPopoverController = _masterPopoverController;

@synthesize detailItem = _detailItem;
@synthesize modeControl = _modeControl;

@synthesize reloadItem = _reloadItem;
@synthesize importItem = _importItem;
@synthesize errorItem = _errorItem;
@synthesize mailItem = _mailItem;
@synthesize sourceItem = _sourceItem;

@synthesize htmlView = _htmlView;
@synthesize cssView = _cssView;
@synthesize jsView = _jsView;

@synthesize libView = _libView;
@synthesize runView = _runView;

@synthesize modeViews = _modeViews;
@synthesize libs = _libs;
@synthesize libPreview = _libPreview;
//@synthesize qlController = _qlController;

@synthesize urlField = _urlField;
@synthesize dlButton = _dlButton;

@synthesize toolbarLabel = _toolbarLabel;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];

        // Update the view.
        //[self configureView];
        
    }
    
    [self configureView];

    //if (_detailItem) { // for prevent crash when appear popover(set detail to nil) on ipad portrait 
        if (self.masterPopoverController != nil) {
            [self.masterPopoverController dismissPopoverAnimated:YES];
        }
    //}
    
    
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        [self _makeEnableView:YES];
        [self _loadFiles];
        [self _showView:0];
        [self _updateDoneButton];
        
        // Apply settings of interface
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        UIColor *textColor = [CAUtil color:[userDefaults integerForKey:kCAKeySettingTextColor]];
        UIColor *bgColor = [CAUtil color:[userDefaults integerForKey:kCAKeySettingBgColor]];
        
        NSString *fontName = [CAUtil fontName:[userDefaults integerForKey:kCAKeySettingFontName]];
        NSString *fontSize = [CAUtil fontSize:[userDefaults integerForKey:kCAKeySettingFontSize]];
        
        _htmlView.backgroundColor = bgColor;
        _cssView.backgroundColor = bgColor;
        _jsView.backgroundColor = bgColor;
        
        _htmlView.textColor = textColor;
        _cssView.textColor = textColor;
        _jsView.textColor = textColor;
        
        UIFont *font = [UIFont fontWithName:fontName size:[fontSize floatValue]];
        _htmlView.font = font;
        _cssView.font = font;
        _jsView.font = font;
        [_htmlLineNumView syncStyle];
        [_cssLineNumView syncStyle];
        [_jsLineNumView syncStyle];
        
        _dlButton.enabled = YES;
        
        NSString *userKeys = [userDefaults objectForKey:kCAKeySettingCustomKeys];
        [_htmlView setUserKeys:userKeys];
        [_cssView setUserKeys:userKeys];
        [_jsView setUserKeys:userKeys];

        // Must do after userKeys
        BOOL isCustomKeyboard = [userDefaults boolForKey:kCAKeySettingIsCustomKeyboard];
        LOG(@"isCustomKeyboard %d", isCustomKeyboard);
        [_htmlView hideAccessory:!isCustomKeyboard];
        [_cssView hideAccessory:!isCustomKeyboard];
        [_jsView hideAccessory:!isCustomKeyboard];
        
        BOOL isLineNums = [userDefaults boolForKey:kCAKeySettingIsLineNums];
        _htmlLineNumView.hasNum = isLineNums;
        _cssLineNumView.hasNum = isLineNums;
        _jsLineNumView.hasNum = isLineNums;

        BOOL isLineInfo = [userDefaults boolForKey:kCAKeySettingIsLineInfo];
        _htmlLineNumView.hasInfo = isLineInfo;
        _cssLineNumView.hasInfo = isLineInfo;
        _jsLineNumView.hasInfo = isLineInfo;

    } else {
        [self _makeEnableView:NO];
    }
    
}

- (void)_makeEnableView:(BOOL)enable {

    if (enable) {
        _toolbarLabel.text = [_detailItem description];
    } else {
        _toolbarLabel.text = @"";
    }
    
    _modeControl.enabled = enable;
    _modeControl.userInteractionEnabled = enable; // for disable tap on iPad
    self.navigationItem.rightBarButtonItem.enabled = enable;
    
    _reloadItem.enabled = enable;
    _importItem.enabled = enable;
    _errorItem.enabled = enable;
    //_sourceItem.enabled = enable;
    _sourceItem.enabled = NO;
    _mailItem.enabled = enable;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.libs = [NSArray array];

    // Init Mode Segmented Control
    self.modeControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                 @"HTM", 
                                                                                 @"CSS", 
                                                                                 @"JS", 
//                                                                                 @"LIB", 
                                                                                 @"EXT", 
                                                                                 @"RUN",
                                                                                 nil]] autorelease];
    _modeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    _modeControl.selectedSegmentIndex = 0;
    
    // Doesn't work on iOS4 and this setting is no longer must
    //UIFont *Boldfont = [UIFont boldSystemFontOfSize:12.0f];
    //NSDictionary *attributes = [NSDictionary dictionaryWithObject:Boldfont forKey:UITextAttributeFont];
    //[_modeControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    self.navigationItem.titleView = _modeControl;
    [_modeControl addTarget:self action:@selector(modeAction:) forControlEvents:UIControlEventValueChanged];
    
    // Init NavigationBar
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // Init Toolbar 
    self.reloadItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadAction:)] autorelease];
    self.importItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"inbox_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(importAction:)] autorelease];
    self.errorItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"console_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(errorAction:)] autorelease];
    self.mailItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_plane_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(mailAction:)] autorelease];
    self.sourceItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"document_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(sourceAction:)] autorelease];

    UIBarButtonItem *flexibleItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

    NSString *maxString;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        maxString = @"123456789012345";
    } else {
        maxString = @"12345678901234567890123456789";        
    }
        
    CGSize labelSize = [maxString sizeWithFont:[UIFont boldSystemFontOfSize:16]];
    self.toolbarLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,labelSize.width,labelSize.height)] autorelease];
    _toolbarLabel.backgroundColor = [UIColor clearColor];
    //_toolbarLabel.backgroundColor = [UIColor redColor];
    _toolbarLabel.font = [UIFont boldSystemFontOfSize:16];
    _toolbarLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _toolbarLabel.textColor = [UIColor whiteColor];
        _toolbarLabel.shadowColor = [UIColor blackColor];
        _toolbarLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    } else {
        _toolbarLabel.textColor = [UIColor colorWithRed:0x71/255.0 green:0x78/255.0 blue:0x80/255.0 alpha:1.0];
        _toolbarLabel.shadowColor = [UIColor colorWithRed:0xe6/255.0 green:0xe7/255.0 blue:0xeb/255.0 alpha:1.0];
        _toolbarLabel.shadowOffset = CGSizeMake(0, 1);
    }
    
    UIBarButtonItem *buttonTitle = [[[UIBarButtonItem alloc] initWithCustomView:_toolbarLabel] autorelease];
    
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             buttonTitle,
                             flexibleItem,
                             _importItem,
                             _reloadItem,
                             _sourceItem,
                             _errorItem,
                             _mailItem, 
                             nil];
    [self setToolbarItems:toolbarItems animated:NO];
    
    self.htmlView = [[[AccessoryTextView alloc] initWithFrame:self.view.bounds] autorelease];
    _htmlView.autocorrectionType = UITextAutocorrectionTypeNo;
    _htmlView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _htmlView.keyboardAppearance = UIKeyboardAppearanceAlert;
    _htmlView.tag = CADetailTagHtmlView;
    _htmlView.delegate = self;
    _htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //[self.view addSubview:_htmlView];
    self.htmlLineNumView = [[[BNLineNumbersTextView alloc] initWithTextView:_htmlView ] autorelease];
    [self.view addSubview:_htmlLineNumView];

    self.cssView = [[[AccessoryTextView alloc] initWithFrame:self.view.bounds] autorelease];
    _cssView.autocorrectionType = UITextAutocorrectionTypeNo;
    _cssView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _cssView.keyboardAppearance = UIKeyboardAppearanceAlert;
    _cssView.tag = CADetailTagCssView;
    _cssView.delegate = self;
    _cssView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //[self.view addSubview:_cssView];
    self.cssLineNumView = [[[BNLineNumbersTextView alloc] initWithTextView:_cssView ] autorelease];
    [self.view addSubview:_cssLineNumView];
    
    self.jsView = [[[AccessoryTextView alloc] initWithFrame:self.view.bounds] autorelease];
    _jsView.autocorrectionType = UITextAutocorrectionTypeNo;
    _jsView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _jsView.keyboardAppearance = UIKeyboardAppearanceAlert;
    _jsView.tag = CADetailTagJsView;
    _jsView.delegate = self;
    _jsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //[self.view addSubview:_jsView];
    self.jsLineNumView = [[[BNLineNumbersTextView alloc] initWithTextView:_jsView ] autorelease];
    [self.view addSubview:_jsLineNumView];
     
    self.libView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] autorelease];
    _libView.dataSource = self;
    _libView.delegate = self;
    _libView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:_libView];

    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DummyCell"] autorelease];

    int buttonWidth = 30;

    //self.urlField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width - paddingSize.width - buttonWidth, cell.frame.size.height)];
    self.urlField = [[[UITextField alloc] initWithFrame:CGRectMake(5, 5, cell.frame.size.width - buttonWidth - 5, 31)] autorelease];
    //_urlField.backgroundColor = [UIColor redColor];
    _urlField.borderStyle = UITextBorderStyleLine;
    _urlField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _urlField.keyboardType = UIKeyboardTypeURL;
    _urlField.returnKeyType = UIReturnKeyDone;
    _urlField.autocorrectionType = UITextAutocorrectionTypeNo;
    _urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _urlField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _urlField.text = _urlField.placeholder = @"http://";
    _urlField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _urlField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _urlField.delegate = self;
        
    self.dlButton = [[[UIButton alloc] initWithFrame:CGRectMake(_urlField.frame.size.width + 5, 0, buttonWidth, cell.frame.size.height)] autorelease];
    _dlButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    //[_dlButton setTitle:@"dl" forState:UIControlStateNormal];
    [_dlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_dlButton setImage:[UIImage imageNamed:@"arrow_down_24.png"] forState:UIControlStateNormal];
    [_dlButton addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *downloadView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)] autorelease];
    downloadView.backgroundColor = [UIColor clearColor];
    
    [downloadView addSubview:_dlButton];
    [downloadView addSubview:_urlField];

    [_libView setTableFooterView:downloadView];

    self.libPreview = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
    _libPreview.tag = CADetailTagLibPreview;
    _libPreview.delegate = self;
    _libPreview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:_libPreview];
    
    /*
    _qlController = [[BlackQLPreviewController alloc] init];
    _qlController.dataSource = self;
    _qlController.delegate = self;
     */
     
    self.runView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
    _runView.tag = CADetailTagRunView;
    _runView.delegate = self;
    _runView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_runView];

    self.modeViews = [NSArray arrayWithObjects:
                      _htmlView,
                      _cssView,  
                      _jsView,  
                      _libView,  
                      _runView,  
                      nil];
    
    
    [self configureView];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.modeControl = nil;
    self.toolbarLabel = nil;
    
    self.importItem = nil;
    self.errorItem = nil;
    self.mailItem = nil;
    self.sourceItem = nil;
    
    self.htmlView = nil;
    self.cssView = nil;
    self.jsView = nil;
    
    self.libView = nil;
    self.runView = nil;
    
    self.modeViews = nil;
    self.libs = nil;
    self.libPreview = nil;
    //self.qlController = nil;
    
    self.urlField = nil;
    self.dlButton = nil;
    
    self.htmlLineNumView = nil;
    self.jsLineNumView = nil;
    self.cssLineNumView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)dealloc
{
    [_detailItem release];
    [_masterPopoverController release];
    
    [_modeControl release];
    [_toolbarLabel release];

    [_reloadItem release];
    [_importItem release];
    [_errorItem release];
    [_mailItem release];
    [_sourceItem release];
    
    [_htmlView release];
    [_cssView release];
    [_jsView release];
    
    [_libView release];
    [_runView release];

    [_modeViews release];
    [_libs release];
    [_libPreview release];
    //[_qlController release];
    
    [_urlField release];
    
    [_htmlLineNumView release];
    [_jsLineNumView release];
    [_cssLineNumView release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setToolbarHidden:NO animated:NO];

    // For adjust subview's position
    [_htmlLineNumView updateFrame:_htmlView.frame];
    [_cssLineNumView updateFrame:_cssView.frame];
    [_jsLineNumView updateFrame:_jsView.frame];
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUIKeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUIKeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];

    NSNotificationCenter *center;
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(projectDidFinishAddLib:) 
                   name:CAProjectDidFinishAddLib object:nil];    
    
}

- (void)viewDidAppear:(BOOL)animated {    
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self _resign]; // for adjust height on iPhone
    
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

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
- (id)init
{
    //self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Projects", @"Projects");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    CAProject *project = (CAProject *)_detailItem;

    switch (actionSheetMode) {
        case CADetailActionSheetModeMail:
            switch (buttonIndex) {
                case 0:
                    LOG(@"Send mail");
                    [self _sendMail];
                    break;
                case 1:
                    if (project.gistId) {
                        LOG(@"View gist");
                        [self _viewGist];
                    } else {
                        LOG(@"Post gist (Private)");
                        [self _postGist:NO];
                    }
                    break;
                case 2:
                    if (project.gistId) {
                        LOG(@"Update gist");
                        [self _postGist:NO];
                    } else {
                        LOG(@"Post gist (Public)");
                        [self _postGist:YES];
                    }
                    break;
                case 3:
                    LOG(@"cancel");
                    break;
            }
            break;
        case CADetailActionSheetModeSource:
            switch (buttonIndex) {
                case 0:
                    LOG(@"HTML");
                    [self _viewGeneratedHtml];
                    break;
                case 1:
                    LOG(@"JS");
                    [self _viewCompiledJs];
                    break;
                case 2:
                    LOG(@"cancel");
                    break;
            }
            break;
    }
    
}

# pragma mark - Button Actions

- (void)mailAction:(id)sender {
    
    CAProject *project = (CAProject *)_detailItem;
    
    actionSheetMode = CADetailActionSheetModeMail;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];

    [actionSheet setDelegate:self];
    //[actionSheet setTitle:@"Sending Project"];
    [actionSheet addButtonWithTitle:@"Mail"];

    if (project.gistId) {
        [actionSheet addButtonWithTitle:@"View Gist"];
        [actionSheet addButtonWithTitle:@"Update Gist"];
    } else {
        [actionSheet addButtonWithTitle:@"Gist (Private)"];
        [actionSheet addButtonWithTitle:@"Gist (Public)"];        
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet setCancelButtonIndex:3];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [actionSheet showInView:self.view];
    } else {
        [actionSheet showFromBarButtonItem:sender animated:YES];
    }

    [actionSheet release];    
}

- (void)doneAction:(id)sender {
    [self _resign];
    [self _deselect];
}

- (void)_resign {
    [_htmlView resignFirstResponder];
    [_cssView resignFirstResponder];
    [_jsView resignFirstResponder];    
    
    //[_runView resignFirstResponder]; // Doesn't work
    //[_runView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    if (lastModeIndex == 4) {
        [_urlField becomeFirstResponder]; // for resign _runView
    }
    [_urlField resignFirstResponder];
    
     _libPreview.hidden = YES;
    [_libPreview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
     [self _updateDoneButton];
    
}

- (void)_deselect {
    lastSelectedRow = -1;    
    [_libView deselectRowAtIndexPath:_libView.indexPathForSelectedRow animated:YES];
}


- (void)modeAction:(id)sender {
    LOG(@"%d", _modeControl.selectedSegmentIndex);

    [self _showView:_modeControl.selectedSegmentIndex];
    
    
}

- (void)downloadAction:(id)sender {
    NSString *urlString = _urlField.text;

    if (urlString.length < 1){
        return;
    }
    
    LOG(@"download %@", _urlField.text);
    CAProject *project = (CAProject *)_detailItem;
    [project addLib:urlString];
    
    [self _loading:YES];
    _dlButton.enabled = NO;

    [self _resign];
}

- (void)errorAction:(id)sender {
    
    //[self performSelector:@selector(_showLogs) withObject:nil afterDelay:1.0f];
    [self _showLogs];
}

- (void)_showLogs {
    
    NSString *separator = @"<>";
    
    NSString *logs = [_runView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"csatonce.getLogs('%@')", separator]];
    LOG(@"getLogs: %@", logs);
    
    NSArray *logsArray = [logs componentsSeparatedByString:separator];
    
    if (logsArray.count == 1 && [[logsArray objectAtIndex:0] isEqualToString:@""]) {
        [CAUtil showError:@"No logs."];
        return;
    }
    
    CALogsViewController *logsController = [[[CALogsViewController alloc] init] autorelease];
    logsController.delegate = self;
    logsController.items = logsArray;
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:logsController] autorelease];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navController animated:YES];  
}

- (void)reloadAction:(id)sender {
    //[_runView reload];
    [self _showView:4];
}

- (void)importAction:(id)sender {
    
    CAImportViewController *importController = [[[CAImportViewController alloc] init] autorelease];
    importController.delegate = self;
    importController.project = _detailItem;
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:importController] autorelease];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navController animated:YES];
}

- (void)sourceAction:(id)sender {
    
    CAProject *project = (CAProject *)_detailItem;

    if (!project.isCoffeeScript) {
        [self _viewGeneratedHtml];
    } else {

        actionSheetMode = CADetailActionSheetModeSource;
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        
        [actionSheet setDelegate:self];
        [actionSheet setTitle:@"View Source"];
        [actionSheet addButtonWithTitle:@"Generated HTML"];
        [actionSheet addButtonWithTitle:@"Compiled JS"];
        
        [actionSheet addButtonWithTitle:@"Cancel"];
        [actionSheet setCancelButtonIndex:2];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [actionSheet showInView:self.view];
        } else {
            [actionSheet showFromBarButtonItem:sender animated:YES];
        }
        
        [actionSheet release];    

    }
    

}


# pragma mark - Update View

- (void)_showView:(int)index {

    [self _resign];

    switch (index) {
        case 0:
            _htmlLineNumView.hidden = NO;
            _cssLineNumView.hidden = YES;
            _jsLineNumView.hidden = YES;
            break;
        case 1:
            _htmlLineNumView.hidden = YES;
            _cssLineNumView.hidden = NO;
            _jsLineNumView.hidden = YES;
            break;
        case 2:
            _htmlLineNumView.hidden = YES;
            _cssLineNumView.hidden = YES;
            _jsLineNumView.hidden = NO;
            break;
    }

    for (int i = 0; i < _modeViews.count; i++) {
        UIView *view = [_modeViews objectAtIndex:i];
        if (i == index) {
            view.hidden = NO;

            // avoid view height bug
            if ([CAUtil isIOS4]) {
                [view becomeFirstResponder];
                
                if (i == 3) {
                    [_urlField becomeFirstResponder];
                }
            }
            
        } else {
            view.hidden = YES;
        }
    }
    
    if (_modeControl.selectedSegmentIndex != index) {
        _modeControl.selectedSegmentIndex = index;
    }
    
    // lib
    if (index == 3) {
        [self _deselect];
    } else {
    }
    
    // run
    if (index == 4) {
        //[self.navigationController setToolbarHidden:YES animated:YES];

        [self _loading:YES];

        CAProject *project = (CAProject *)_detailItem;
        NSURLRequest *request = [project build];

        if (isRan) {
            [_runView reload];
        } else {
            [_runView loadRequest:request];
            isRan = YES;
        }
            
        LOG(@"run: %@", request);

        // Compiled JS is require coffeescript.js, so if enable after build once
        _sourceItem.enabled = YES;

    } else {
        //[self.navigationController setToolbarHidden:NO animated:YES];        
    }
    
    _reloadItem.enabled = NO;
    _errorItem.enabled = NO;
    //_sourceItem.enabled = NO;
    
    lastModeIndex = _modeControl.selectedSegmentIndex;

}

- (void)_loadFiles {
    CAProject *project = (CAProject *)_detailItem;

    NSString *htmlContent = [project loadHtml];
    _htmlView.text = htmlContent;
    
    NSString *cssContent = [project loadCss];
    _cssView.text = cssContent;

    NSString *jsContent = [project loadJs];
    _jsView.text = jsContent;

    isRan = NO;
    
    [_runView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];

    [self _updateLibs];
    
    
}

- (void)_updateLibs {
    CAProject *project = (CAProject *)_detailItem;

    NSArray *libs = [project libs];
    LOG(@"libs: %@", libs);
    self.libs = libs;
    
    /*
     for (UITableViewCell* cell in [_libView visibleCells]) {
     [self _updateCell:cell atIndexPath:[_libView indexPathForCell:cell]];
     }
     */
    [_libView reloadData];    
}

- (void)_updateDoneButton {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    
    if (_htmlView.isFirstResponder || _cssView.isFirstResponder || _jsView.isFirstResponder || _urlField.isFirstResponder) {
        return;
    }
    
    
    if (_libPreview.hidden == NO) {
        [self.navigationItem.rightBarButtonItem setTitle:@"Close"];
        return;
    }

    self.navigationItem.rightBarButtonItem.enabled = NO;

}

- (void)_loading:(BOOL)isLoading {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = isLoading;
}


# pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _libs.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    [self _updateCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.    
    // return indexPath.row > 1; // can't remove coffee-script.js, jquery.js
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        LOG(@"delete");
        
        NSString *name = [_libs objectAtIndex:indexPath.row];
        CAProject *project = (CAProject *)_detailItem;
        [project removeLib:name];
        
        [self _updateLibs];        

        return;
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (lastSelectedRow == indexPath.row) {

        NSString *lib = [_libs objectAtIndex:indexPath.row];
        CAProject *project = (CAProject *)_detailItem;
        NSURLRequest *request = [project loadLib:lib];
        LOG(@"libreq: %@, %@", request, _libPreview);    
        [_libPreview loadRequest:request];
        _libPreview.hidden = NO;
        [self _updateDoneButton];
        [self _loading:YES];
        
        /*
        [_qlController reloadData];
        _qlController.currentPreviewItemIndex = indexPath.row;
        [self presentModalViewController:_qlController animated:YES];
         */
    }
    
    lastSelectedRow = indexPath.row;
    
}

# pragma mark - Refresh View

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    cell.textLabel.text = [_libs objectAtIndex:indexPath.row];
}

# pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self _loading:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    CAProject *project = (CAProject *)_detailItem;
    
    if (webView.tag == CADetailTagRunView) {
        
        if (_modeControl.selectedSegmentIndex == 4) {
            if (project.isOnError || project.isConsoleLog) {
                [self performSelector:@selector(_enableErrorItem) withObject:nil afterDelay:1.0f];
            }
        }
        
    } else if (webView.tag == CADetailTagLibPreview) {
        
    }
    
    [self _loading:NO];
}

- (void)_enableErrorItem {
    _reloadItem.enabled = YES;
    _errorItem.enabled = YES;    
    _sourceItem.enabled = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [self _loading:NO];
}

# pragma mark - CAProject Notifications

- (void)projectDidFinishAddLib:(NSNotification*)notification
{
    LOG(@"done add lib");
    
    CAProject *project = [[notification userInfo] objectForKey:@"project"];
    
    if (project == _detailItem) {
        
        [self _updateLibs];        
        
        LOG(@"same");
    }

    _dlButton.enabled = YES;
    [self _loading:NO];
}

# pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    CAProject *project = (CAProject *)_detailItem;
    switch (textView.tag) {
        case CADetailTagHtmlView:
            [project saveHtml:textView.text];
            break;
        case CADetailTagCssView:
            [project saveCss:textView.text];
            break;
        case CADetailTagJsView:
            [project saveJs:textView.text];
            break;
    }
}

# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


# pragma mark - CALogsViewControllerDelegate

- (void)logsControllerDidSave:(CALogsViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

# pragma mark - CAImportViewControllerDelegate

- (void)importControllerDidSave:(CAImportViewController *)controller {
    [self _loadFiles];
    [self _showView:0];
    [self dismissModalViewControllerAnimated:YES];
}

# pragma mark - QLPreviewController
/*
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return _libs.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    
    NSString *lib = [_libs objectAtIndex:index];
    CAProject *project = (CAProject *)_detailItem;
    NSURLRequest *request = [project loadLib:lib];
    
    return request.URL;
}

- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    [self _deselect];        
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
}

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id<QLPreviewItem>)item {
    return NO;
}
*/


# pragma mark - Keyboard Notifications

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
    
    LOG(@"keyboard height %f", endHeight);
    
    CGRect htmlFrame = _htmlView.frame;
    htmlFrame.size.height = self.view.frame.size.height - endHeight + self.navigationController.toolbar.frame.size.height;
    
    CGRect libFrame = _libView.frame;
    libFrame.size.height = self.view.frame.size.height - endHeight + self.navigationController.toolbar.frame.size.height;
    
    if (lastModeIndex < 4) { // for avoid keyboard animation when resign webview by dummy
        NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration
                     animations:^{
                         //_htmlView.frame = htmlFrame;
                         //_cssView.frame = htmlFrame;
                         //_jsView.frame = htmlFrame;
                         [_htmlLineNumView updateFrame:htmlFrame];
                         [_cssLineNumView updateFrame:htmlFrame];
                         [_jsLineNumView updateFrame:htmlFrame];
                         _libView.frame = libFrame;
                     }];
    } else {
        //_htmlView.frame = htmlFrame;
        //_cssView.frame = htmlFrame;
        //_jsView.frame = htmlFrame;
        [_htmlLineNumView updateFrame:htmlFrame];
        [_cssLineNumView updateFrame:htmlFrame];
        [_jsLineNumView updateFrame:htmlFrame];
        _libView.frame = libFrame;
    }
    
    [self _updateDoneButton];
}

- (void)onUIKeyboardWillHideNotification:(NSNotification *)notification
{
    LOG(@"before hide keyboard %f", self.view.frame.size.height);
    
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
    
    CGRect htmlFrame = _htmlView.frame;
    htmlFrame.size.height = self.view.frame.size.height;    
    
    CGRect libFrame = _libView.frame;
    libFrame.size.height = self.view.frame.size.height;
    
    if (lastModeIndex < 4) {
        NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration
                     animations:^{
                         //_htmlView.frame = htmlFrame;
                         //_cssView.frame = htmlFrame;
                         //_jsView.frame = htmlFrame;
                         [_htmlLineNumView updateFrame:htmlFrame];
                         [_cssLineNumView updateFrame:htmlFrame];
                         [_jsLineNumView updateFrame:htmlFrame];
                         _libView.frame = libFrame;
                     }];
    } else {
        //_htmlView.frame = htmlFrame;
        //_cssView.frame = htmlFrame;
        //_jsView.frame = htmlFrame;
        [_htmlLineNumView updateFrame:htmlFrame];
        [_cssLineNumView updateFrame:htmlFrame];
        [_jsLineNumView updateFrame:htmlFrame];
        _libView.frame = libFrame;
    }

    LOG(@"after hide keyboard %f", _htmlView.frame.size.height);

    [self _updateDoneButton];

}

# pragma mark - View Source

- (void)_viewCompiledJs {

    CAProject *project = (CAProject *)_detailItem;

    NSString *escapedJs = [[[project loadJs] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    NSString *buildJs = [_runView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"(function() { try { return CoffeeScript.compile('%@', { bare: false }); } catch (e) { return e.message; } })();", escapedJs]];
    
    //[[[[UIAlertView alloc] initWithTitle:@"Generated HTML Source" message:buildJs delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];

    CASourceViewController *sourceController = [[CASourceViewController alloc] initWithSource:buildJs title:NSLocalizedString(@"Compiled JS", @"") name:project.name];
    sourceController.delegate = self;
    UINavigationController *sourceNavController = [[UINavigationController alloc] initWithRootViewController:sourceController];
    
    sourceNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:sourceNavController animated:YES];
    
    [sourceController release];
    [sourceNavController release];

}

- (void)_viewGeneratedHtml {

    CAProject *project = (CAProject *)_detailItem;

    //[[[[UIAlertView alloc] initWithTitle:@"Generated HTML Source" message:[project loadBuildHtml] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];

    CASourceViewController *sourceController = [[CASourceViewController alloc] initWithSource:[project loadBuildHtml] title:NSLocalizedString(@"Generated HTML", @"") name:project.name];
    sourceController.delegate = self;
    UINavigationController *sourceNavController = [[UINavigationController alloc] initWithRootViewController:sourceController];
    
    sourceNavController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:sourceNavController animated:YES];
    
    [sourceController release];
    [sourceNavController release];


}


# pragma mark - Sharing

- (void)_sendMail {
    
    if(![MFMailComposeViewController canSendMail]) {
        [CAUtil showError:@"Please set mail account."];
        return;
	}
    
    CAProject *project = (CAProject *)_detailItem;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isBodyText = [userDefaults boolForKey:kCAKeySettingIsBodyText];
    BOOL isAttachment = [userDefaults boolForKey:kCAKeySettingIsAttachment];
    BOOL isZipball = [userDefaults boolForKey:kCAKeySettingIsZipball];
                    
    MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
    mailController.mailComposeDelegate = self;
    mailController.modalPresentationStyle = UIModalPresentationFormSheet;
    [mailController setSubject:project.name];

    if (isBodyText) {
        NSString *body = [NSString stringWithFormat:@""
                          "[HTML]\n"
                          "%@\n"
                          "\n"
                          "[CSS]\n"
                          "%@\n"
                          "\n"
                          "[JS]\n"
                          "%@\n"
                          "\n", _htmlView.text, _cssView.text, _jsView.text];
        [mailController setMessageBody:body isHTML:NO];
    }
    
    if (isAttachment) {
        [mailController addAttachmentData:[project htmlData] mimeType:@"text/html" fileName:@"index.html"];
        [mailController addAttachmentData:[project cssData] mimeType:@"text/css" fileName:@"style.css"];
        [mailController addAttachmentData:[project jsData] mimeType:@"text/javascript" fileName:@"script.js"];
    }
    
    if (isZipball) {
        
        NSString *zipName = [NSString stringWithFormat:@"%@.zip", project.name];
        NSString *zipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:zipName];
        
        ZKFileArchive *fileArchive = [ZKFileArchive archiveWithArchivePath:zipPath];
        [fileArchive deflateDirectory:[project projectPath] relativeToPath:[[CAProjectManager sharedManager] projectsPath] usingResourceFork:NO];
        LOG(@"zipPath: %@", zipPath);

        NSData *zipData = [NSData dataWithContentsOfFile:zipPath];
        [mailController addAttachmentData:zipData mimeType:@"application/zip" fileName:zipName];
        
    }    
        
    
    [self presentModalViewController:mailController animated:YES];

}

- (void)_postGist:(BOOL)isPublic {
 
    NSError *error = nil;  

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults stringForKey:kCAKeySettingUsername];
    NSString *password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:kCAKeySettingServiceName error:&error];

    // test
    //username = @"csatonce";
    //password = @"csatonce1";
    
    if (username.length <=  0 || password.length <= 0) {
        [CAUtil showError:@"Please set github account."];        
        return;
    }    
    
    [self _loading:YES];
    
    CAProject *project = (CAProject *)_detailItem;

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            project.name, @"description", 
                            [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSDictionary dictionaryWithObject:_htmlView.text forKey:@"content"], @"index.html", 
                             [NSDictionary dictionaryWithObject:_cssView.text forKey:@"content"], @"style.css", 
                             [NSDictionary dictionaryWithObject:_jsView.text forKey:@"content"], @"script.js", 
                             nil], @"files",
                            nil];

    if (!project.gistId) {
        [params setValue:(isPublic ? @"true" : @"false") forKey:@"public"];        
    }
    
    NSData *data = [[params JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *urlString = [NSMutableString stringWithString:@"https://api.github.com/gists"];
    if (project.gistId) {
        [urlString appendFormat:@"/%@", project.gistId];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (project.gistId) {
        [request setHTTPMethod:@"PATCH"];          
    } else {
        [request setHTTPMethod:@"POST"];  
    }

    NSString *credential = [CAUtil base64:[NSString stringWithFormat:@"%@:%@", username, password]];
    [request setValue:[NSString stringWithFormat:@"Basic %@", credential] forHTTPHeaderField:@"Authorization"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];  
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];  
    [request setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];  
    [request setHTTPBody:data];  

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

        if (!error) {
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *response = [content JSONValue];
                NSString *gistId = [response objectForKey:@"id"];
                LOG(@"response: %@", gistId);
                
                if (!project.gistId) {
                    project.gistId = gistId;
                    [[CAProjectManager sharedManager] save];
                }
                
                [[[[UIAlertView alloc] initWithTitle:@"Succeeded" message:[NSString stringWithFormat:@"Gist id is \"%@\"", project.gistId] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];        
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CAUtil showError:[error localizedDescription]];
                return;
            });
        }
        
    });    
    
    [self _loading:NO];
}

- (void)_viewGist {
    CAProject *project = (CAProject *)_detailItem;
    [CAUtil openSafari:@"Gist" urlString:[NSString stringWithFormat:@"https://gist.github.com/%@", project.gistId] confirm:YES];
}


# pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isZipball = [userDefaults boolForKey:kCAKeySettingIsZipball];
    
    if (isZipball) {
        
        CAProject *project = (CAProject *)_detailItem;
        
        NSString *zipName = [NSString stringWithFormat:@"%@.zip", project.name];
        NSString *zipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:zipName];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *err = nil;
        [fileManager removeItemAtPath:zipPath error:&err];  
        
        if (err) {
            [CAUtil showError:err.description];
            return;
        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
}

# pragma mark - CASourceViewControllerDelegate

- (void)sourceControllerDidClose:(CASourceViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}


@end
