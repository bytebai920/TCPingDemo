//
//  TCPingManager.m
//  TCPingDemo
//
//  Created by 白永炳 on 16/12/28.
//  Copyright © 2016年 BYB. All rights reserved.
//  github https://github.com/jlyo/tcping
//

#import "TCPingManager.h"

#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <sys/time.h>

#include "tcp.h"

#define abs(x) ((x) < 0 ? -(x) : (x))

static volatile int stop = 0;
static TCPingManager *tcpManager = nil;

@interface TCPingManager ()

@end

@implementation TCPingManager

+ (TCPingManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (tcpManager == nil) {
            tcpManager = [[TCPingManager alloc] init];
        }
    });
    
    return tcpManager;
    
}

- (void)OTSTCPingWithHostName:(NSString *)pingTarget time:(NSNumber *)num currentDelay:(delayBlock)delay success:(successBlock)success failed:(failedBlock)failed
{
    //    char *char_host = [ip cStringUsingEncoding:NSASCIIStringEncoding];
    //    char *char_port = [port cStringUsingEncoding:NSASCIIStringEncoding];
    
    self.success = success;
    self.failed = failed;
    self.delay = delay;
    
    NSArray *pingArr = nil;
    
    if (pingTarget != nil) {
        pingArr = [pingTarget componentsSeparatedByString:@":"];
    }
    
    if (pingArr != nil && pingArr.count > 0) {
        
        NSString *ipStr = pingArr.firstObject;
        NSString *portStr = pingArr.lastObject;
        [self stratPingWithIPAddress:ipStr Port:portStr times: num.intValue];

    }
    
}

void usage(void)
{
    fprintf(stderr, "tcping, (C) 2003 folkert@vanheusden.com\n\n");
    fprintf(stderr, "hostname	hostname (e.g. localhost)\n");
    fprintf(stderr, "-p portnr	portnumber (e.g. 80)\n");
    fprintf(stderr, "-c count	how many times to connect\n");
    fprintf(stderr, "-i interval	delay between each connect\n");
    fprintf(stderr, "-f		flood connect (no delays)\n");
    fprintf(stderr, "-q		quiet, only returncode\n\n");
}

void handler(int sig)
{
    stop = 1;
}

- (int)stratPingWithIPAddress:(NSString *)ipAddr Port:(NSString *)port times:(int)times
{

     char *hostname = (char *)[ipAddr cStringUsingEncoding:NSASCIIStringEncoding];
    //"222.187.221.65";
     char *portnr = (char *)[port cStringUsingEncoding:NSASCIIStringEncoding];
    //"37018";
    int curncount = 0;
    int quiet = 0;
    int ok = 0, err = 0;
    double min = 999999999999999.0, avg = 0.0, max = 0.0;
    struct addrinfo *resolved;
    int errcode;
    int seen_addrnotavail;
    
    signal(SIGINT, handler);
    signal(SIGTERM, handler);
    
    if ((errcode = lookup(hostname, portnr, &resolved)) != 0)
    {
        fprintf(stderr, "%s\n", gai_strerror(errcode));
        return 2;
    }
    
    if (!quiet)
        printf("PING %s:%s\n", hostname, portnr);
    
    for (int i = 0; i<times; i++) {
        
        double ms;
        struct timeval rtt;
        
        if ((errcode = connect_to(resolved, &rtt)) != 0)
        {
            if (errcode != -EADDRNOTAVAIL)
            {
                printf("error connecting to host (%d): %s\n", -errcode, strerror(-errcode));
                err++;
                
                NSString *error  = [NSString stringWithUTF8String:strerror(-errcode)];
                if (error!= nil && _failed) {
                    _failed(error);
                }
            }
            else
            {
                if (seen_addrnotavail)
                {
                    printf(".");
                    fflush(stdout);
                }
                else
                {
                    printf("error connecting to host (%d): %s\n", -errcode, strerror(-errcode));
                }
                seen_addrnotavail = 1;
            }
        }
        else
        {
            seen_addrnotavail = 0;
            ok++;
            
            ms = ((double)rtt.tv_sec * 1000.0) + ((double)rtt.tv_usec / 1000.0);
            avg += ms;
            min = min > ms ? ms : min;
            max = max < ms ? ms : max;
            
            if (self.delay) {
                _delay(ms);
            }
            printf("response from %s:%s, seq=%d time=%.2f ms\n", hostname, portnr, curncount, ms);
            
        }
        
        curncount ++;
        
    }
    if (!quiet)
    {
        printf("--- %s:%s ping statistics ---\n", hostname, portnr);
        printf("%d responses, %d ok, %3.2f%% failed\n", curncount, ok, (((double)err) / abs(((double)curncount)) * 100.0));
        printf("round-trip min/avg/max = %.1f/%.1f/%.1f ms\n", min, avg / (double)ok, max);
        
        if (_success) {
            _success(max, min, avg);
        }
    }
    
    freeaddrinfo(resolved);
    if (ok)
        return 0;
    else
        return 127;
    
}

@end
