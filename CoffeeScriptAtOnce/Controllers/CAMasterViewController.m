//
//  CAMasterViewController.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CAMasterViewController.h"

#import "CADetailViewController.h"

#import "CAUtil.h"
#import "CAProjectManager.h"
#import "CAProject.h"
#import "CAInfoViewController.h"
#import "CASettingViewController.h"

#import "BlockAlertView.h"

#import "GADBannerView.h"

@interface CAMasterViewController () {
    int lastSelectedRow;
    ADBannerView *_iAdView;
    GADBannerView *_admobView;
}

@property (nonatomic, retain) UIBarButtonItem *infoItem;
@property (nonatomic, retain) UIBarButtonItem *dupItem;
@property (nonatomic, retain) UIBarButtonItem *trashItem;

@end

@implementation CAMasterViewController

@synthesize infoItem = _infoItem;
@synthesize dupItem = _dupItem;
@synthesize trashItem = _trashItem;

@synthesize detailViewController = _detailViewController;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
- (id)init
{
    //self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self = [super init];
    if (self) {
        //self.title = NSLocalizedString(@"Master", @"Master");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    
    [_iAdView release];
    [_admobView release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    // Init NavigationBar
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;

    UIBarButtonItem *backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    // Init Toolbar
    //UIBarButtonItem *settingButton = [[[UIBarButtonItem alloc] initWithTitle:@"Setting" style:UIBarButtonItemStyleBordered target:self action:@selector(settingAction:)] autorelease];
    UIBarButtonItem *settingButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingAction:)] autorelease];
    //self.navigationItem.leftBarButtonItem = settingButton;
    
    //self.infoItem = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(infoAction:)];
    //self.dupItem = [[UIBarButtonItem alloc] initWithTitle:@"Dup" style:UIBarButtonItemStyleBordered target:self action:@selector(dupAction:)];
    //self.trashItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashAction:)];
    //_trashItem.style = UIBarButtonItemStyleBordered;
    self.infoItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"spanner_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(infoAction:)] autorelease];
    self.dupItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"copy_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dupAction:)] autorelease];
    self.trashItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trash_24.png"] style:UIBarButtonItemStylePlain target:self action:@selector(trashAction:)] autorelease];

    UIBarButtonItem *flexibleItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    NSArray *toolbarItems = [NSArray arrayWithObjects:
                             settingButton,
                             flexibleItem,
                             _infoItem, 
                             _dupItem, 
                             _trashItem, 
                             nil];
    [self setToolbarItems:toolbarItems animated:NO];

    // doesn't work on iPad iOS4.3
    //if ([CAUtil isIOS5]) {
    //    [self.navigationController setToolbarHidden:NO animated:NO];   
    //}
    
    
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

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _iAdView = [[ADBannerView alloc] initWithFrame:CGRectZero];
        _iAdView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        _iAdView.delegate = self;
        _iAdView.hidden = YES;
    } else {
        self.tableView.tableFooterView = _admobView;
        [_admobView loadRequest:request];        
    }
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self _deselect:self.tableView.indexPathForSelectedRow deleted:NO];
    
    [self _toggleProjectButtons:NO];
    
    [self.navigationController setToolbarHidden:NO animated:NO];   
    
    [self _iAdToBottom];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.navigationController setToolbarHidden:YES animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    //switch ([UIApplication sharedApplication].statusBarOrientation) {
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            _iAdView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            _iAdView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
            break;
    }

    [self _iAdToBottom];

    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
     */
    return YES;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [CAProjectManager sharedManager].projects.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        /*
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
         */
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

    [self _updateCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG(@"commit");
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[CAProjectManager sharedManager] removeProjectAtIndex:indexPath.row];
        [[CAProjectManager sharedManager] save];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [self _deselect:indexPath deleted:YES];
        return;

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
    [self _deselect:indexPath deleted:NO];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG(@"end");
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG(@"begin");
    [self _deselect:indexPath deleted:NO]; // for when not deleted or selecte unselected row
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [[CAProjectManager sharedManager] moveProjectAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
    [[CAProjectManager sharedManager] save];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG(@"did select: last index = %d, %d", lastSelectedRow, tableView.indexPathForSelectedRow.row);
   
    BOOL is_select = NO;
    if (lastSelectedRow == indexPath.row) {
        is_select = YES;  
    }        
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                is_select = YES;
                break;
        }
    }

    if (is_select) {
        
        id object = [[CAProjectManager sharedManager].projects objectAtIndex:indexPath.row];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (!self.detailViewController) {
                //self.detailViewController = [[[CADetailViewController alloc] initWithNibName:@"CADetailViewController_iPhone" bundle:nil] autorelease];
                self.detailViewController = [[[CADetailViewController alloc] init] autorelease];
            }
            self.detailViewController.detailItem = object;
            [self.navigationController pushViewController:self.detailViewController animated:YES];
        } else {
            self.detailViewController.detailItem = object;
        }
        
    } else {
        //[self.navigationController setToolbarHidden:NO animated:YES];   
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    [self _toggleProjectButtons:YES];    
    
    lastSelectedRow = indexPath.row;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    LOG(@"setEdit");
    if (!editing) {
        [self _deselect:self.tableView.indexPathForSelectedRow deleted:NO];
    }
    [super setEditing:editing animated:animated];
}

# pragma mark - Refresh View

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {

    CAProject *project = nil;
    NSArray *projects = [CAProjectManager sharedManager].projects;
    project = [projects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = project.description;
    cell.detailTextLabel.text = [project.updatedAt description];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        cell.accessoryType = UITableViewCellAccessoryNone;        
    }
}

- (void)_updateAllCells {
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        [self _updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

- (void)_toggleProjectButtons:(BOOL)enabled {
    _infoItem.enabled = enabled;
    _dupItem.enabled = enabled;
    _trashItem.enabled = enabled;
}

- (void)_updateTitle {
    self.title = [NSString stringWithFormat:@"Projects (%d)", [CAProjectManager sharedManager].projects.count];
}

- (void)_deselect:(NSIndexPath *)indexPath deleted:(BOOL)deleted {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    lastSelectedRow = -1;
    [self _updateAllCells];
    [self _updateTitle];

    if (deleted) {
        _detailViewController.detailItem = nil;
    }
    
    [self _iAdToBottom];
}

# pragma mark - Button Actions


- (void)addAction:(id)sender
{
    CAInfoViewController *infoController = [[[CAInfoViewController alloc] init] autorelease];
    infoController.delegate = self;
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:infoController] autorelease];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navController animated:YES];    
}

- (void)infoAction:(id)sender {
    CAInfoViewController *infoController = [[[CAInfoViewController alloc] init] autorelease];
    infoController.delegate = self;
    infoController.project = [[CAProjectManager sharedManager].projects objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:infoController] autorelease];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navController animated:YES];    
}

# pragma mark - CAInfoViewControllerDelegate

- (void)infoControllerDidCancel:(CAInfoViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];    
}

- (void)infoController:(CAInfoViewController *)controller didSave:(CAProject *)project {
    [self dismissModalViewControllerAnimated:YES];
        
    if ([self.tableView numberOfRowsInSection:0] != [CAProjectManager sharedManager].projects.count) {
        [self.tableView reloadData]; 
    }        

    [self _iAdToBottom];
}

# pragma mark - CAInfoViewControllerDelegate

- (void)settingControllerDidCancel:(CASettingViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];    
}

- (void)settingControllerDidSave:(CASettingViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
}

# pragma mark - Button Actions

- (void)trashAction:(id)sender {

    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    CAProject *project = [[CAProjectManager sharedManager].projects objectAtIndex:indexPath.row];
    
    BlockAlertView *blockAlert = [[BlockAlertView alloc] initWithTitle:@"Delete Project" message:[NSString stringWithFormat:@"Delete \"%@\" project?", project.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
    [blockAlert showWithCompletionHandler:^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0: {
                [[CAProjectManager sharedManager] removeProjectAtIndex:indexPath.row];
                [[CAProjectManager sharedManager] save];
                
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self _toggleProjectButtons:NO];    
                
                [self _deselect:indexPath deleted:YES];
 
                break;
            }
            case 1:
                break;
        }
    }];
    [blockAlert release];
    
}

- (void)settingAction:(id)sender {
    CASettingViewController *settingController = [[[CASettingViewController alloc] init] autorelease];
    settingController.delegate = self;
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:settingController] autorelease];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navController animated:YES];        
}

- (void)dupAction:(id)sender {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    CAProject *sourceProject = [[CAProjectManager sharedManager].projects objectAtIndex:indexPath.row];
    
    CAProject *project = [[[CAProject alloc] initFromProject:sourceProject] autorelease];
    [[CAProjectManager sharedManager] insertProject:project atIndex:0];

    [[CAProjectManager sharedManager] save];

    //[self.tableView reloadData];
    NSIndexPath *top = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:top] withRowAnimation:UITableViewRowAnimationAutomatic];

    [self _deselect:self.tableView.indexPathForSelectedRow deleted:NO];
    
}

# pragma mark - iAd

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    LOG(@"iad fail");
    _iAdView.hidden = YES;
    
    GADRequest *request = [GADRequest request];
#ifdef DEBUG
    request.testing = YES;
#endif    
    self.tableView.tableFooterView = _admobView;
    [_admobView loadRequest:request];        

    [self _iAdToBottom];
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    LOG(@"iad did finish");
    _iAdView.hidden = NO;
    self.tableView.tableFooterView = _iAdView;
    [self.tableView bringSubviewToFront:_iAdView];
    [self _iAdToBottom];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    LOG(@"iad did load");
    _iAdView.hidden = NO;    
    self.tableView.tableFooterView = _iAdView;
    [self _iAdToBottom];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self _iAdToBottom];
}

-(void)_iAdToBottom {
    CGRect iAdFrame = _iAdView.frame;
    CGFloat newOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - iAdFrame.size.height;
    CGRect newIAdFrame = CGRectMake(iAdFrame.origin.x, newOriginY, iAdFrame.size.width, iAdFrame.size.height);
    _iAdView.frame = newIAdFrame;
    
    CGRect admobFrame = _admobView.frame;
    CGFloat newAdmobOriginY = self.tableView.contentOffset.y + self.tableView.frame.size.height - admobFrame.size.height;
    CGRect newAdmobFrame = CGRectMake(admobFrame.origin.x, newAdmobOriginY, admobFrame.size.width, admobFrame.size.height);
    _admobView.frame = newAdmobFrame;
    
}



@end
