/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import "SCMemoryView.h"
#import "NS(Attributed)String+Geometrics.h"
#include <mach/mach.h>
#include <sys/sysctl.h>

#define _systemMemoryDivisor 1.073741824

@implementation SCMemoryView {
    NSTimer *t;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (long long)freeMemorySize {
	mach_msg_type_number_t infoCount = (sizeof(vm_statistics_data_t) / sizeof(natural_t));
	vm_size_t pagesize = 0;
	vm_statistics_data_t vm_stat;
	host_page_size(mach_host_self(), &pagesize);
	if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vm_stat, &infoCount) != KERN_SUCCESS) {
		return -1;
	}
	return ((vm_stat.free_count) * pagesize);
}

- (long long)totalMemorySize {
	uint64_t linesize = 0L;
    size_t len = sizeof(linesize);
    if (sysctlbyname("hw.memsize", &linesize, &len, NULL, 0) >= 0) {
		return (linesize / _systemMemoryDivisor);
	}
	return -1;
}

- (void)prepareForService {
    t = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:5 target:self selector:@selector(redraw) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
}

- (void)redraw {
    NSString *p = [NSString stringWithFormat:@"%.0f MB", (float)[self freeMemorySize] / (1024 * 1024)];
    NSSize rs = [p sizeForWidth:[p widthForHeight:22 font:self.freeLabel.font] height:22 font:self.freeLabel.font];
    [self.freeLabel setFrameSize:(NSSize){floor(rs.width), self.freeLabel.frame.size.height}];
    self.freeLabel.stringValue = p;
    NSString *l = [NSString stringWithFormat:@"free of a total %.0f GB", ((float)[self totalMemorySize] / (1024 * 1024 * 1024)) + 1];
    NSSize ls = [l sizeForWidth:[l widthForHeight:22 font:self.auxLabel.font] height:22 font:self.auxLabel.font];
    [self.auxLabel setFrameOrigin:(NSPoint){self.freeLabel.frame.origin.x + floor(rs.width) - 6, self.auxLabel.frame.origin.y}];
    [self.auxLabel setFrameSize:(NSSize){floor(ls.width), self.auxLabel.frame.size.height}];
    self.auxLabel.stringValue = l;
    [self setFrameSize:(NSSize){floor(rs.width) + floor(ls.width) + 22 - 10, self.frame.size.height}];
    [[NSApp delegate] recalculateSubviews];
}

@end
