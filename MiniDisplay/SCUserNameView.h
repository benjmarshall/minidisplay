/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import <Cocoa/Cocoa.h>

@interface SCUserNameView : NSView
@property (strong) IBOutlet NSTextField *nameField;
@property (strong) IBOutlet NSTextFieldCell *nameInner;

@end
