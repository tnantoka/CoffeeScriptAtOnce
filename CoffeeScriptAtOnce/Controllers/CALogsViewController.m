//
//  CALogsViewController.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CALogsViewController.h"
#import "CALogDetailViewController.h"

@interface CALogsViewController ()

@property (nonatomic, retain) UITableView *tableView;

@end

@implementation CALogsViewController

@synthesize items = _items;
@synthesize tableView = _tableView;
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
    
    // Bar Style
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    }
    
    // Init NavigationBar
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)] autorelease];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.title = @"Logs";
    
    // Init TableView
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] autorelease];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.tableView = nil;
}

- (void)dealloc {

    [_tableView release];
    
    [_items release];
    
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

- (void)viewWillAppear:(BOOL)animated {
    [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:YES];    
}


# pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
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

# pragma mark - Refresh View

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    cell.textLabel.text = [_items objectAtIndex:indexPath.row];        
}

- (void)_updateAllCells {
    for (UITableViewCell* cell in [self.tableView visibleCells]) {
        [self _updateCell:cell atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CALogDetailViewController *detailController = [[[CALogDetailViewController alloc] init] autorelease];
    detailController.detail = [_items objectAtIndex:indexPath.row];
    detailController.delegate = _delegate;
    [self.navigationController pushViewController:detailController animated:YES];
}

# pragma mark - Button Actions

- (void)doneAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(logsControllerDidSave:)]) {
        [_delegate logsControllerDidSave:self];
    }
}


@end
