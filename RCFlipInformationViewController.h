//
//  FlipInformationViewController.h
//  PageControl
//
//  Created by rcrebs on 6/17/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCWebViewController.h"

@protocol FlipInformationViewControllerDelegate;

@interface RCFlipInformationViewController : UIViewController <RCWebViewControllerDelegate>{
	id <FlipInformationViewControllerDelegate> delegate;
	UITextView *description;
	int pageNumber;
	UINavigationBar *navigationBar;
	UITextView *attributeText;
	
	UIButton *buttonLink;
	NSURL *urlLinkToPhoto;
	
}

@property (assign) int pageNumber;

@property (nonatomic, assign) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, assign) IBOutlet UITextView *description;
@property (nonatomic, assign) IBOutlet UITextView *attributeText;
@property (nonatomic, assign) IBOutlet UIButton *buttonLink;
@property (nonatomic, retain) NSURL *urlLinkToPhoto;
@property (nonatomic, assign) id<FlipInformationViewControllerDelegate> delegate;

// Methonds
-(IBAction)done;
-(IBAction)callLink;
@end

@protocol FlipInformationViewControllerDelegate
-(void)flipInformationViewControllerDidFinish:(RCFlipInformationViewController *)controller;
@end
