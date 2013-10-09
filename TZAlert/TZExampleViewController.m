//
//  TZExampleViewController.m
//  TZAlertExample
//
//  Created by Zhou Hangqing on 13-9-18.
//  Copyright (c) 2013年 Zhou Hangqing. All rights reserved.
//

#import "TZExampleViewController.h"
#import "TZAlert.h"

@interface TZExampleViewController ()

@property (nonatomic, strong) TZAlert *alert;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleForSections;

@end

@implementation TZExampleViewController

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
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

}

- (void)viewWillLayoutSubviews
{
    self.tableView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
- (NSUInteger)supportedInterfaceOrientations {
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationMaskAll;
	
	// iPad only
	return UIInterfaceOrientationMaskLandscape;
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
//		return UIDeviceOrientationIsValidInterfaceOrientation(interfaceOrientation);
        return YES;
    // iPad only
    // iPhone only
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (NSArray *)titleForSections
{
    return @[@"Presentation Style", @"Different content view"];
}

- (NSArray *)titleForRowsInSection:(NSUInteger)section
{
    NSArray *titles;
    if (section == 0) {
        titles = @[@"Alert popover", @"Alert slide down", @"Alert slider up", @"Alert with dim background", @"Alert with modal", @"Alert automatically hide after shown"];
    } else if (section == 1) {
        titles = @[@"Alert with title and content", @"Alert with only title", @"Alert with custom view"];
    }
    return titles;
}



#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleForSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self titleForRowsInSection:section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.titleForSections[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [self titleForRowsInSection:indexPath.section][indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row < 3) {
            [self showAlertWithPresentationStyle:indexPath.row];
        } else if (indexPath.row == 3) {
            [self showAlertWithDimBackground];
        } else if (indexPath.row == 4) {
            [self showAlertWithModal];
        } else if (indexPath.row == 5) {
            [self showAlertAndHideAfterDuration:3];
        }
    } else if (indexPath.section == 1) {
        NSString *title = self.titleForSections[indexPath.section];
        NSString *content = [self titleForRowsInSection:indexPath.section][indexPath.row];
        if (indexPath.row == 0) {
            [self showAlertWithTitleText:title withContentText:content];
        } else if (indexPath.row == 1) {
            [self showAlertWithTitleText:title withContentText:nil];
        }else {
            [self showAlertViewCustomView];
        }
        
    }
}

#pragma mark - Show alert

- (void)showAlertWithPresentationStyle:(TZAlertPresentationStyle)style
{
    self.alert = [[TZAlert alloc] initWithView:self.view];
    [self.view addSubview:self.alert];
    self.alert.titleText = @"Test Alert";
    self.alert.contentText = @"This is the alert for testing";
    self.alert.presentationStyle = style;
    
    if (style == TZAlertPresentationStyleSlideDown || style == TZAlertPresentationStyleSlideUp) {
        self.alert.defaultSize = CGSizeMake(self.view.window.bounds.size.width * 0.5, self.view.window.bounds.size.height * 0.1);
    }
    
    [self.alert showWithAnimated:YES];
}

- (void)showAlertWithDimBackground
{
    self.alert = [[TZAlert alloc] initWithView:self.view];
    [self.view addSubview:self.alert];
    self.alert.presentationStyle = TZAlertPresentationStyleSlideDown;
    self.alert.titleText = @"Test";
    self.alert.contentText = @"This is the alert with dim background";
    self.alert.defaultSize = CGSizeMake(self.view.window.bounds.size.width * 0.5, self.view.window.bounds.size.height * 0.1);
    self.alert.color = [UIColor colorWithRed:0.24f green:0.35f blue:0.49f alpha:1];
    self.alert.dimBackground = YES;
    
    [self.alert show];
}

- (void)showAlertWithModal
{
    self.alert = [[TZAlert alloc] initWithView:self.view];
    [self.view addSubview:self.alert];
    self.alert.presentationStyle = TZAlertPresentationStyleSlideDown;
    self.alert.titleText = @"Test";
    self.alert.contentText = @"This is the alert with modal ";
    self.alert.defaultSize = CGSizeMake(self.view.window.bounds.size.width * 0.5, self.view.window.bounds.size.height * 0.1);
    self.alert.color = [UIColor colorWithRed:0.24f green:0.35f blue:0.49f alpha:1];
    self.alert.dimBackground = YES;
    
    self.alert.isModal = YES;
    
    [self.alert show];
}


- (void)showAlertAndHideAfterDuration:(NSTimeInterval)duration
{
    self.alert = [[TZAlert alloc] initWithView:self.view];
    [self.view addSubview:self.alert];
    self.alert.presentationStyle = TZAlertPresentationStyleSlideDown;
    self.alert.titleText = @"Test";
    self.alert.contentText = @"Now, i am really doing the test";
    self.alert.defaultSize = CGSizeMake(self.view.window.bounds.size.width * 0.5, self.view.window.bounds.size.height * 0.1);
    
    [self.alert showAndHideAfterDuration:duration];
}

- (void)showAlertWithTitleText:(NSString *)title withContentText:(NSString *)content
{
    self.alert = [[TZAlert alloc] initWithView:self.view];
    [self.view addSubview:self.alert];
    self.alert.presentationStyle = TZAlertPresentationStyleSlideDown;
    self.alert.titleText = title;
    self.alert.contentText = content;
    self.alert.defaultSize = CGSizeMake(self.view.window.bounds.size.width * 0.5, self.view.window.bounds.size.height * 0.1);
    self.alert.isModal = NO;
    
    [self.alert showWithAnimated:YES];
}

- (void)showAlertViewCustomView
{
    self.alert = [[TZAlert alloc] initWithView:self.view];
    [self.view addSubview:self.alert];
    self.alert.presentationStyle = TZAlertPresentationStylePopUp;
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    customView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:customView.bounds];
    [customView addSubview:label];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"I'm a custom view";
    label.textColor = [UIColor darkTextColor];
    label.backgroundColor = [UIColor clearColor];
    label.center = CGPointMake(customView.bounds.size.width * 0.5, customView.bounds.size.height * 0.5);
    
    self.alert.customView = customView;
    
    self.alert.isModal = YES;

    [self.alert showWithAnimated:YES];

}

@end
