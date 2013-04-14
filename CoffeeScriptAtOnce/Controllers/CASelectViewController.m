//
//  CASelectViewController.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CASelectViewController.h"

#import "CAUtil.h"

#import "GADBannerView.h"

@interface CASelectViewController () {
    GADBannerView *_admobView;
    NADView *_nadView;
}

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation CASelectViewController

@synthesize tableView = _tableView;
@synthesize items = _items;
@synthesize target = _target;

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
    
    // Init TableView
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    
    // Ad
    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([locale isEqualToString:@"ja"] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {        
        _nadView = [[NADView alloc] initWithFrame:CGRectMake(0.0, 
                                                             0.0,
                                                             NAD_ADVIEW_SIZE_320x50.width, 
                                                             NAD_ADVIEW_SIZE_320x50.height)];
        [_nadView setNendID:NendId spotID:NendSpotId];
        _nadView.delegate = self;
        _nadView.rootViewController = self;
        [_nadView load:nil];
    } else {
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
        
        _tableView.tableHeaderView = _admobView;
        [_admobView loadRequest:request]; 
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _nadView.delegate = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.tableView = nil;

}

- (void)dealloc {
    [super dealloc];
    
    [_tableView release];
    
    [_admobView release];
    [_nadView release];
    
    _items = nil;
    _target = nil;

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

# pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    _target.tag = indexPath.row;
    LOG(@"tag %d, %d", indexPath.row, _target.tag);
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self _updateAllCells];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}


# pragma mark - Refresh View

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    cell.textLabel.text = [_items objectAtIndex:indexPath.row];        

    LOG(@"tag %d", _target.tag);
    if (_target.tag == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }    

}

- (void)_updateAllCells {
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        [self _updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

- (void)nadViewDidFinishLoad:(NADView *)adView {
    [_tableView setTableHeaderView:adView];
}





@end
