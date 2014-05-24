/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import "SCDiskView.h"
#import "SCAppDelegate.h"
#import "NS(Attributed)String+Geometrics.h"

typedef enum OpMode {
    OpModeSystemDisk,
    OpModeHomeDisk,
} OpMode;

@implementation SCDiskView {
    NSTimer *t;
    OpMode md;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)prepareForService:(NSString *)arg {
    if ([arg isEqualToString:@"home"]) {
        [self.img setImage:[NSImage imageNamed:@"home-disk.png"]];
        md = OpModeHomeDisk;
    } else {
        md = OpModeSystemDisk;
    }
    t = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:60 target:self selector:@selector(redraw) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
    [self redraw];
}

- (NSDictionary *)dataReport {
    NSError *e = nil;
    NSDictionary *dc = [[NSFileManager defaultManager] attributesOfFileSystemForPath:(md == OpModeHomeDisk ? NSHomeDirectory() : @"/") error:&e];
    NSMutableDictionary *rt = [NSMutableDictionary dictionary];
    if (e) {
        return nil;
    }
    long long bFree = [[dc objectForKey:NSFileSystemFreeSize] longLongValue];
    if (bFree < 2000000000) {
        [rt setObject:@"MB" forKey:@"FreeUnits"];
        [rt setObject:@(bFree / (1000 * 1000)) forKey:@"FreeBytes"];
    } else {
        [rt setObject:@"GB" forKey:@"FreeUnits"];
        [rt setObject:@(bFree / (1000 * 1000 * 1000)) forKey:@"FreeBytes"];
    }
    long long bUsed = [[dc objectForKey:NSFileSystemSize] longLongValue] - [[dc objectForKey:NSFileSystemFreeSize] longLongValue];
    if (bUsed < 2000000000) {
        [rt setObject:@"MB" forKey:@"UsedUnits"];
        [rt setObject:@(bUsed / (1000 * 1000)) forKey:@"UsedBytes"];
    } else {
        [rt setObject:@"GB" forKey:@"UsedUnits"];
        [rt setObject:@(bUsed / (1000 * 1000 * 1000)) forKey:@"UsedBytes"];
    }
    return rt;
}

- (void)redraw {
    NSDictionary *report = [self dataReport];
    NSString *p = [NSString stringWithFormat:@"%lu %@", [[report objectForKey:@"FreeBytes"] longValue], [report objectForKey:@"FreeUnits"]];
    NSSize rs = [p sizeForWidth:[p widthForHeight:22 font:self.freeLabel.font] height:22 font:self.freeLabel.font];
    [self.freeLabel setFrameSize:(NSSize){floor(rs.width), self.freeLabel.frame.size.height}];
    self.freeLabel.stringValue = p;
    NSString *l = [NSString stringWithFormat:@"free, %lu %@ used on %@", [[report objectForKey:@"UsedBytes"] longValue], [report objectForKey:@"UsedUnits"], (md == OpModeHomeDisk ? @"~" : @"/")];
    NSSize ls = [l sizeForWidth:[l widthForHeight:22 font:self.auxLabel.font] height:22 font:self.auxLabel.font];
    [self.auxLabel setFrameOrigin:(NSPoint){self.freeLabel.frame.origin.x + floor(rs.width) - 6, self.auxLabel.frame.origin.y}];
    [self.auxLabel setFrameSize:(NSSize){floor(ls.width), self.auxLabel.frame.size.height}];
    self.auxLabel.stringValue = l;
    [self setFrameSize:(NSSize){floor(rs.width) + floor(ls.width) + 22 - 10, self.frame.size.height}];
    [[NSApp delegate] recalculateSubviews];
}

@end
