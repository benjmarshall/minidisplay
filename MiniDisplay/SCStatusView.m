/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import "SCStatusView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SCStatusView

- (void)awakeFromNib {
    CALayer *layer = [CALayer layer];
    [layer setBackgroundColor:[[NSColor blackColor] CGColor]];
    self.wantsLayer = YES;
    self.layer = layer;
}

@end
