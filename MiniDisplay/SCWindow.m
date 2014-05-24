/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import "SCWindow.h"

/* Code mostly stolen from a stackoverflow question here. */
@implementation SCWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    if (!(self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag])) return nil;
    [self setBackgroundColor: [NSColor clearColor]];
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
    // Get the mouse location in window coordinates.
    self.initialLocation = [theEvent locationInWindow];
}

/*
 Once the user starts dragging the mouse, move the window with it. The window has no title bar for
 the user to drag (so we have to implement dragging ourselves)
 */
- (void)mouseDragged:(NSEvent *)theEvent {
    NSRect screenVisibleFrame = [[NSScreen mainScreen] visibleFrame];
    NSRect windowFrame = [self frame];
    NSPoint newOrigin = windowFrame.origin;
    
    // Get the mouse location in window coordinates.
    NSPoint currentLocation = [theEvent locationInWindow];
    // Update the origin with the difference between the new mouse location and the old mouse location.
    newOrigin.x += (currentLocation.x - self.initialLocation.x);
    newOrigin.y += (currentLocation.y - self.initialLocation.y);
    
    // Don't let window get dragged up under the menu bar
    if ((newOrigin.y + windowFrame.size.height) > (screenVisibleFrame.origin.y + screenVisibleFrame.size.height)) {
        newOrigin.y = screenVisibleFrame.origin.y + (screenVisibleFrame.size.height - windowFrame.size.height);
    }
    if (newOrigin.x < 0) {
        newOrigin.x = 0;
    }
    
    // Move the window to the new location
    [self setFrameOrigin:newOrigin];
}

@end
