//
//  RCWebViewController.h
//  PageControl
//
//  Created by rcrebs on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RCWebViewControllerDelegate;

@interface RCWebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	id <RCWebViewControllerDelegate> delegate;
	NSURL *url;
	UIWebView *webView;
	UIBarButtonItem *backButton, *forwardButton, *safariButton;
	UIActivityIndicatorView *safariLoadIndicator;
	UINavigationBar *webViewNavBar;
	NSString *navTitle;
	
}
@property (nonatomic, retain) IBOutlet NSString *navTitle;
@property (nonatomic, retain) IBOutlet UINavigationBar *webViewNavBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *buttonItem;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *safariLoadIndicator;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *forwardButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *safariButton;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) id<RCWebViewControllerDelegate> delegate;

// Methods
-(IBAction)done;
-(IBAction)back;
-(IBAction)forward;
-(IBAction)openInSafari;
@end

@protocol RCWebViewControllerDelegate
-(void)webViewControllerDidFinish:(RCWebViewController *)controller;
@end
