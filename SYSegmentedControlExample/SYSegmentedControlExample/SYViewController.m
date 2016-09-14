//
//  SYViewController.m
//  SYSegmentedControlExample
//
//  Created by Stan Chevallier on 13/09/2016.
//
//

#import "SYViewController.h"
#import "SYSegmentedControl.h"

@interface SYViewController ()
@property (nonatomic, weak) IBOutlet SYSegmentedControl *segmentedControl;
@end

@implementation SYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // [self playWithLineWidth];
}

- (void)playWithLineWidth
{
    [self.segmentedControl setLineWidth:(arc4random() % 10)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playWithLineWidth];
    });
}

@end
