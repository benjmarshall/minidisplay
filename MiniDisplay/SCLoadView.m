/*
 * MiniDisplay, the broken system monitor for the Obsidian Menu Bar
 * and possibly the worst code I've ever written.
 *
 * I hereby release this file into the public domain. You can use it for
 * anything you want -- you don't even have to retain this notice!
 */

#import "SCLoadView.h"
#import "SCAppDelegate.h"
#import "NS(Attributed)String+Geometrics.h"
#include <sys/sysctl.h>
#include <sys/types.h>
#include <mach/processor_info.h>
#include <mach/mach.h>
#include <mach/mach_host.h>

@implementation SCLoadView {
    NSTimer *refreshTimer;
    processor_info_array_t cpuInfo, prevCpuInfo;
    mach_msg_type_number_t numCpuInfo, numPrevCpuInfo;
    NSUInteger numCPUs;
    NSTimer *updateTimer;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (theEvent.clickCount == 2){
        [[NSWorkspace sharedWorkspace] launchApplication:@"Activity Monitor"];
    }
}

- (void)prepareForService {
    int mib[2] = {CTL_HW, HW_NCPU};
    size_t sizeOfNumCPUs = sizeof(numCPUs);
    int status = sysctl(mib, 2, &numCPUs, &sizeOfNumCPUs, NULL, 0);
    if (status) {
        numCPUs = 1;
    }
    refreshTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1 target:self selector:@selector(redraw) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:refreshTimer forMode:NSDefaultRunLoopMode];
    [self redraw];
}

- (void)redraw {
    double *val;
    val = malloc(sizeof(double) * 3);
    getloadavg(val, 3);
    NSString *p = [self getCPUPercent];
    int temp_int = [p intValue];
    if (temp_int < 10) {
        p = [NSString stringWithFormat:@" %@",p];
    }
    NSString *temp_p = @"00%";
    NSSize rs = [temp_p sizeForWidth:[temp_p widthForHeight:22 font:self.percentLabel.font] height:22 font:self.percentLabel.font];
    [self.percentLabel setFrameSize:(NSSize){floor(rs.width), self.percentLabel.frame.size.height}];
    self.percentLabel.stringValue = p;
    NSString *l = [NSString stringWithFormat:@"(load: %.2f, %.2f, %.2f)", val[0], val[1], val[2]];
    free(val);
    NSSize ls = [l sizeForWidth:[l widthForHeight:22 font:self.loadLabel.font] height:22 font:self.loadLabel.font];
    [self.loadLabel setFrameOrigin:(NSPoint){self.percentLabel.frame.origin.x + floor(rs.width) - 5, self.loadLabel.frame.origin.y}];
    [self.loadLabel setFrameSize:(NSSize){floor(ls.width), self.loadLabel.frame.size.height}];
    self.loadLabel.stringValue = l;
    [self setFrameSize:(NSSize){floor(rs.width) + floor(ls.width) + 22 - 5, self.frame.size.height}];
    [[NSApp delegate] recalculateSubviews];
}

- (NSString *)getCPUPercent {
    natural_t numCPUsU = 0;
    kern_return_t err = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
    float usage = 0;
    if(err == KERN_SUCCESS) {
        float inUse, total;
        for(unsigned i = 0; i < numCPUs; ++i) {
            if(prevCpuInfo) {
                inUse = (
                         (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM])
                         + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE]   - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE])
                         );
                total = inUse + (cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE]);
            } else {
                inUse = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                total = inUse + cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
            }
            usage += (inUse / total);
        }
        if (prevCpuInfo) {
            size_t prevCpuInfoSize = sizeof(integer_t) * numPrevCpuInfo;
            vm_deallocate(mach_task_self(), (vm_address_t)prevCpuInfo, prevCpuInfoSize);
        }
        prevCpuInfo = cpuInfo;
        numPrevCpuInfo = numCpuInfo;
        cpuInfo = NULL;
        numCpuInfo = 0;
        return [NSString stringWithFormat:@"%.0f%%", (usage / numCPUs) * 100];
    } else {
        return @"error!";
    }
}

@end
