//
//  CASourceViewController.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/09/28.
//
//

#import "CASourceViewController.h"

#import "GADBannerView.h"

@interface CASourceViewController () {
    NSString *_source;
    GADBannerView *_admobView;
}

@property (nonatomic, retain) UITextView *textView;

@end

@implementation CASourceViewController

- (void)dealloc {
    [_textView release];
    
    _delegate = nil;
    
    [_admobView release];
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.textView = nil;
    //self.webView = nil;
}

- (id)initWithSource:(NSString *)source title:(NSString *)title name:(NSString *)name {
    self = [super init];
    if (self) {
        _source = [source stringByReplacingOccurrencesOfString:@"\t" withString:@"  "];
        self.title = title;
        self.navigationItem.prompt = name;
    }
    return self;
}


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
    
    // Set color
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Navigation bar
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(closeAction:)];
    self.navigationItem.rightBarButtonItem = closeItem;
    [closeItem release];
    
    // Ad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _admobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        _admobView.adUnitID = AdMobUnitIdPhone; //iPhone
    }else {
        _admobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeFullBanner];
        _admobView.adUnitID = AdMobUnitIdPad; //iPad
    }
    _admobView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
#ifdef DEBUG
    request.testing = YES;
#endif
    
    _admobView.center = CGPointMake(self.view.bounds.size.width / 2, _admobView.center.y);
    _admobView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin;

    [_admobView loadRequest:request];

#ifdef DEBUG
    CGRect admobFrame = _admobView.frame;
    //admobFrame.size.height = 0;
    _admobView.frame = admobFrame;    
#endif
    
    // TextView
    self.textView = [[[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - _admobView.frame.size.height)] autorelease];
    _textView.editable = NO;
    _textView.font = [UIFont fontWithName:@"Courier" size:14.0f];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _textView.dataDetectorTypes = UIDataDetectorTypeLink;
    [self.view addSubview:_textView];
    _textView.text = _source;

    [self.view addSubview:_admobView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGRect admobFrame = _admobView.frame;
    admobFrame.origin.y = self.view.bounds.size.height - admobFrame.size.height;
    _admobView.frame = admobFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

# pragma mark - Button actions

- (void)closeAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(sourceControllerDidClose:)]) {
        [_delegate sourceControllerDidClose:self];
    }
}



@end
