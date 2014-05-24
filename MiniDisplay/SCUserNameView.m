/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#include <stdlib.h>
#include <unistd.h>
#import "SCUserNameView.h"
#import "NS(Attributed)String+Geometrics.h"

@implementation SCUserNameView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib {
    const char *name = getlogin();
    NSString *s = [NSString stringWithCString:name encoding:NSASCIIStringEncoding];
    NSSize rs = [s sizeForWidth:[s widthForHeight:22 font:self.nameField.font] height:22 font:self.nameField.font];
    [self.nameField setStringValue:s];
    [self setFrameSize:(NSSize){22 + rs.width + 3, self.frame.size.height}];
    [self.nameField setFrameSize:(NSSize){rs.width, self.nameField.frame.size.height}];
}

@end
