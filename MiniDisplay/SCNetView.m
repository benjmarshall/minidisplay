/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import "SCNetView.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socketvar.h>
#include <netinet/ip.h>
#include <netinet/ip_var.h>
#include <netinet/tcp.h>
#include <netinet/tcp_var.h>
#import "NS(Attributed)String+Geometrics.h"
#import "SCAppDelegate.h"

typedef enum PacketDirection {
    PacketDirectionOut,
    PacketDirectionIn,
} PacketDirection;

@implementation SCNetView {
    NSTimer *t;
    unsigned long ipkts;
    unsigned long opkts;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)prepareForService {
    ipkts = 0;
    opkts = 0;
    self.inAux.stringValue = @"KB/s in  - ";
    [self.inAux setFrameSize:(NSSize){floor([self.inAux.stringValue sizeForWidth:[self.inAux.stringValue widthForHeight:22 font:self.inAux.font] height:22 font:self.inAux.font].width), self.inAux.frame.size.height}];
    self.outAux.stringValue = @"KB/s out";
    [self.outAux setFrameSize:(NSSize){floor([self.outAux.stringValue sizeForWidth:[self.outAux.stringValue widthForHeight:22 font:self.outAux.font] height:22 font:self.outAux.font].width), self.outAux.frame.size.height}];
    t = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:2 target:self selector:@selector(redraw) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
}

- (unsigned long)getTCPByteCount:(enum PacketDirection)dir {
    struct tcpstat stats;
    size_t retSize = sizeof(struct tcpstat);
    int rv;
    if ((rv = sysctlbyname("net.inet.tcp.stats", &stats, &retSize, NULL, 0)) < 0) {
        NSLog(@"bailing out; %s", strerror(rv));
        return 0;
    }
    unsigned long tpkts;
    switch (dir) {
        case PacketDirectionIn:
            tpkts = stats.tcps_rcvbyte + stats.tcps_rcvoobyte + stats.tcps_rcvdupbyte - ipkts;
            ipkts = tpkts + ipkts;
            return tpkts;
            break;
        case PacketDirectionOut:
            tpkts = stats.tcps_sndbyte + stats.tcps_sndrexmitbyte - opkts;
            opkts = tpkts + opkts;
            return tpkts;
            break;
        default:
            return 0;
    }
    return 0;
}

- (NSInteger)drawInLabel {
    NSString *p = [NSString stringWithFormat:@"%.2f", ((float)[self getTCPByteCount:PacketDirectionIn] / 1024) / 2];
    NSSize rs = [p sizeForWidth:[p widthForHeight:22 font:self.inNum.font] height:22 font:self.inNum.font];
    [self.inNum setFrameSize:(NSSize){floor(rs.width), self.inNum.frame.size.height}];
    self.inNum.stringValue = p;
    [self.inAux setFrameOrigin:(NSPoint){floor(self.inNum.frame.origin.x) + floor(rs.width) - 5, self.inAux.frame.origin.y}];
    return floor(rs.width) + self.inAux.frame.size.width;
}

- (NSInteger)drawOutLabel:(NSInteger)offset {
    NSString *p = [NSString stringWithFormat:@"%.2f", ((float)[self getTCPByteCount:PacketDirectionOut] / 1024) / 2];
    NSSize rs = [p sizeForWidth:[p widthForHeight:22 font:self.outNum.font] height:22 font:self.outNum.font];
    [self.outNum setFrameOrigin:(NSPoint){offset + 16, self.outNum.frame.origin.y}];
    [self.outNum setFrameSize:(NSSize){floor(rs.width), self.outNum.frame.size.height}];
    self.outNum.stringValue = p;
    [self.outAux setFrameOrigin:(NSPoint){floor(self.outNum.frame.origin.x) + floor(rs.width) - 5, self.outAux.frame.origin.y}];
    return floor(rs.width) + self.outAux.frame.size.width;
}

- (void)redraw {
    NSInteger inWidth = [self drawInLabel];
    [self setFrameSize:(NSSize){12 + inWidth + [self drawOutLabel:inWidth], 22}];
    [[NSApp delegate] recalculateSubviews];
}

@end
