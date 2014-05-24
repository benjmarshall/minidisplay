/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import <Cocoa/Cocoa.h>

@interface SCNetView : NSView
@property (strong) IBOutlet NSTextField *inNum;
@property (strong) IBOutlet NSTextField *inAux;
@property (strong) IBOutlet NSTextField *outNum;
@property (strong) IBOutlet NSTextField *outAux;
@end
