//
//  PBWebController.m
//  GitX
//
//  Created by Pieter de Bie on 08-10-08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBWebController.h"


@implementation PBWebController

@synthesize startFile;

- (void) awakeFromNib
{
	NSString *path = [NSString stringWithFormat:@"html/views/%@", startFile];
	NSString* file = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:path];
	NSLog(@"path: %@, file: %@", path, file);
	NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:file]];

	finishedLoading = NO;
	[view setUIDelegate:self];
	[view setFrameLoadDelegate:self];
	[[view mainFrame] loadRequest:request];
}

- (void) webView:(id) v didFinishLoadForFrame:(id) frame
{
	id script = [view windowScriptObject];
	[script setValue: self forKey:@"Controller"];

	finishedLoading = YES;
	if ([self respondsToSelector:@selector(didLoad)])
		[self performSelector:@selector(didLoad)];
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary
{
	NSLog(@"Error from webkit: %@", dictionary);
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
	return NO;
}

+ (BOOL)isKeyExcludedFromWebScript:(const char *)name {
	return NO;
}

#pragma mark Functions to be used from JavaScript
- (void) log: (NSString*) logMessage
{
	NSLog(@"%@", logMessage);
}

#include <SystemConfiguration/SCNetworkReachability.h>

- (BOOL) isReachable:(NSString *)hostname
{
	SCNetworkConnectionFlags flags;
	if (!SCNetworkCheckReachabilityByName([hostname cStringUsingEncoding:NSASCIIStringEncoding], &flags))
		return FALSE;

	// If a connection is required, then it's not reachable
	if (flags & (kSCNetworkFlagsConnectionRequired | kSCNetworkFlagsConnectionAutomatic | kSCNetworkFlagsInterventionRequired))
		return FALSE;

	return flags > 0;
}

@end
