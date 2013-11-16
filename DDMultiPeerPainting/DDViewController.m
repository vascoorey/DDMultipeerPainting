//
//  DDViewController.m
//  DDMultiPeerPainting
//
//  Created by Vasco d'Orey on 14/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDViewController.h"
#import "DDDrawingView.h"
#import "DDDrawingData.h"
#import <Masonry/Masonry.h>

@import MultipeerConnectivity;

static NSString *const DDServiceType = @"deltadogdrawing";
static NSString *const DDState = @"s";
static NSString *const DDXCoordinate = @"x";
static NSString *const DDYCoordinate = @"y";
static NSString *const DDClear = @"c";

@interface DDViewController () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, Drawing>
// UI
@property (nonatomic, strong) DDDrawingView *drawingView;
@property (nonatomic, strong) UILabel *peersLabel;
@property (nonatomic, strong) UIButton *browseButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIBezierPath *currentPath;
// MC
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, getter = isBrowsing) BOOL browsing;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *myPeer;
@property (nonatomic, strong) NSMutableArray *peers;
@end

@implementation DDViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.myPeer = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
  
  self.peers = [NSMutableArray array];
  
  self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.myPeer serviceType:DDServiceType];
  self.browser.delegate = self;
  
  self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.myPeer discoveryInfo:nil serviceType:DDServiceType];
  self.advertiser.delegate = self;
  [self.advertiser startAdvertisingPeer];
  
  self.session = [[MCSession alloc] initWithPeer:self.myPeer];
  self.session.delegate = self;
  
  self.drawingView = [[DDDrawingView alloc] init];
  self.drawingView.backgroundColor = [UIColor whiteColor];
  self.drawingView.delegate = self;
  [self.view addSubview:self.drawingView];
  
  self.peersLabel = [[UILabel alloc] init];
  self.peersLabel.text = @"Peers: 0";
  self.peersLabel.textAlignment = NSTextAlignmentCenter;
  self.peersLabel.backgroundColor = [UIColor grayColor];
  [self.view addSubview:self.peersLabel];
  
  self.browseButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.browseButton.backgroundColor = [UIColor grayColor];
  [self.browseButton setTitle:@"Start Browsing" forState:UIControlStateNormal];
  [self.browseButton addTarget:self action:@selector(browseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.browseButton];
  
  self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.clearButton.backgroundColor = [UIColor grayColor];
  [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
  [self.clearButton addTarget:self action:@selector(clearButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.clearButton];
  
  [self.peersLabel makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view.left);
    make.top.equalTo(self.view.top);
    make.width.equalTo(self.view.width).multipliedBy(1.f / 3.f);
    make.height.equalTo(self.view.height).multipliedBy(.1f);
  }];
  
  [self.clearButton makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.peersLabel.right);
    make.top.equalTo(self.view.top);
    make.width.equalTo(self.view.width).multipliedBy(1.f / 3.f);
    make.height.equalTo(self.view.height).multipliedBy(.1f);
  }];
  
  [self.browseButton makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.view.right);
    make.top.equalTo(self.view.top);
    make.width.equalTo(self.view.width).multipliedBy(1.f / 3.f);
    make.height.equalTo(self.view.height).multipliedBy(.1f);
  }];
  
  [self.drawingView makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.peersLabel.bottom);
    make.left.equalTo(self.view.left);
    make.right.equalTo(self.view.right);
    make.bottom.equalTo(self.view.bottom);
  }];
}

#pragma mark - Actions

-(void)browseButtonTapped:(__unused UIButton *)sender
{
  if(self.isBrowsing)
  {
    [self.browseButton setTitle:@"Start Browsing" forState:UIControlStateNormal];
    [self.advertiser startAdvertisingPeer];
    [self.browser stopBrowsingForPeers];
  }
  else
  {
    [self.browseButton setTitle:@"Stop Browsing" forState:UIControlStateNormal];
    [self.advertiser stopAdvertisingPeer];
    [self.browser startBrowsingForPeers];
  }
  self.browsing = !self.browsing;
}

-(void)clearButtonTapped:(__unused UIButton *)sender
{
  [self.drawingView clear];
  if(!self.peers.count)
  {
    return;
  }
  NSError *error;
  NSDictionary *params = @{ DDClear : @YES };
  NSData *data = [NSPropertyListSerialization dataWithPropertyList:params format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
  if(error)
  {
    NSLog(@"%@", error.localizedDescription);
    return;
  }
  NSLog(@"Size to send: %lu", (unsigned long)data.length);
  [self.session sendData:data toPeers:self.peers withMode:MCSessionSendDataReliable error:&error];
  if(error)
  {
    NSLog(@"%@", error.localizedDescription);
  }
}

#pragma mark - Browser Delegate

-(void)browser:(__unused MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(__unused NSError *)error
{
  
}

-(void)browser:(__unused MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(__unused NSDictionary *)info
{
  [self.browser invitePeer:peerID toSession:self.session withContext:nil timeout:10.f];
}

-(void)browser:(__unused MCNearbyServiceBrowser *)browser lostPeer:(__unused MCPeerID *)peerID
{
  
}

#pragma mark - Advertiser Delegater

-(void)advertiser:(__unused MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(__unused NSError *)error
{
  
}

-(void)advertiser:(__unused MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(__unused NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
  invitationHandler(YES, self.session);
}

#pragma mark - Session Delegate

-(void)session:(__unused MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
  dispatch_async(dispatch_get_main_queue(), ^{
    NSError *error;
    NSDictionary *params = [NSPropertyListSerialization propertyListWithData:data options:0 format:0 error:&error];
    NSLog(@"%@", params);
    if(error)
    {
      NSLog(@"%@", error.localizedDescription);
      return;
    }
    if(params[DDClear])
    {
      [self.drawingView clear];
    }
    else
    {
      [self.drawingView updatePathWithKey:peerID state:[params[DDState] integerValue] point:CGPointMake([params[DDXCoordinate] doubleValue], [params[DDYCoordinate] doubleValue])];
    }
  });
}

-(void)session:(__unused MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
  dispatch_async(dispatch_get_main_queue(), ^{
    if(state == MCSessionStateConnected)
    {
      NSLog(@"Connected to %@", peerID);
      [self.peers addObject:peerID];
    }
    else
    {
      NSLog(@"Lost connection to %@", peerID);
      [self.peers removeObject:peerID];
      [self.advertiser startAdvertisingPeer];
    }
    self.peersLabel.text = [NSString stringWithFormat:@"Peers: %lu", (unsigned long)self.peers.count];
    [self.peersLabel setNeedsDisplay];
  });
}

-(void)session:(__unused MCSession *)session didStartReceivingResourceWithName:(__unused NSString *)resourceName fromPeer:(__unused MCPeerID *)peerID withProgress:(__unused NSProgress *)progress
{
  
}

-(void)session:(__unused MCSession *)session didFinishReceivingResourceWithName:(__unused NSString *)resourceName fromPeer:(__unused MCPeerID *)peerID atURL:(__unused NSURL *)localURL withError:(__unused NSError *)error
{
  
}

-(void)session:(__unused MCSession *)session didReceiveStream:(__unused NSInputStream *)stream withName:(__unused NSString *)streamName fromPeer:(__unused MCPeerID *)peerID
{
  
}

#pragma mark - Drawing Delegate

-(void)drawingView:(__unused DDDrawingView *)drawingView didDrawPoint:(CGPoint)point withState:(DDDrawingState)state
{
  if(!self.peers.count)
  {
    return;
  }
  NSError *error = nil;
  NSDictionary *params = @{ DDState : @(state), DDXCoordinate : @((short)point.x), DDYCoordinate : @((short)point.y) };
  NSData *data = [NSPropertyListSerialization dataWithPropertyList:params format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
  if(error)
  {
    NSLog(@"%@", error.localizedDescription);
    return;
  }
  NSLog(@"Size to send: %lu", (unsigned long)data.length);
  [self.session sendData:data toPeers:self.peers withMode:MCSessionSendDataReliable error:&error];
  if(error)
  {
    NSLog(@"%@", error.localizedDescription);
  }
}

@end
