/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import <Cocoa/Cocoa.h>
#import "SCAppDelegate.h"

@interface SCMemoryView : NSView
@property (strong) IBOutlet NSTextField *freeLabel;
@property (strong) IBOutlet NSTextField *auxLabel;
@end
