//
//  SDConfigLoader.m
//  Zephyros
//
//  Created by Steven on 4/15/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDConfigLauncher.h"

#import "SDPreferencesWindowController.h"
#import "SDPathWatcher.h"

#import "SDLogWindowController.h"
#import "SDAlertWindowController.h"

@interface SDConfigLauncher ()

@property SDPathWatcher* configWatcher;
@property NSTask* launchedTask;

@end


@implementation SDConfigLauncher

+ (SDConfigLauncher*) sharedConfigLauncher {
    static SDConfigLauncher* sharedConfigLauncher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfigLauncher = [[SDConfigLauncher alloc] init];
        sharedConfigLauncher.configWatcher = [[SDPathWatcher alloc] init];
    });
    return sharedConfigLauncher;
}

- (void) launchConfigMaybe {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* cmd = [[NSUserDefaults standardUserDefaults] stringForKey:SDLaunchCommandDefaultsKey];
        BOOL shouldLaunchConfig = [[NSUserDefaults standardUserDefaults] boolForKey:SDRunMyScriptDefaultsKey] && [cmd length] > 0;
        
        if (shouldLaunchConfig) {
            if ([self isLaunched])
                [self unlaunch];
            
            [self launch];
        }
        else {
            [self unlaunch];
            self.configWatcher = nil;
        }
        
        [self watchPathsMaybe];
    });
}

- (void) watchPathsMaybe {
    BOOL shouldLaunchConfig = [[NSUserDefaults standardUserDefaults] boolForKey:SDRunMyScriptDefaultsKey];
    BOOL shouldWatchPaths = [[NSUserDefaults standardUserDefaults] boolForKey:SDUseRelaunchPathsDefaultsKey];
    
    if (shouldLaunchConfig && shouldWatchPaths) {
        NSString* pathsStr = [[NSUserDefaults standardUserDefaults] stringForKey:SDRelaunchPathsDefaultsKey];
        NSArray* paths = [pathsStr componentsSeparatedByString:@"\n"];
        self.configWatcher = [SDPathWatcher watcherFor:paths];
    }
    else {
        self.configWatcher = nil;
    }
}




- (void) prelaunchMaybe {
    BOOL shouldPrelaunch = [[NSUserDefaults standardUserDefaults] boolForKey:SDRunCommandFirstDefaultsKey];
    
    if (!shouldPrelaunch)
        return;
    
    NSString* prelaunchCmd = [[NSUserDefaults standardUserDefaults] stringForKey:SDPrerunCommandDefaultsKey];
    
    NSTask* task = [NSTask launchedTaskWithLaunchPath:@"/bin/bash" arguments:@[@"-l", @"-c", prelaunchCmd]];
    [task waitUntilExit];
}

- (void) launch {
    [self prelaunchMaybe];
    
    NSString* cmd = [[NSUserDefaults standardUserDefaults] stringForKey:SDLaunchCommandDefaultsKey];
    
    NSPipe* stdoutPipe = [NSPipe pipe];
    NSPipe* stderrPipe = [NSPipe pipe];
    
    self.launchedTask = [[NSTask alloc] init];
    
    [self.launchedTask setLaunchPath:@"/bin/bash"];
    [self.launchedTask setArguments:@[@"-l", @"-c", cmd]];
    
    [self.launchedTask setStandardOutput:stdoutPipe];
    [self.launchedTask setStandardError:stderrPipe];
    
    [stdoutPipe fileHandleForReading].readabilityHandler = ^(NSFileHandle* handle) {
        NSData* data = [handle availableData];
        NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SDLogWindowController sharedLogWindowController] show:str
                                                               type:SDLogMessageTypeUser];
        });
    };
    
    [stderrPipe fileHandleForReading].readabilityHandler = ^(NSFileHandle* handle) {
        NSData* data = [handle availableData];
        NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SDLogWindowController sharedLogWindowController] show:str
                                                               type:SDLogMessageTypeError];
        });
    };
    
    [self.launchedTask launch];
    
    static BOOL firstTime = YES;
    if (firstTime) {
        firstTime = NO;
    }
    else {
        [[SDAlertWindowController sharedAlertWindowController] show:@"Relaunched Config"
                                                              delay:nil];
    }
}

- (void) unlaunch {
    [self.launchedTask terminate];
    self.launchedTask = nil;
}

- (BOOL) isLaunched {
    return self.launchedTask != nil;
}



//- (id) eval:(NSString*)str {
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"configShouldPreprocess"]) {
//        NSString* preprocessor = [[NSUserDefaults standardUserDefaults] stringForKey:@"configConverter"];
//        if (preprocessor) {
//            preprocessor = [preprocessor stringByStandardizingPath];
//            NSDictionary* result = [SDAPI shell:@"/bin/bash"
//                                           args:@[@"-lc", preprocessor]
//                                        options:@{@"input": str, @"pwd":[preprocessor stringByDeletingLastPathComponent]}];
//            str = [result objectForKey:@"stdout"];
//        }
//    }


@end
