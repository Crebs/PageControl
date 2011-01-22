/*
     File: MyViewController.m
 Abstract: A controller for a single page of content. For this application, pages simply display text on a colored background. The colors are retrieved from a static color list.
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
#pragma mark -

#import "MyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"



static NSMutableArray *__pageControlWallpaperList = nil;

@implementation MyViewController

@synthesize imageView;


#pragma mark -
#pragma mark Member Functions
-(void)refreshImageAtIndex:(int)page
{
	if (self.imageView.image == nil) {
		//NSLog(@"refresh page number %i", page);
		NSArray *spesificImageData = [[[AppDelegate sharedAppDelegate].generalImageDataFromServer objectAtIndex:page] componentsSeparatedByString:@"@&@"];
		// Each image has specific data pulled from the Appible server.
		NSURL *url = [NSURL URLWithString:[spesificImageData objectAtIndex:2]];
		// Try to get image from phone first so we can check to see if it needs to be downloaded again
		//NSLog(@"file is %@", [[self applicationsDocumentsDirectory] stringByAppendingPathComponent:[url lastPathComponent]]);
		
		if (self.imageView.image == nil) {
			//NSLog(@"Image name is %@", [[self applicationsDocumentsDirectory] stringByAppendingPathComponent:[url lastPathComponent]]);
			
			
			imageView.image = [UIImage imageWithContentsOfFile:[[self applicationsDocumentsDirectory] stringByAppendingPathComponent:[url lastPathComponent]]];
			
			// Gets the Core Animation Layer and adds a boarder to it
			CALayer *layer = [imageView layer];
			layer.borderWidth = 1.0f;
		}
	}



}

-(NSString*)applicationsDocumentsDirectory
{
	NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	return [searchPaths objectAtIndex:0];
	
}

-(void)toggleNavBarAndToolBarVisible{
	
	if (![AppDelegate sharedAppDelegate].toolBarLocked) {
		[UIView beginAnimations:@"hidden" context:nil];
		[UIView setAnimationDuration:1.0f];
		[UIView setAnimationBeginsFromCurrentState:YES];
		//[UINavigationBar setAnimationDelay:2.0f];
		
		if ([AppDelegate sharedAppDelegate].navigationBar.alpha == 0.0f) {
			[AppDelegate sharedAppDelegate].navigationBar.alpha = 0.9f;
			[AppDelegate sharedAppDelegate].toolBar.alpha = 0.9f;
			// [application setStatusBarHidden:FALSE withAnimation:UIStatusBarAnimationSlide];
		}
		else
		 {
			
			[AppDelegate sharedAppDelegate].navigationBar.alpha = 0.0f;
			[AppDelegate sharedAppDelegate].toolBar.alpha = 0.0f;
			
		 }
		[UIView commitAnimations];
	}
}





// Creates the color list the first time this method is invoked. Returns one color object from the list.
- (id)pageControlWallpaperWithIndex:(NSUInteger)index {

	if (__pageControlWallpaperList == nil) {
		return @"nil";
	}

	// Mod the index by the list length to ensure access remains in bounds.
	return [__pageControlWallpaperList objectAtIndex:index % [__pageControlWallpaperList count]];
}

#pragma mark -
#pragma mark Action Methods



#pragma mark -
#pragma mark FlipInfoDelegate
-(void)flipInformationViewControllerDidFinish:(RCFlipInformationViewController *)controller{
	
	UIDevice *device = [UIDevice currentDevice];
	NSString *osVersion = device.systemVersion;
	
	if ([osVersion floatValue] >= 4.0f) {
		// Dismiss the Flip View
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		[self dismissModalViewControllerAnimated:NO];
	}

	// Need to let the UIScrollView work again
	[AppDelegate sharedAppDelegate].scrollView.scrollEnabled = YES;
	[self toggleNavBarAndToolBarVisible];

}


#pragma mark -
#pragma mark TouchEvents
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self toggleNavBarAndToolBarVisible];
	
}



#pragma mark -
// Load the view nib and initialize the pageNumber ivar.
- (id)initWithPageNumber:(int)page {
	//NSLog(@"init with page number");
    if (self = [super initWithNibName:@"MyView" bundle:nil]) {
        pageNumber = page;
		 [self refreshImageAtIndex:page];
    }
    return self;
}

-(id)initWithOutPageNumberZero
{
	if (self = [super initWithNibName:@"MyView" bundle:nil]) {
		pageNumber = 0;
		
		// Put Load screen on until image is downloaded
		UIImage *image = [UIImage imageNamed:@"Default.png"];
		if (image != nil) {
			self.imageView.image = image;
			//NSLog(@"Defalt image set");
		}
		else {
			//NSLog(@"Defalt image not found");
		}
	}
	return self;
}

- (void)dealloc {
	 [imageView release];
    [super dealloc];
}


// Set the label and background color when the view has finished loading.
- (void)viewDidLoad {
	
//	if ((imageView.image = [UIImage imageNamed:[self pageControlWallpaperWithIndex:pageNumber]]) == nil) 
//	{
//	  [self getWallpaperImagesFromAppilbeServerUsingURLConnection];
//	}
}

@end
