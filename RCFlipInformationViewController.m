//
//  FlipInformationViewController.m
//  PageControl
//
//  Created by rcrebs on 6/17/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "RCFlipInformationViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>



@implementation RCFlipInformationViewController

@synthesize delegate, description, pageNumber, navigationBar, attributeText, urlLinkToPhoto, buttonLink;
#pragma mark -
#pragma mark RCWebViewControllerDelegate
-(void)webViewControllerDidFinish:(RCWebViewController *)controller {
	UIDevice *device = [UIDevice currentDevice];
	NSString *osVersion = device.systemVersion;
	
	if ([osVersion floatValue] >= 4.0f) {
		// Dismiss the Flip View
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		[self dismissModalViewControllerAnimated:NO];
	}
	
	[controller release];
}

#pragma mark Action Methods\
#pragma mark -

- (IBAction)done{
	//NSLog(@"Done has been called");
	[self.delegate flipInformationViewControllerDidFinish:self];
}

-(IBAction)callLink
{
	// I am using this because I had to make a hyperlink out of a button
	// The reason was because NSAtributedString is not currently supported on iOS completely [commented by Riley 9/1/2010]
	//NSLog(@"callLink: hello url is %@", self.urlLinkToPhoto);
	
	// Create instance of webview
	RCWebViewController *webVewController = [[RCWebViewController alloc] initWithNibName:@"RCWebViewController" 
																											bundle:nil];
	//  Set the delegate of the view and things for the webview
	webVewController.delegate = self;
	webVewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	webVewController.url = self.urlLinkToPhoto;
	
	/*************************set up title for webview**********************/
	// Get navigation bar items
	NSArray *navItems = navigationBar.items;
	// get the tile item from FlipView and give it RCWebView
	UINavigationItem *navigationBarTitleItem = [navItems objectAtIndex:0];
	webVewController.navTitle = navigationBarTitleItem.title;
	
	UIDevice *device = [UIDevice currentDevice];
	NSString *osVersion = device.systemVersion;
	
	if ([osVersion floatValue] >= 4.0f){
		
		[self presentModalViewController:webVewController animated:YES];
	}
	else {

		[self presentModalViewController:webVewController animated:NO];
	}
	
	
	//[[UIApplication sharedApplication] openURL:self.urlLinkToPhoto];
}
#pragma mark View lifecycle
#pragma mark -

- (void)viewDidLoad {

	
    [super viewDidLoad];
	

	
	// Get Array and specific data for this image.
	NSArray *spesificImageData = [[[AppDelegate sharedAppDelegate].generalImageDataFromServer objectAtIndex:pageNumber] componentsSeparatedByString:@"@&@"];
	// Get navigation bar items
	NSArray *navItems = navigationBar.items;
	// get the tile item
	UINavigationItem *navigationBarTitleItem = [navItems objectAtIndex:0];
	// set the title to the image title
	navigationBarTitleItem.title = [spesificImageData objectAtIndex:0];
	// set description text
	self.description.text = [spesificImageData objectAtIndex:1];
	// set attributeText :: Here I had to use a button on the FlipInformationViewConController.xib file
	// the reason being that iOS doesn't current support NSAtributedString completely [commented by Riley 9/1/2010]
	self.attributeText.textColor = [UIColor blueColor];
	self.attributeText.text = [spesificImageData objectAtIndex:5];
	self.urlLinkToPhoto = [NSURL URLWithString:[spesificImageData objectAtIndex:6]];
	
	// Make sure all the background colors match
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	self.description.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	self.attributeText.backgroundColor = [UIColor viewFlipsideBackgroundColor];
	self.buttonLink.backgroundColor = [UIColor viewFlipsideBackgroundColor];
		
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	// Add rounded corners to the scroll views
	float cornerRadius = 10.0f;
	description.layer.cornerRadius = cornerRadius;
	attributeText.layer.cornerRadius = cornerRadius;

	

	
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return <#number of sections#>;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    return <#number of rows in section#>;
//}
//
//
//// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//    }
//    
//    // Configure the cell...
//    
//    return cell;
//}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Navigation logic may go here. Create and push another view controller.
//	/*
//	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//	 [self.navigationController pushViewController:detailViewController animated:YES];
//	 [detailViewController release];
//	 */
//}
//
//
//#pragma mark -
//#pragma mark Memory management
//
//- (void)didReceiveMemoryWarning {
//    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//    
//    // Relinquish ownership any cached data, images, etc that aren't in use.
//}
//
//- (void)viewDidUnload {
//    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
//    // For example: self.myOutlet = nil;
//}


- (void)dealloc {
    [super dealloc];
}


@end

