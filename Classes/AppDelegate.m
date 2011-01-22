/*
     File: AppDelegate.m
 Abstract: Application and scroll view delegate. This object manages the view controllers which are the pages in the scroll view.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import "AppDelegate.h"
#import "MyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"

static NSUInteger kNumberOfPages = 0;

@interface AppDelegate (PrivateMethods)
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation AppDelegate
@synthesize window, toolBarLocked, scrollView, pageControl, viewControllers, /*usageAlertView,*/ navigationBar, toolBar, generalImageDataFromServer, activityIndicatorView, url, fileStream, connection, filePath;
@synthesize view;


#pragma mark -
#pragma mark Member Functions
#pragma mark -
/********************************************************************
 *	Author:
 *		Riley Crebs (got from Apple's SimpleFTP Sample Code)
 *
 *	Parameters:
 *		NONE
 *
 *	Description:
 *		This will be used to return the instance of the AppDelegate. 
 *
 *	Date:
 *		June 29, 2010
 *
 *	Modified: <TBA>
 ********************************************************************/
//-(id)init{
//	
//	if (self = [super init]) {
//		// Create a thread to get images from server.
////		loadImages = [[NSThread alloc] initWithTarget:self selector:@selector(getTheImagesDataFromAppibleServer:) object:nil];
////		[loadImages start];
//		
//	}
//	
//	return self;
//}

+ (AppDelegate *)sharedAppDelegate
{
	return (AppDelegate *) [UIApplication sharedApplication].delegate;
}

-(void)endAnimation{
	[UIView commitAnimations];
}

-(void)beginAnimaitonNamed:(NSString*)nameOfAnimation{
	[UIView beginAnimations:nameOfAnimation context:nil];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationBeginsFromCurrentState:YES];
}
-(void)fadeOutNavigationBarAndToolbar:(BOOL)fadOut withAnimation:(BOOL)animaiton{

	// Check if animaiton is wanted and beginAnimaiton
   if (animaiton) {
		// Calls UIView Core Animation Stuff
		[self beginAnimaitonNamed:@"hidden"];
	}
	
	if (fadOut) {
		self.navigationBar.alpha = 0.0f;
		self.toolBar.alpha = 0.0f;
	}
	else {
		
		self.navigationBar.alpha = 0.9f;
		self.toolBar.alpha = 0.9f;
	}
	
	// Check if animaiton was wanted and end Animation
	if (animaiton) {
		// Calls memeber function that calles Core Animation stuff 
		[self endAnimation];
	}
	
	
}
- (IBAction)showInfo {    

	if (!scrollView.decelerating) {
		// Disable Scrolling when the info button is pressed. This make so you are locked into the Flip view (prevents a lot of bugs).
		scrollView.scrollEnabled = NO;
		
		// Fade out the Navigation and Tool bars so the Flip view is not abstracted (prevents a lot of bugs as well).
		[self fadeOutNavigationBarAndToolbar:YES withAnimation:YES];
		
		// Get the ViewController for the Image in view
		MyViewController *myViewController = [viewControllers objectAtIndex:[self pageNumber]];
		
		// Create a Flip view
		RCFlipInformationViewController *controller = [[RCFlipInformationViewController alloc] initWithNibName:@"FlipInformationViewController"
																																  bundle:nil];
		controller.pageNumber = [self pageNumber]; // Tell the flipviewcontroller what page it is on.
		
		// Make the ViewController that has the Image is the delegate of the Flip view so the Flip will be dismissed at the correct place in the scrollview.
		controller.delegate = myViewController;
		
		controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		
		// TODO: create a macro for this
		// Get the device number
		UIDevice *device = [UIDevice currentDevice];
		NSString *osVersion = device.systemVersion;
		
		if ([osVersion floatValue] >= 4.0f){
			
			[myViewController presentModalViewController:controller animated:YES];
		}
		else {
			// This is to fix a bug. When the FlipInformationViewController flips it's frame is lost
			// I am not using animation because it cause some bugs currently
			controller.view.frame = myViewController.view.frame;
			[myViewController presentModalViewController:controller animated:NO];
		}
		
		[controller release];
	}

}

- (int)pageNumber
{
   // Switch the indicator when more than 50% of the previous/next page is visible
	CGFloat pageWidth = scrollView.frame.size.width;
	int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	return pageControl.currentPage = page;	
}

-(NSString*)applicationsDocumentsDirectory
{
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	return [searchPaths objectAtIndex:0];
	
}

- (void)writeData:(NSData *)data
// A delegate method called by the NSURLConnection as data arrives.  We just 
// write the data to the file.
{
	NSLog(@"wiritng to disk");
	//[AppDelegate sharedAppDelegate].scrollView.scrollEnabled = NO;
#pragma unused(theConnection)
	NSInteger       dataLength;
	const uint8_t * dataBytes;
	NSInteger       bytesWritten;
	NSInteger       bytesWrittenSoFar;
	
	//assert(theConnection == self.connection);
	
	dataLength = [data length];
	dataBytes  = [data bytes];
	
	//NSLog(@"didReceiveData");
	bytesWrittenSoFar = 0;
	
	// Keep writting until all data give to the delegate method are written.
	do {
		bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
		
		//NSLog(@"bytesWritten %i", bytesWritten);
		
		assert(bytesWritten != 0);
		if (bytesWritten == -1) {
			// TODO: Check for failure when writting file to device.
			//[self _stopReceiveWithStatus:@"File write error"];
			break;
		} else {
			bytesWrittenSoFar += bytesWritten;
		}
		
	} while (bytesWrittenSoFar != dataLength);
}

- (void)_receiveDidStopWithStatus:(NSString *)statusString
{
	
}

- (void)_stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil) 
// or the error status (otherwise).
{
	if (self.connection != nil) {
		[self.connection cancel];
		self.connection = nil;
	}
	if (self.fileStream != nil) {
		[self.fileStream close];
		self.fileStream = nil;
	}
	[self _receiveDidStopWithStatus:statusString];
	self.filePath = nil;
}



#pragma mark -
#pragma mark TouchEvents
#pragma mark -
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//	NSLog(@"touchHappend in AppDelegate");
}


#pragma mark -
#pragma mark SEL methods
#pragma mark -
- (void)savePickture
{
  
	// Alert that an image is about to be saved.
	NSString *message = @"Do you want to save this wallpaper to your Photo app?";
	UIAlertView *usageAlertView = [[UIAlertView alloc] initWithTitle:@"Confirm Download" message:message delegate:self cancelButtonTitle:@"Download" otherButtonTitles:@"Cancel", nil ];
	[usageAlertView show];
	
   
}

- (void) image: (UIImage *) image
didFinishSavingWithError: (NSError *) error
	contextInfo: (void *) contextInfo
{
	// TODO: Need to add Error Checking. See if there are Errors when adding pictures to the Photo Album of iPhone
	// Alert that an image is about to be saved.
	NSString *message = @"This wallpaper has been saved to your Photo app. You can now set it as your wallpaper from the Photos app.";
	UIAlertView *usageAlertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
	[usageAlertView show];
}

/********************************************************************
 *	Author:
 *		Riley Crebs
 *
 *	Decriptions:
 *		Gets the first image from the server.
 *******************************************************************/
-(void)getTheFirstImageFromServer
{
	[self fadeOutNavigationBarAndToolbar:YES withAnimation:YES];
	self.toolBarLocked = YES;
	
	NSError **error = nil; // TODO: leran how to use NSError
	
	NSString *dataFromServer	= [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://appible.net/wallapps/jb9WS7B8bN1WilWcTzcNbZdNOl3W9qeVKlEMMBvITQW/realtree-1/feed.php"] encoding:NSUTF8StringEncoding error:error];
	
	// TODO: instead of the an array USE CORE DATA
	generalImageDataFromServer = [dataFromServer componentsSeparatedByString:@"$@$"];
	[generalImageDataFromServer retain];

	if ([generalImageDataFromServer count]) {
		// Set the static value of images for this application
		kNumberOfPages = [generalImageDataFromServer count];
		
		// Parse all the image data from the generalImageData String that was sent by the server.
		// view controllers are created lazily
		// in the meantime, load the array with placeholders which will be replaced on demand
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		// Make room for all the controller views in our controller array to keep track of arrays
		for (int i = 0; i < [generalImageDataFromServer count]; ++i) {
			[controllers addObject:[NSNull null]];
		}
		
		// TODO: may need to release controllers 
		self.viewControllers = controllers;
		
		// Each image has specific data pulled from the Appible server.
		NSArray *specifecImageData;
		specifecImageData = [[[AppDelegate sharedAppDelegate].generalImageDataFromServer objectAtIndex:0] componentsSeparatedByString:@"@&@"]; 
		self.url = [NSURL URLWithString:[specifecImageData objectAtIndex:2]];
		
		// Try to get image from phone first so we can check to see if it needs to be downloaded again
		//NSLog(@"file is %@",[[self applicationsDocumentsDirectory] stringByAppendingPathComponent:[self.url lastPathComponent]]);
		UIImage *image = [UIImage imageWithContentsOfFile:[[self applicationsDocumentsDirectory] stringByAppendingPathComponent:[self.url lastPathComponent]]];
		
		// If image doesn't exist write the image data to phone
		if (image == nil) {
			
			// Get the file path to write to
			self.filePath = [[self applicationsDocumentsDirectory] stringByAppendingPathComponent:[self.url lastPathComponent]]; 
			
			// Create an outputsteam to write to flash using the file path.
			self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
			[fileStream open];
			
			// Get data from URL and write to phone
			//				if ([self.activityIndicatorView isAnimating]) {
			//					NSLog(@"activity indicator should be spinning, should be spinning");
			//				}
			//				else {
			//					[self.activityIndicatorView startAnimating];
			//					NSLog(@"not spinning");
			//				}
			
			NSData *data = [NSData dataWithContentsOfURL:self.url];			
			[self writeData:data];
		}
		
		[generalImageDataFromServer retain];
		// a page is the width of the scroll view
		scrollView.pagingEnabled = YES;
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
		scrollView.showsHorizontalScrollIndicator = YES;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.scrollsToTop = NO;
		scrollView.delegate = self;
		scrollView.scrollEnabled = YES;
		
		// pages are created on demand
		// load the visible page
		// load the page on either side to avoid flashes when the user starts scrolling
		[self loadScrollViewWithPage:0];
		//	[self loadScrollViewWithPage:1];
		
		int page = [self pageNumber];
		
		[[viewControllers objectAtIndex:(page) % [generalImageDataFromServer count]] refreshImageAtIndex: page];
				
	}
	else {
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reachability" message:@"Could not connect to server. Please check your internet connection. The application will now close." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
		
		[alertView show];
		
		[self autorelease];
		
	}
	
}

/********************************************************************
 *	Author:
 *		Riley Crebs
 *
*	Decriptions:
 *		Called by NSThread. This is called by a seperate thread to load images from the server.
 ********************************************************************/
- (void) getTheImagesDataFromAppibleServer: (id)data {
	
	/*****************************************************************
	 *   Arrays are separated by $@$ and items within the arrays are separated by @&@
	 *   Each array consists of the following information:
	 *   Title
	 *   Description
	 *   URL of 320x480 image
	 *   URL of 640x960 image
	 *   URL of 1024x1024 image
	 *   Attribution text
	 *   Attribution URL
	 *****************************************************************/
	
	// This gets data from the server with a sertain URL. This data will be used to get each image from the server.

	
	//	//TODO: Instead of pulling form an Array, Use Core Data
	NSArray *specifecImageData;
	self.scrollView.scrollEnabled = NO;
//	self.activityIndicatorView.hidesWhenStopped = NO;
	[self.activityIndicatorView startAnimating];
	
	//  Check the data we got from the serever and see if we need to download any images
	for (int i = 1; i < kNumberOfPages; ++i) {
		//[self.activityIndicatorView startAnimating];
		if ([self.activityIndicatorView isAnimating]) {
			NSLog(@"Animateing");
		}
		// Each image has specific data pulled from the Appible server.
		specifecImageData = [[[AppDelegate sharedAppDelegate].generalImageDataFromServer objectAtIndex:i] componentsSeparatedByString:@"@&@"]; 
		self.url = [NSURL URLWithString:[specifecImageData objectAtIndex:2]];
		
		// Try to get image from phone first so we can check to see if it needs to be downloaded again
		//NSLog(@"file is %@",[[self applicationsDocumentsDirectory] stringByAppendingPathComponent:[self.url lastPathComponent]]);
		UIImage *image = [UIImage imageWithContentsOfFile:[[self applicationsDocumentsDirectory] stringByAppendingPathComponent:[self.url lastPathComponent]]];
		
		// If image doesn't exist write the image data to phone
		if (image == nil) {
			
			// Get the file path to write to
			self.filePath = [[self applicationsDocumentsDirectory] stringByAppendingPathComponent:[self.url lastPathComponent]]; 
			
			// Create an outputsteam to write to flash using the file path.
			self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
			[fileStream open];
				
				// Get data from URL and write to phone
//				if ([self.activityIndicatorView isAnimating]) {
//					NSLog(@"activity indicator should be spinning, should be spinning");
//				}
//				else {
//					[self.activityIndicatorView startAnimating];
//					NSLog(@"not spinning");
//				}
				
			NSData *data = [NSData dataWithContentsOfURL:self.url];			
			[self writeData:data];
				
		}
			
	}
//	self.activityIndicatorView.hidesWhenStopped = YES;
	[self.activityIndicatorView stopAnimating];
	self.scrollView.scrollEnabled = YES;
	self.toolBarLocked = NO;
	
	[self loadScrollViewWithPage:1 % [generalImageDataFromServer count]];
	[self loadScrollViewWithPage:2 % [generalImageDataFromServer count]];
}

#pragma mark -
#pragma mark UIAlertView Delegate Methods 
#pragma mark -
- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

	// Make sure the specific Alert only gets called for down loading the image 
	if (alertView.title == @"Confirm Download") {
		//Do condition checking for  Button Indexs
		if (buttonIndex == 0) {
			// From the array of  View Controllers the currenlty viewed View Controller is selected 
			// Then the image is pointed to in the viewController pulled from the array
			// Then the image is saved to the PhotoAlbum of the iPhone
			MyViewController *currentlyViewedViewController  = [viewControllers objectAtIndex:[self pageNumber]]; 
			UIImage *thisImage = currentlyViewedViewController.imageView.image;
			UIImageWriteToSavedPhotosAlbum(thisImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
		}
	}
	else if (alertView.title == @"Reachability") {
		[self getTheImagesDataFromAppibleServer:nil];
	}
	
	[alertView autorelease];
}

#pragma mark -
#pragma mark AppDelegate Methods
#pragma mark -
#pragma mark -
- (void)dealloc {
	[viewControllers release];
	[scrollView release];
	[pageControl release];
	[window release];
	[loadImages release];
	[view release];
	[super dealloc];
}

//- (void)applicationDidBecomeActive:(UIApplication *)application{
//	NSLog(@"Becoming active");
//}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self getTheFirstImageFromServer];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	//Check reachability
	Reachability *reachability = [Reachability reachabilityForInternetConnection];
	[reachability userInterfaceFeedBackByAnAlertWindow:[reachability currentReachabilityStatus]];
}


#pragma mark -
#pragma mark NSScrollView Delegate Methods
#pragma mark -
- (void)loadScrollViewWithPage:(int)page {
	// TODO: need to figure out how to make it so only 5 images are currenly in the scroll view. As the scroll view is slid this will need to be done dynamically. Roveing the out view and shiffing the scrollviwe to the center and adding a new view to the oppisite end.
	

	
   if (page < 0) return;
   if (page >= [generalImageDataFromServer count]) return;

    // replace the placeholder if necessary
	NSLog(@"page number is %i and viewcontroller count is %i", page, [viewControllers count]);
    MyViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {

        controller = [[MyViewController alloc] initWithPageNumber:page];
		 
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }

    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
		  
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
		 
    }
	
	
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	
	if (self.scrollView.scrollEnabled) {
		// We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
		// which a scroll event generated from the user hitting the page control triggers updates from
		// the delegate method. We use a boolean to disable the delegate logic when the page control is used.
		if (pageControlUsed) {
			// do nothing - the scroll was initiated from the page control, not the user dragging
			return;
		}
		
		// Switch the indicator when more than 50% of the previous/next page is visible
		int page = [self pageNumber];
		
		// load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
		
		[self loadScrollViewWithPage:page - 1];
		[self loadScrollViewWithPage:page];
		[self loadScrollViewWithPage:page + 1];
		[self loadScrollViewWithPage:page + 2];
		[self loadScrollViewWithPage:page + 3];
//		[self loadScrollViewWithPage:page + 4];
		
		
		
		// A possible optimization would be to unload the views+controllers which are no longer visible
	}

}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	//TODO: Need to clean up once I get this error.
	NSLog(@"Crap free up some memory!");
}
// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
	if (self.scrollView.scrollEnabled) {
		pageControlUsed = NO;
		int page = [self pageNumber];
		//NSLog(@"Current page is %i", page);
		
		NSArray *spesificImageData = [[[AppDelegate sharedAppDelegate].generalImageDataFromServer objectAtIndex:page] componentsSeparatedByString:@"@&@"];
		[AppDelegate sharedAppDelegate].navigationBar.topItem.title = [spesificImageData objectAtIndex:0];
		[[viewControllers objectAtIndex:(page + 1) % [generalImageDataFromServer count]] refreshImageAtIndex: (page + 1) % [generalImageDataFromServer count]];
	}	
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	if (self.scrollView.scrollEnabled) {
		pageControlUsed = NO;
		int page = [self pageNumber];
		
		NSArray *spesificImageData = [[[AppDelegate sharedAppDelegate].generalImageDataFromServer objectAtIndex:page] componentsSeparatedByString:@"@&@"];
		[AppDelegate sharedAppDelegate].navigationBar.topItem.title = [spesificImageData objectAtIndex:0];
		
		[[viewControllers objectAtIndex:(page) % [generalImageDataFromServer count]] refreshImageAtIndex: page];
		[[viewControllers objectAtIndex:(page + 1) % [generalImageDataFromServer count]] refreshImageAtIndex: (page + 1) % [generalImageDataFromServer count]];
		[[viewControllers objectAtIndex:(page + 2) % [generalImageDataFromServer count]] refreshImageAtIndex:(page + 2) % [generalImageDataFromServer count]];
		[[viewControllers objectAtIndex:(page + 3) % [generalImageDataFromServer count]] refreshImageAtIndex: (page + 3) % [generalImageDataFromServer count]];
	}
	
}

- (IBAction)changePage:(id)sender {

    int page = pageControl.currentPage;
	[[viewControllers objectAtIndex:page] refreshImageAtIndex: page];
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

#pragma mark -
#pragma mark NSURLConnection delegate methods
#pragma mark -


@end
