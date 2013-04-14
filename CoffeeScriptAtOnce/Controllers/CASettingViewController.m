//
//  CASettingViewController.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CASettingViewController.h"

#import "CAUtil.h"

#import "SFHFKeychainUtils.h"

#import "CASelectViewController.h"

#import "GADBannerView.h"

enum {
    CASettingTagUsernameField,  
    CASettingTagPasswordField,
    CASettingTagKeysField  
};

@interface CASettingViewController () {
    NSArray *_sections;
    NSArray *_items;
    GADBannerView *_admobView;
    NADView *_nadView;
}

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) UILabel *textColorLabel;
@property (nonatomic, retain) UILabel *bgColorLabel;
@property (nonatomic, retain) UILabel *fontNameLabel;
@property (nonatomic, retain) UILabel *fontSizeLabel;
@property (nonatomic, retain) UISwitch *isCustomKeyboardSwitch;

@property (nonatomic, retain) UISwitch *isLineNumsSwitch;
@property (nonatomic, retain) UISwitch *isLineInfoSwitch;

@property (nonatomic, retain) UISwitch *isBodyTextSwitch;
@property (nonatomic, retain) UISwitch *isAttachmentSwitch;
@property (nonatomic, retain) UISwitch *isZipballSwitch;

@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;

@property (nonatomic, retain) UITextField *keysField;

@end

@implementation CASettingViewController

@synthesize delegate = _delegate;

@synthesize tableView = _tableView;

@synthesize textColorLabel = _textColorLabel;
@synthesize bgColorLabel = _bgColorLabel;
@synthesize fontNameLabel = _fontNameLabel;
@synthesize fontSizeLabel = _fontSizeLabel;
@synthesize isCustomKeyboardSwitch = _isCustomKeyboardSwitch;

@synthesize isBodyTextSwitch = _isBodyTextSwitch;
@synthesize isAttachmentSwitch = _isAttachmentSwitch;
@synthesize isZipballSwitch = _isZipballSwitch;

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

@synthesize keysField = _keysField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

        _sections = [[NSArray arrayWithObjects:
                      @"Editor",
                      @"Email",
                      @"Github",
                      @"Thanks",
                      nil] retain];
        _items = [[NSArray arrayWithObjects:
                   [NSArray arrayWithObjects:@"Text Color", @"Bg Color", @"Font Name", @"Font Size", @"Custom Keyboard", @"Custom Keys", @"Line Numbers", @"Line Info", nil],
                   [NSArray arrayWithObjects:@"Body Text", @"Attachements", @"Zipball", nil],
                   [NSArray arrayWithObjects:@"Username", @"Password", nil],
                   [NSArray arrayWithObjects:@"CoffeeScript", @"jQuery", @"Retina Display Icon Set", @"SFHFKeychainUtils", @"ZipKit", @"SBJson", nil],
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
    
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)] autorelease];
    self.navigationItem.leftBarButtonItem = cancelButton;

    // Init TableView
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    // Init parts of form

    UITableViewCell *dummyCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DummyCell"] autorelease];
    
    // Editor
    self.textColorLabel = [[[UILabel alloc] init] autorelease];
    _textColorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _textColorLabel.textAlignment = UITextAlignmentRight;
    _textColorLabel.backgroundColor = [UIColor clearColor];
    _textColorLabel.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    _textColorLabel.text = @" ";
    [_textColorLabel sizeToFit]; // for right margin);
    CGRect textColorFrame = _textColorLabel.frame;
    textColorFrame.size.width = dummyCell.frame.size.width * 0.5;
    _textColorLabel.frame = textColorFrame;
    
    self.bgColorLabel = [[[UILabel alloc] init] autorelease];
    _bgColorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _bgColorLabel.textAlignment = UITextAlignmentRight;
    _bgColorLabel.backgroundColor = [UIColor clearColor];
    _bgColorLabel.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    _bgColorLabel.text = [CAUtil colorName:_bgColorLabel.tag];
    [_bgColorLabel sizeToFit]; // for right margin
    CGRect bgColorFrame = _bgColorLabel.frame;
    bgColorFrame.size.width = dummyCell.frame.size.width * 0.5;
    _bgColorLabel.frame = bgColorFrame;

    self.fontNameLabel = [[[UILabel alloc] init] autorelease];
    _fontNameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _fontNameLabel.textAlignment = UITextAlignmentRight;
    _fontNameLabel.backgroundColor = [UIColor clearColor];
    _fontNameLabel.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    _fontNameLabel.text = [CAUtil fontName:_fontNameLabel.tag];
    [_fontNameLabel sizeToFit]; // for right margin
    CGRect fontNameFrame = _fontNameLabel.frame;
    fontNameFrame.size.width = dummyCell.frame.size.width * 0.5;
    _fontNameLabel.frame = fontNameFrame;

    self.fontSizeLabel = [[[UILabel alloc] init] autorelease];
    _fontSizeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _fontSizeLabel.textAlignment = UITextAlignmentRight;
    _fontSizeLabel.backgroundColor = [UIColor clearColor];
    _fontSizeLabel.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    _fontSizeLabel.text = [CAUtil fontSize:_fontSizeLabel.tag];
    [_fontSizeLabel sizeToFit]; // for right margin
    CGRect fontSizeFrame = _fontSizeLabel.frame;
    fontSizeFrame.size.width = dummyCell.frame.size.width * 0.5;
    _fontSizeLabel.frame = fontSizeFrame;

    self.isCustomKeyboardSwitch = [[[UISwitch alloc] init] autorelease];        
    
    self.keysField = [[[UITextField alloc] init] autorelease];
    _keysField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _keysField.clearButtonMode = UITextFieldViewModeAlways;
    _keysField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _keysField.textAlignment = UITextAlignmentRight;
    _keysField.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    _keysField.tag = CASettingTagUsernameField;
    _keysField.returnKeyType = UIReturnKeyDone;
    _keysField.autocorrectionType = UITextAutocorrectionTypeNo;
    _keysField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _keysField.delegate = self;
    _keysField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _keysField.frame = CGRectMake(0, 0, dummyCell.frame.size.width * 0.5, dummyCell.frame.size.height);
    
    self.isLineNumsSwitch = [[[UISwitch alloc] init] autorelease];
    self.isLineInfoSwitch = [[[UISwitch alloc] init] autorelease];
    
    // Email
    self.isBodyTextSwitch = [[[UISwitch alloc] init] autorelease];
    self.isAttachmentSwitch = [[[UISwitch alloc] init] autorelease];
    self.isZipballSwitch = [[[UISwitch alloc] init] autorelease];
    
    // Github
    self.usernameField = [[[UITextField alloc] init] autorelease];
    _usernameField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _usernameField.clearButtonMode = UITextFieldViewModeAlways;
    _usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _usernameField.textAlignment = UITextAlignmentRight;
    _usernameField.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    _usernameField.tag = CASettingTagUsernameField;
    _usernameField.returnKeyType = UIReturnKeyDone;
    _usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    _usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameField.delegate = self;
    _usernameField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _usernameField.frame = CGRectMake(0, 0, dummyCell.frame.size.width * 0.5, dummyCell.frame.size.height);

    self.passwordField = [[[UITextField alloc] init] autorelease];
    _passwordField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _passwordField.clearButtonMode = UITextFieldViewModeAlways;
    _passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordField.textAlignment = UITextAlignmentRight;
    _passwordField.textColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    _passwordField.tag = CASettingTagPasswordField;
    _passwordField.returnKeyType = UIReturnKeyDone;
    _passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordField.delegate = self;
    _passwordField.secureTextEntry = YES;
    _passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    _passwordField.frame = CGRectMake(0, 0, dummyCell.frame.size.width * 0.5, dummyCell.frame.size.height);
    
    // Thanks
    
    // Restore settings
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _textColorLabel.tag = [userDefaults integerForKey:kCAKeySettingTextColor];
    _bgColorLabel.tag = [userDefaults integerForKey:kCAKeySettingBgColor];
    _fontNameLabel.tag = [userDefaults integerForKey:kCAKeySettingFontName];
    _fontSizeLabel.tag = [userDefaults integerForKey:kCAKeySettingFontSize];
    _isCustomKeyboardSwitch.on = [userDefaults boolForKey:kCAKeySettingIsCustomKeyboard];

    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _updateAllCells];
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

    self.textColorLabel = nil;
    self.bgColorLabel = nil;
    self.fontNameLabel = nil;
    self.fontSizeLabel = nil;
    self.isCustomKeyboardSwitch = nil;
    
    self.isLineNumsSwitch = nil;
    self.isLineInfoSwitch = nil;
    
    self.isBodyTextSwitch = nil;
    self.isAttachmentSwitch = nil;
    self.isZipballSwitch = nil;
    
    self.usernameField = nil;
    self.passwordField = nil;
    
}


- (void)dealloc {

    [_sections release];
    [_items release];
    
    _delegate = nil;
    
    [_tableView release];
    
    [_textColorLabel release];
    [_bgColorLabel release];
    [_fontNameLabel release];
    [_fontSizeLabel release];
    [_isCustomKeyboardSwitch release];

    [_isLineNumsSwitch release];
    [_isLineInfoSwitch release];
    
    [_isBodyTextSwitch release];
    [_isAttachmentSwitch release];
    [_isZipballSwitch release];
    
    [_usernameField release];
    [_passwordField release];
    
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
        [self _initCell:cell atIndexPath:indexPath];
    }
    
    [self _updateCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        
        case 0: {
            CASelectViewController *selectController = [[[CASelectViewController alloc] init] autorelease];
            selectController.title = [[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            
            switch (indexPath.row) {
                case 0:
                    selectController.items = [CAUtil colorNames];
                    selectController.target = _textColorLabel;
                    [self.navigationController pushViewController:selectController animated:YES];
                    
                    break;
                case 1:
                    selectController.items = [CAUtil colorNames];
                    selectController.target = _bgColorLabel;
                    [self.navigationController pushViewController:selectController animated:YES];

                    break;
                case 2:
                    selectController.items = [CAUtil fontNames];
                    selectController.target = _fontNameLabel;
                    [self.navigationController pushViewController:selectController animated:YES];

                    break;
                case 3:
                    selectController.items = [CAUtil fontSizes];
                    selectController.target = _fontSizeLabel;
                    [self.navigationController pushViewController:selectController animated:YES];
                    
                    break;
                case 4:
                    break;
                case 5:
                    break;
            }
            break;
        }
        case 1:
            switch (indexPath.row) {
            }
            break;
        
        case 2:
            switch (indexPath.row) {
            }
            break;

        case 3:
            switch (indexPath.row) {
                case 0:
                    [CAUtil openSafari:[[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] urlString:@"http://coffeescript.org/" confirm:YES];
                    break;
                case 1:
                    [CAUtil openSafari:[[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] urlString:@"http://jquery.com/" confirm:YES];
                    break;
                case 2:
                    [CAUtil openSafari:[[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] urlString:@"http://blog.twg.ca/2010/11/retina-display-icon-set/" confirm:YES];
                    break;
                case 3:
                    [CAUtil openSafari:[[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] urlString:@"https://github.com/ldandersen/scifihifi-iphone/tree/master/security" confirm:YES];
                    break;
                case 4:
                    [CAUtil openSafari:[[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] urlString:@"https://bitbucket.org/kolpanic/zipkit/wiki/Home" confirm:YES];
                    break;
                case 5:
                    [CAUtil openSafari:[[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] urlString:@"http://stig.github.com/json-framework/" confirm:YES];
                    break;
            }
            break;
    }
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}


# pragma mark - Refresh View

- (void)_initCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {

    cell.textLabel.text = [[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];    
    
    switch (indexPath.section) {
        case 0:
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            switch (indexPath.row) {
                case 0:
                    cell.accessoryView = _textColorLabel;                    
                    break;                    
                case 1:
                    cell.accessoryView = _bgColorLabel;
                    break;                    
                case 2:
                    cell.accessoryView = _fontNameLabel;
                    break;
                case 3:
                    cell.accessoryView = _fontSizeLabel;
                    break;
                case 4:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryView = _isCustomKeyboardSwitch;
                    break;
                case 5:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryView = _keysField;
                    break;
                case 6:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryView = _isLineNumsSwitch;
                    cell.detailTextLabel.text = @"* Only as a guide";
                    break;
                case 7:
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.accessoryView = _isLineInfoSwitch;
                    break;
            }
            break;
        case 1:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0:
                    cell.accessoryView = _isBodyTextSwitch;
                    break;                    
                case 1:
                    cell.accessoryView = _isAttachmentSwitch;
                    break;
                case 2:
                    cell.accessoryView = _isZipballSwitch;
                    break;
            }
            break;
        case 2:
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row) {
                case 0:
                    cell.accessoryView = _usernameField;
                    break;
                case 1:            
                    cell.accessoryView = _passwordField;
                    break;
            }
            break;
        case 3:
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            switch (indexPath.row) {
                case 0:
                    break;
                case 1:            
                    break;
                case 2:
                    break;
                case 3:            
                    break;
                case 4:            
                    break;
                case 5:            
                    break;
            }
            break;
    }
    
}

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    
    cell.textLabel.text = [[_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSError *error = nil;

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    _textColorLabel.text = [CAUtil colorName:_textColorLabel.tag];
                    break;                    
                case 1:
                    _bgColorLabel.text = [CAUtil colorName:_bgColorLabel.tag];
                    break;                    
                case 2:
                    _fontNameLabel.text = [CAUtil fontName:_fontNameLabel.tag];
                    break;
                case 3:
                    _fontSizeLabel.text = [CAUtil fontSize:_fontSizeLabel.tag];
                    break;
                case 4:
                    _isCustomKeyboardSwitch.on = [userDefaults boolForKey:kCAKeySettingIsCustomKeyboard];
                    break;
                case 5:
                    _keysField.text = [userDefaults stringForKey:kCAKeySettingCustomKeys];                    
                    break;
                case 6:
                    _isLineNumsSwitch.on = [userDefaults boolForKey:kCAKeySettingIsLineNums];
                    break;
                case 7:
                    _isLineInfoSwitch.on = [userDefaults boolForKey:kCAKeySettingIsLineInfo];
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    _isBodyTextSwitch.on = [userDefaults boolForKey:kCAKeySettingIsBodyText];
                    break;                    
                case 1:
                    _isAttachmentSwitch.on = [userDefaults boolForKey:kCAKeySettingIsAttachment];
                    break;
                case 2:
                    _isZipballSwitch.on = [userDefaults boolForKey:kCAKeySettingIsZipball];
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    _usernameField.text = [userDefaults stringForKey:kCAKeySettingUsername];                    
                    break;
                case 1:            
                    _passwordField.text = [SFHFKeychainUtils getPasswordForUsername:[userDefaults stringForKey:kCAKeySettingUsername] andServiceName:kCAKeySettingServiceName error:&error];
                    break;
            }
            break;
        case 3:
            //cell.accessoryView = nil; // for reuse table cell
            switch (indexPath.row) {
                case 0:
                    break;
                case 1:            
                    break;
                case 2:
                    break;
                case 3:            
                    break;
                case 4:
                    break;
                case 5:            
                    break;
            }
            break;
    }
    
    if (error) {
        [CAUtil showError:[error localizedDescription]];
    }

}
     
- (void)_updateAllCells {
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        [self _updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}


# pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == CASettingTagUsernameField) {
        [textField resignFirstResponder];
    } else if (textField.tag == CASettingTagPasswordField) {
        [textField resignFirstResponder];
    }
    return YES;
}

# pragma mark - Button Actions

- (void)cancelAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(settingControllerDidCancel:)]) {
        [_delegate settingControllerDidCancel:self];
    }
}

- (void)saveAction:(id)sender {
    
    // Save setting
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults setBool:_isBodyTextSwitch.on forKey:kCAKeySettingIsBodyText];
    [userDefaults setBool:_isAttachmentSwitch.on forKey:kCAKeySettingIsAttachment];
    [userDefaults setBool:_isZipballSwitch.on forKey:kCAKeySettingIsZipball];

    NSString *keys = _keysField.text;
    if (keys.length > 0) {
        [userDefaults setObject:keys forKey:kCAKeySettingCustomKeys];
    } else {
        [userDefaults removeObjectForKey:kCAKeySettingCustomKeys];
    }
    
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    
    if (username.length > 0) {
        [userDefaults setObject:username forKey:kCAKeySettingUsername];
        
        if (password.length > 0) {
            NSError *error = nil;
            [SFHFKeychainUtils storeUsername:username andPassword:password forServiceName:kCAKeySettingServiceName updateExisting:YES error:&error];    
    
            if (error) {
                [CAUtil showError:[error localizedDescription]];
            }
        }
    }

    [userDefaults setInteger:_textColorLabel.tag forKey:kCAKeySettingTextColor];
    [userDefaults setInteger:_bgColorLabel.tag forKey:kCAKeySettingBgColor];
    [userDefaults setInteger:_fontNameLabel.tag forKey:kCAKeySettingFontName];
    [userDefaults setInteger:_fontSizeLabel.tag forKey:kCAKeySettingFontSize];
    [userDefaults setBool:_isCustomKeyboardSwitch.on forKey:kCAKeySettingIsCustomKeyboard];
    [userDefaults setBool:_isLineNumsSwitch.on forKey:kCAKeySettingIsLineNums];
    [userDefaults setBool:_isLineInfoSwitch.on forKey:kCAKeySettingIsLineInfo];
    
    if ([_delegate respondsToSelector:@selector(settingControllerDidSave:)]) {
        [_delegate settingControllerDidSave:self];
    }
}

#pragma mark - NADViewDelegate

- (void)nadViewDidFinishLoad:(NADView *)adView {
    [_tableView setTableHeaderView:adView];
}



@end
