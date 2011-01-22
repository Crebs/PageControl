//
//  RCWebViewController.m
//  PageControl
//
//  Created by rcrebs on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RCWebViewController.h"
#import "AppDelegate.h"

@implementation RCWebViewController

@synthesize delegate, url, webView;
@synthesize backButton, forwardButton, safariButton;
@synthesize safariLoadIndicator;
@synthesize buttonItem;
@synthesize webViewNavBar, navTitle;
//@synthesize webViewToolBar;

#pragma mark -
#pragma mark ActionMethods
-(IBAction)done {
	// Takes the image of RCWebViewController's delegate, and all this method for the delegate to then execute.
	[self.webView stopLoading];
	[self.delegate webViewControllerDidFinish:self];
}

-(IBAction)back {
	[self.webView goBack];
}

-(IBAction)forward{
	[self.webView goForward];
}

-(IBAction)openInSafari {
	UIActionSheet *usageActionSheet = [[UIActionSheet alloc] initWithTitle:nil
																					 delegate:self 
																		 cancelButtonTitle:@"Cancel" 
																  destructiveButtonTitle:nil
																		 otherButtonTitles:@"Go to Safari", nil];
	
	[usageActionSheet showInView:[AppDelegate sharedAppDelegate].view];
	//[usageActionSheet showFromToolbar:self.webViewToolBar];
	//[usageActionSheet showFromBarButtonItem:buttonItem animated:YES];
	
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

#pragma mark -
#pragma mark UIWebViewDelegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
	
	// Show and start UIActivityIndicatorView
	[self.safariLoadIndicator startAnimating];
	self.webView.scalesPageToFit = YES;
	// Check if back forward buttons are clickable for user
	if ([self.webView canGoBack]) {
		backButton.enabled = YES;
	}
	else {
		backButton.enabled = NO;
	}
	
	if ([self.webView canGoForward]) {
		forwardButton.enabled = YES;
	}
	else {
		forwardButton.enabled = NO;
	}
	
}
	 
-(void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.safariLoadIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

}

#pragma mark -
#pragma mark UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// buttonIndex 1: cancel button clicked
	// buttonIndex 0: Go to safari button clicked
	switch (buttonIndex) {
		case 0:
			[[UIApplication sharedApplication] openURL:self.url];
			break;
	}
}

#pragma mark -
#pragma mark Other Delegate Methods
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:request]; 
	
	// Get navigation bar items
	NSArray *navItems = webViewNavBar.items;
	// get the tile item
	UINavigationItem *navigationBarTitleItem = [navItems objectAtIndex:0];
	// set the title to the image title
	navigationBarTitleItem.title = navTitle;
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
