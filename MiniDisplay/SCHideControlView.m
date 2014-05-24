/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import "SCHideControlView.h"

@interface SCAppDelegate : NSObject <NSApplicationDelegate>

- (IBAction)collapseClicked:(id)sender;

@end

@implementation SCHideControlView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    [(SCAppDelegate*)[NSApp delegate] collapseClicked:self];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    [self.window mouseDragged:theEvent];
}

@end
