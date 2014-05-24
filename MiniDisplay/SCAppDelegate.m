/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import "SCAppDelegate.h"

@implementation SCAppDelegate {
    long long currentWidth;
    BOOL isCollapsed;
    NSLock *rsLock;
}

static NSArray *arr;

+ (void)initialize {
    /* configuration goes here
     * 0: collapse button 
     * 1: user name
     * 3: CPU
     * 4: Memory
     * 6: disk
     */
    arr = @[@"0", @"3", @"4", @"6*sys", @"6*home"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    rsLock = [NSLock alloc];
    currentWidth = 500;
    isCollapsed = NO;
    self.window.level = kCGDesktopIconWindowLevel + 1;
    [self positionWindow:NO];
    NSInteger len = 0;
    NSArray *views = nil;
    int iter = 0;
    for (; iter < [arr count]; iter++) {
        [[NSBundle mainBundle] loadNibNamed:@"Views" owner:self topLevelObjects:&views];
        NSString *m = nil;
        NSString *a = nil;
        NSString *d = [arr objectAtIndex:iter];
        if ([d rangeOfString:@"*"].location == NSNotFound) {
            m = d;
        } else {
            m = [[d componentsSeparatedByString:@"*"] objectAtIndex:0];
            a = [[d componentsSeparatedByString:@"*"] objectAtIndex:1];
        }
        for (NSView *i in views) {
            if (![i isKindOfClass:[NSView class]]) {
                continue;
            }
            if ([i.identifier isEqualToString:m]) {
                if (a && [i respondsToSelector:@selector(prepareForService:)]) {
                    [i performSelector:@selector(prepareForService:) withObject:a];
                } else if ([i respondsToSelector:@selector(prepareForService)]) {
                    [i performSelector:@selector(prepareForService)];
                }
                [i setFrameOrigin:NSMakePoint(len, 0)];
                [self.bgView addSubview:i];
                len += i.frame.size.width;
                break;
            }
        }
        if (iter + 1 < [arr count] && iter != 0) {
            NSView *sp = GetSeparatorView();
            [sp setFrameOrigin:(NSPoint){len, 0}];
            [self.bgView addSubview:sp];
        }
        len++;
    }
    [self.window setFrame:(NSRect){self.window.frame.origin, {len + 80, self.window.frame.size.height}} display:YES];
    [self.window makeKeyAndOrderFront:self];
}

- (void)recalculateSubviews {
    [rsLock lock];
    NSInteger len = 0;
    for (NSView *m in self.bgView.subviews) {
        [m setFrameOrigin:NSMakePoint(len, 0)];
        len += m.frame.size.width;
    }
    if (isCollapsed) {
        currentWidth = len + 80;
    } else {
        [self.bgView setFrameSize:(NSSize){len, self.window.frame.size.height}];
        [self.window setFrame:(NSRect){self.window.frame.origin, {len + 80, self.window.frame.size.height}} display:YES];
        [self.endView setFrameOrigin:(NSPoint){len, 0}];
        [self.endView setFrameSize:(NSSize){80, 22}];
    }
    [rsLock unlock];
}

NSView *GetSeparatorView(void) {
    NSView *v = [[NSView alloc] initWithFrame:(NSRect){{0, 0}, {1, 22}}];
    v.wantsLayer = YES;
    v.layer = [CALayer layer];
    v.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.2 alpha:1.0] CGColor];
    return v;
}

- (void)setCurrentWidth:(long long)newCurrentWidth {
    currentWidth = newCurrentWidth;
    [self positionWindow:YES];
}

- (IBAction)exitClicked:(id)sender {
    [NSApp stop:self];
}

- (IBAction)collapseClicked:(id)sender {
    if (!isCollapsed) {
        [self collapseWindow];
    } else {
        [self positionWindow:YES];
    }
}

- (void)collapseWindow {
    currentWidth = self.window.frame.size.width;
    [self.window setFrame:(NSRect){self.window.frame.origin, {17 + 80, 22}} display:YES animate:YES];
    [self.bgView setFrameSize:(NSSize){17, 22}];
    [self.endView setFrameOrigin:(NSPoint){17, 0}];
    isCollapsed = YES;
    [[self.appMenu itemAtIndex:2] setTitle:@"Expand"];
}

- (void)positionWindow:(BOOL)animated {
    [self recalculateSubviews];
    [self.endView setFrameOrigin:(NSPoint){currentWidth - 80, 0}];
    [self.bgView setFrameSize:(NSSize){currentWidth - 80, 22}];
    [self.window setFrame:(NSRect){self.window.frame.origin, {currentWidth, 22}} display:YES animate:animated];
    isCollapsed = NO;
    [[self.appMenu itemAtIndex:2] setTitle:@"Collapse"];
}

@end
