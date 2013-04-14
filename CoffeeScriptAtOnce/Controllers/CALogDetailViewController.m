//
//  CALogDetailViewController.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CALogDetailViewController.h"
#import "CALogsViewController.h"

@interface CALogDetailViewController ()

@end

@implementation CALogDetailViewController

@synthesize detail = _detail;
@synthesize delegate = _delegate;

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
    
    // Init NavigationBar
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = doneButton;

    self.title = _detail;
    
    // Init DetailView
    UITextView *detailView = [[UITextView alloc] initWithFrame:self.view.bounds];
    detailView.editable = NO;    
    detailView.text = _detail;
    detailView.font = [UIFont systemFontOfSize:18.0f];
    detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:detailView];
    [detailView release];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc {
    
    _delegate = nil;
    
    [super dealloc];
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
    if ([_delegate respondsToSelector:@selector(logsControllerDidSave:)]) {
        [_delegate logsControllerDidSave:[self.navigationController.viewControllers objectAtIndex:0]];
    }
}

@end
