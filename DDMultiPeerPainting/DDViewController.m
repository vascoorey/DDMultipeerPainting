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

@import MultipeerConnectivity;

static NSString *const DDServiceType = @"deltadogdrawing";
static NSString *const DDState = @"s";
static NSString *const DDXCoordinate = @"x";
static NSString *const DDYCoordinate = @"y";

@interface DDViewController () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, Drawing>
@property (nonatomic, strong) DDDrawingView *drawingView;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *myPeer;
@property (nonatomic, strong) NSMutableArray *peers;
@property (nonatomic, strong) UIBezierPath *currentPath;
@end

@implementation DDViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  self.myPeer = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
  
  self.peers = [NSMutableArray array];
  
#if TARGET_IPHONE_SIMULATOR
  self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.myPeer serviceType:DDServiceType];
  self.browser.delegate = self;
  [self.browser startBrowsingForPeers];
#endif
  
  self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.myPeer discoveryInfo:nil serviceType:DDServiceType];
  self.advertiser.delegate = self;
  [self.advertiser startAdvertisingPeer];
  
  self.session = [[MCSession alloc] initWithPeer:self.myPeer];
  self.session.delegate = self;
  
  self.drawingView = [[DDDrawingView alloc] initWithFrame:self.view.frame];
  self.drawingView.backgroundColor = [UIColor whiteColor];
  self.drawingView.delegate = self;
  [self.view addSubview:self.drawingView];
}

#pragma mark - Browser Delegate

-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
  
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
  [browser invitePeer:peerID toSession:self.session withContext:nil timeout:10.f];
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
  
}

#pragma mark - Advertiser Delegater

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
  
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
  [self.browser stopBrowsingForPeers];
  [self.advertiser stopAdvertisingPeer];
  [self.peers addObject:peerID];
  invitationHandler(YES, self.session);
}

#pragma mark - Session Delegate

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
  dispatch_async(dispatch_get_main_queue(), ^{
//    UIBezierPath *receivedPath = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    [self.drawingView addPath:receivedPath];
//    [self.view setNeedsDisplay];
    NSError *error;
    NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:data options:0 format:0 error:&error];
    NSLog(@"%@", dictionary);
    if(error)
    {
      NSLog(@"%@", error.localizedDescription);
      return;
    }
    [self.drawingView setPathWithKey:peerID state:[dictionary[DDState] integerValue] point:CGPointMake([dictionary[DDXCoordinate] doubleValue], [dictionary[DDYCoordinate] doubleValue])];
  });
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
  if(state == MCSessionStateConnected)
  {
    NSLog(@"Connected to %@", peerID);
    [self.peers addObject:peerID];
  }
  else
  {
    NSLog(@"Lost connection to %@", peerID);
    [self.peers removeObject:peerID];
  }
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
  
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
  
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
  
}

#pragma mark - Drawing Delegate

-(void)drawingView:(DDDrawingView *)drawingView didDrawPoint:(CGPoint)point withState:(DDDrawingState)state
{
  NSError *error = nil;
  NSDictionary *dictionary = @{ DDState : @(state), DDXCoordinate : @((short)point.x), DDYCoordinate : @((short)point.y) };
  NSData *data = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
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
