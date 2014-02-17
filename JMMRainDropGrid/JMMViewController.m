//
//  JMMViewController.m
//  JMMRainDropGrid
//
//  Created by Justin Martin on 2/16/14.
//  Copyright (c) 2014 JMM. All rights reserved.
//

#import "JMMViewController.h"

static CGFloat const kJMMStaggerTick = 0.08;
static CGFloat const kJMMGridSize = 320.0f;
static CGFloat const kJMMGridBottom = 480.0f;
static int const kJMMItemsPerRow = 4;
static int const kJMMNumberOfRows = 4;


static CGPoint PositionForIndex(int index, float size) {
    CGFloat xOff = size * (index % kJMMItemsPerRow);
    CGFloat yOff = size * trunc((index / kJMMItemsPerRow));
    yOff = yOff - kJMMGridBottom;
    return CGPointMake(xOff, yOff);
}

@interface JMMViewController ()
@property (nonatomic) NSMutableArray *rainDrops;
@end

@implementation JMMViewController {
    UIButton *_startButton;
    UIDynamicAnimator *_animator;
    UIGravityBehavior *_gravity;
    UICollisionBehavior *_collision;
    NSTimer *_staggerTimer;
    CGFloat _itemSize;
    int _currentRainDrop;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _itemSize = kJMMGridSize / kJMMItemsPerRow;
    _startButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x, self.view.height - 50, 80, 50)];
    [_startButton addTarget:self action:@selector(triggerAnimation) forControlEvents:UIControlEventTouchUpInside];
    [_startButton setTitle:@"Trigger" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_startButton];
    
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    _collision = [[UICollisionBehavior alloc] initWithItems:@[]];
    _collision.translatesReferenceBoundsIntoBoundary = NO;
    [_collision addBoundaryWithIdentifier:@"bottom" fromPoint:CGPointMake(0, kJMMGridBottom) toPoint:CGPointMake(self.view.width, kJMMGridBottom)];
    [_animator addBehavior:_collision];
    _gravity = [[UIGravityBehavior alloc] initWithItems:@[]];
    _gravity.angle = M_PI / 2;
    _gravity.magnitude = 0.4;
    [_animator addBehavior:_gravity];
    
    self.rainDrops = [NSMutableArray array];
	for (int i = 0; i < kJMMNumberOfRows * kJMMItemsPerRow; i++) {
        [self addRainDropAtIndex:i];
    }
}

-(void) addRainDropAtIndex:(int)index {
    CGPoint position = PositionForIndex(index, _itemSize);
    UIView *item = [[UIView alloc] initWithFrame:CGRectMake(position.x, position.y, _itemSize, _itemSize)];
    item.tag = 1000 + index;
    item.layer.borderColor = [UIColor blackColor].CGColor;
    item.layer.borderWidth = 1;
    item.alpha = 0.4;
    CGFloat r = (arc4random() % 60);
    CGFloat g = (arc4random() % 60);
    CGFloat b = (arc4random() % 155) + 100;
    item.backgroundColor = [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:1];
    [self.view addSubview:item];
    [self.rainDrops addObject:item];
}

-(void) triggerAnimation {
	[self _makeItRain];
}

-(void) _makeItRain {
    if (!_staggerTimer) {
        _currentRainDrop = ((int)[self.rainDrops count]) - 1;
        
        _staggerTimer = [NSTimer timerWithTimeInterval:kJMMStaggerTick target:self selector:@selector(_nextRainDrop) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_staggerTimer forMode:NSRunLoopCommonModes];
    }
}

-(void) _nextRainDrop {
    if (_currentRainDrop >= 0) {
        [self _dropRainDrop:self.rainDrops[_currentRainDrop]];
        _currentRainDrop --;
    }
    else {
        [_staggerTimer invalidate];
        _staggerTimer = nil;
    }
}

-(void) _dropRainDrop:(UIView *)rainDrop {
    [_gravity addItem:rainDrop];
    [_collision addItem:rainDrop];
}



@end
