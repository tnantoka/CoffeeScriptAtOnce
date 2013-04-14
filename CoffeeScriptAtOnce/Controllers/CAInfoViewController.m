//
//  CAInfoViewController.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CAInfoViewController.h"

#import "CAProjectManager.h"
#import "CAProject.h"
#import "CAUtil.h"

#import "GADBannerView.h"

enum {
    CAInfoTagNameField,  
    CAInfoTagGistField  
};

@interface CAInfoViewController () {
    NSArray *_sections;
    NSArray *_items;
    GADBannerView *_admobView;
    NADView *_nadView;
}

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) UITextField *nameField;

@property (nonatomic, retain) UITextField *gistField;

@property (nonatomic, retain) UISwitch *isCoffeeScriptSwitch;
@property (nonatomic, retain) UISwitch *isJQuerySwitch;
@property (nonatomic, retain) UISwitch *isOnErrorSwitch;
@property (nonatomic, retain) UISwitch *isConsoleLogSwitch;

@end

@implementation CAInfoViewController

@synthesize delegate = _delegate;
@synthesize project = _project;

@synthesize tableView = _tableView;

@synthesize nameField = _nameField;

@synthesize gistField = _gistField;

@synthesize isCoffeeScriptSwitch = _isCoffeeScriptSwitch;
@synthesize isJQuerySwitch = _isJQuerySwitch;
@synthesize isOnErrorSwitch = _isOnErrorSwitch;
@synthesize isConsoleLogSwitch = _isConsoleLogSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _sections = [[NSArray arrayWithObjects:
                      @"Identifier",
                      @"Library",
                      @"Log",
                      nil] retain];
        
        NSArray *logs;
        
        if ([CAUtil isIOS4]) {
            logs = [NSArray arrayWithObjects:@"console.log", nil];
        } else {
            logs = [NSArray arrayWithObjects:@"console.log", @"window.onenrror", nil];
        }
        
        _items = [[NSArray arrayWithObjects:
                   [NSArray arrayWithObjects:@"Name", @"Gist id", nil],
                   [NSArray arrayWithObjects:@"CoffeeScript", @"jQuery", nil],
                   logs,
                   nil] retain];
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
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    if (!_project) {
        //self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Init parts of form
    self.nameField = [[[UITextField alloc] init] autorelease];
    _nameField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _nameField.clearButtonMode = UITextFieldViewModeAlways;
    _nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameField.textAlignment = UITextAlignmentRight;
    _nameField.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    _nameField.tag = CAInfoTagNameField;
    _nameField.returnKeyType = UIReturnKeyDone;
    _nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _nameField.delegate = self;
    [_nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _nameField.keyboardAppearance = UIKeyboardAppearanceAlert;

    self.gistField = [[[UITextField alloc] init] autorelease];
    _gistField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //_gistField.clearButtonMode = UITextFieldViewModeAlways;
    _gistField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _gistField.textAlignment = UITextAlignmentRight;
    //_gistField.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    _gistField.tag = CAInfoTagGistField;
    _gistField.returnKeyType = UIReturnKeyDone;
    _gistField.autocorrectionType = UITextAutocorrectionTypeNo;
    _gistField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _gistField.delegate = self;
    _gistField.userInteractionEnabled = NO;
    //[_gistField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _gistField.keyboardAppearance = UIKeyboardAppearanceAlert;

    UITableViewCell *dummyCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DummyCell"] autorelease];
    _nameField.frame = CGRectMake(-30, 0, dummyCell.frame.size.width * 0.65, dummyCell.frame.size.height);
    //_gistField.frame = CGRectMake(-30, 0, dummyCell.frame.size.width * 0.65, dummyCell.frame.size.height);

    self.isCoffeeScriptSwitch = [[[UISwitch alloc] init] autorelease];
    self.isJQuerySwitch = [[[UISwitch alloc] init] autorelease];
    self.isOnErrorSwitch = [[[UISwitch alloc] init] autorelease];
    self.isConsoleLogSwitch = [[[UISwitch alloc] init] autorelease];
    
    // Init TableView
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    // Restore project or last value
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (_project) {
        _nameField.text = _project.name;
        _isCoffeeScriptSwitch.on = _project.isCoffeeScript;
        _isJQuerySwitch.on = _project.isJQuery;
        _isOnErrorSwitch.on = _project.isOnError;
        _isConsoleLogSwitch.on = _project.isConsoleLog;
        
        if (_project.gistId > 0) {
            _gistField.text = _project.gistId;
            [_gistField sizeToFit];
        }
    } else {
        _nameField.text = [NSString stringWithFormat:@"Project %d", [CAProjectManager sharedManager].projects.count + 1];
        _isCoffeeScriptSwitch.on = [userDefaults boolForKey:kCAKeyDefaultIsCoffeeScript];
        _isJQuerySwitch.on = [userDefaults boolForKey:kCAKeyDefaultIsJQuery];
        _isOnErrorSwitch.on = [userDefaults boolForKey:kCAKeyDefaultIsOnError];
        _isConsoleLogSwitch.on = [userDefaults boolForKey:kCAKeyDefaultIsConsoleLog];
    }

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
        
        _tableView.tableFooterView = _admobView;
        [_admobView loadRequest:request];                        
    }


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.tableView = nil;
    self.nameField = nil;
    
    self.gistField = nil;

    self.isCoffeeScriptSwitch = nil;
    self.isJQuerySwitch = nil;
    self.isOnErrorSwitch = nil;
    self.isConsoleLogSwitch = nil;
}

- (void)dealloc {
    [_tableView release];
    
    [_sections release];
    [_items release];
    
    _delegate = nil;    
    _project = nil;
    
    [_nameField release];
    
    [_gistField release];
    
    [_isCoffeeScriptSwitch release];
    [_isJQuerySwitch release];
    [_isOnErrorSwitch release];
    [_isConsoleLogSwitch release];
    
    [_admobView release];
    [_nadView release];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_project) {
        //[_nameField becomeFirstResponder];
    }
}


# pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_items objectAtIndex:section] count];
}
            
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d%d", indexPath.section, indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self _initCell:cell atIndexPath:indexPath];
    }
    
    [self _updateCell:cell atIndexPath:indexPath];
    return cell;
}

# pragma mark - Refresh View

- (void)_initCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell.accessoryView = _nameField;
                    
                    break;                    
                case 1:
                    cell.accessoryView = _gistField;
                    
                    break;                    
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.accessoryView = _isCoffeeScriptSwitch;
                    break;                    
                case 1:
                    cell.accessoryView = _isJQuerySwitch;
                    break;                    
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.accessoryView = _isConsoleLogSwitch;
                    break;
                case 1:            
                    cell.accessoryView = _isOnErrorSwitch;
                    break;
            }
            break;
    }    
}
    
- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    cell.textLabel.text = [[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

# pragma mark - Button Actions

- (void)cancelAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(infoControllerDidCancel:)]) {
        [_delegate infoControllerDidCancel:self];
    }
}

- (void)saveAction:(id)sender {
    NSString *name = _nameField.text;
    
    //if ([[CAProjectManager sharedManager] isExists:name] && _project != [[CAProjectManager sharedManager] projectNamed:name]) {    
    if (_project != [[CAProjectManager sharedManager] projectNamed:name]) {    
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Project \"%@\" already exists.", name] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    // New Project
    if (!_project) {
        _project = [[CAProject alloc] initWithIsCoffeeScript:_isCoffeeScriptSwitch.on isJQuery:_isJQuerySwitch.on];
        if (![[CAProjectManager sharedManager].projects containsObject:_project]) {
            //[[CAProjectManager sharedManager] addProject:_project];
            [[CAProjectManager sharedManager] insertProject:_project atIndex:0];
        }
    } else {
        _project.isCoffeeScript = _isCoffeeScriptSwitch.on;
        _project.isJQuery = _isJQuerySwitch.on;        
    }
    
    // Update project property
    _project.name = name;
    _project.isOnError = _isOnErrorSwitch.on;
    _project.isConsoleLog = _isConsoleLogSwitch.on;
    _project.updatedAt = [NSDate date];        
    
    // Save last value
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:_project.isCoffeeScript forKey:kCAKeyDefaultIsCoffeeScript];
    [userDefaults setBool:_project.isJQuery forKey:kCAKeyDefaultIsJQuery];
    [userDefaults setBool:_project.isOnError forKey:kCAKeyDefaultIsOnError];
    [userDefaults setBool:_project.isConsoleLog forKey:kCAKeyDefaultIsConsoleLog];
    
    [[CAProjectManager sharedManager] save];
    
    if ([_delegate respondsToSelector:@selector(infoController:didSave:)]) {
        [_delegate infoController:self didSave:_project];
    }
}

# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == CAInfoTagNameField) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidChange:(id)sender {
    UITextField *textField = (UITextField *)sender;
    if (textField.tag == CAInfoTagNameField) {
        if (textField.text.length > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}    

#pragma mark - NADViewDelegate

- (void)nadViewDidFinishLoad:(NADView *)adView {
    [_tableView setTableFooterView:adView];
}




@end
