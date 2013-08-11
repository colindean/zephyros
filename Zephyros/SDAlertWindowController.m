//
//  SDAlertWindowController.m
//  Zephyros
//
//  Created by Steven on 4/14/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDAlertWindowController.h"

#import <QuartzCore/QuartzCore.h>

#import "SDAPI.h"

@interface SDAlertWindowController ()

@property IBOutlet NSTextField* textField;
@property IBOutlet NSBox* box;

@end

@implementation SDAlertWindowController

+ (SDAlertWindowController*) sharedAlertWindowController {
    static SDAlertWindowController* sharedAlertWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAlertWindowController = [[SDAlertWindowController alloc] init];
        sharedAlertWindowController.alertDisappearDelay = 1.0;
    });
    return sharedAlertWindowController;
}

- (NSString*) windowNibName {
    return @"AlertWindow";
}

- (void) setAlertAnimates:(BOOL)alertAnimates {
    self.window.animationBehavior = (alertAnimates ? NSWindowAnimationBehaviorAlertPanel : NSWindowAnimationBehaviorNone);
}

- (void) windowDidLoad {
    self.window.styleMask = NSBorderlessWindowMask;
    self.window.backgroundColor = [NSColor clearColor];
    self.window.opaque = NO;
    self.window.level = NSFloatingWindowLevel;
    self.window.ignoresMouseEvents = YES;
    self.window.animationBehavior = NSWindowAnimationBehaviorAlertPanel;
//    self.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorStationary;
}

- (void) show:(NSString*)oneLineMsg delay:(NSNumber*)delay {
    if (delay == nil || delay == (id)[NSNull null])
        delay = @(self.alertDisappearDelay);
    
    NSDisableScreenUpdates();
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeWindowOut) object:nil];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(closeAndResetWindow) object:nil];
    
    [self closeAndResetWindow];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.01];
    [[[self window] animator] setAlphaValue:1.0];
    [NSAnimationContext endGrouping];
    
    [self useTitleAndResize:[oneLineMsg description]];
    
    [self.window center];
    [self showWindow:self];
    
    [self performSelector:@selector(fadeWindowOut) withObject:nil afterDelay:[delay doubleValue]];
    
    NSEnableScreenUpdates();
}

- (void) fadeWindowOut {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.15];
    [[[self window] animator] setAlphaValue:0.0];
    [NSAnimationContext endGrouping];
    
    [self performSelector:@selector(closeAndResetWindow) withObject:nil afterDelay:0.15];
}

- (void) closeAndResetWindow {
    [[self window] orderOut:nil];
    [[self window] setAlphaValue:1.0];
}

- (void) useTitleAndResize:(NSString*)title {
    [self window]; // sigh; required in case nib hasnt loaded yet
    
    self.textField.stringValue = title;
    [self.textField sizeToFit];
    
	NSRect windowFrame = [[self window] frame];
	windowFrame.size.width = [self.textField frame].size.width + 32.0;
	windowFrame.size.height = [self.textField frame].size.height + 24.0;
	[[self window] setFrame:windowFrame display:YES];
}

@end
