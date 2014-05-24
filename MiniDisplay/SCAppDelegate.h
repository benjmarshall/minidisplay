/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import <Cocoa/Cocoa.h>
#import "SCWindow.h"

@interface SCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSView *bgView;
@property (strong) IBOutlet NSMenu *appMenu;
@property (weak) IBOutlet NSView *endView;
- (void)setCurrentWidth:(long long)newCurrentWidth;
- (void)recalculateSubviews;
@end
