//
//  Commons.m
//  eXplora MuSe
//
//  Created by Nicolò Tosi on 6/22/13.
//  Copyright (c) 2013 MobFarm. All rights reserved.
//

#import "Commons.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation Commons

+(NSString *)randomIdentifier
{
    int randoms [8];
    
    for(int i = 0; i < 8; i++)
    {
        randoms[i] = arc4random();
    }
    
    return [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",randoms[0],randoms[1],randoms[2],randoms[3],randoms[4],randoms[5],randoms[6],randoms[7]];
}



+(NSString *)checksumStringFromChecksumByteArray:(unsigned char *)checksum
{
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            checksum[0], checksum[1], checksum[2], checksum[3], checksum[4],checksum[5],checksum[6],checksum[7],
            checksum[8], checksum[9], checksum[10], checksum[11], checksum[12], checksum[13], checksum[14],checksum[15]];
}

static char hexConversionTable [] = {
    0,1,2,3,4,5,6,7,8,9,
    -1,-1,-1,-1,-1,-1,-1,
    10,11,12,13,14,15,
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
        10,11,12,13,14,15
};

+(void)convertChecksumString:(NSString *)string toByteArray:(unsigned char *)hexes
{
    NSUInteger stringLength = string.length;
    
    if(stringLength%2 != 0)
        return;
    
    for (NSUInteger count = 0; count < string.length; count+=2) {
        
        unichar firstByte = [string characterAtIndex:count];
        unichar secondByte = [string characterAtIndex:count + 1];
        
        if(firstByte < '0' || firstByte > 'f' || secondByte < '0' || secondByte > 'f')
            return;
        
        int firstByteValue = hexConversionTable[firstByte - '0'];
        int secondByteValue = hexConversionTable[secondByte - '0'];
        
        if(firstByteValue >= 0 && secondByteValue >= 0)
        {
            hexes[count/2] = (firstByteValue * 16) + secondByteValue;
        }
        else
        {
            return;
        }   
    }
}

+(void)checksumOfFile:(NSString *)file hex:(unsigned char *)hexes
{
    CC_MD5_CTX * ctx = malloc(sizeof(CC_MD5_CTX));
    CC_MD5_Init(ctx);
    
    NSData * data = [NSData dataWithContentsOfFile:file];
    
    CC_MD5_Update(ctx, [data bytes], [data length]);
    
    CC_MD5_Final(hexes, ctx);
    
    free(ctx);
}

+(BOOL)isFile:(NSString *)file0
   equalToFile:(NSString *)file1
{
    unsigned char digest0[CC_MD5_DIGEST_LENGTH];
    unsigned char digest1[CC_MD5_DIGEST_LENGTH];
    
    [Commons checksumOfFile:file0 hex:digest0];
    [Commons checksumOfFile:file1 hex:digest1];
    
    return (memcmp(digest0, digest1, CC_MD5_DIGEST_LENGTH) == 0);
}

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

/* Settings keys */
static NSString * MFExploraServerAddressKey = @"MFExploraServerAddress";
static NSString * MFExploraUseDevelopmentDatabaseKey = @"MFExploraUseDevelopmentDatabase";
static NSString * MFExploraUseRWDatabaseKey = @"MFexploraUseRWDatabase";
static NSString * MFExploraCurrentSessionIDKey = @"MFExploraCurrentSessionID";
static NSString * MFExploraUploadServerAddressKey = @"MFExploraUploadServerAddress";
static NSString * MFExploraUploadServerPortKey = @"MFExploraUploadServerPort";
static NSString * MFExploraUploadDatabaseDirectoryKey = @"MFExploraUploadDatabaseDirectoryKey";

/* Settings fallback values */
static NSString * MFExploraDefaultServerAddress = @"bundles.mobfarm.eu";
static NSString * MFExploraDefaultUploadServerAddress = @"mobfarm.eu";
static NSUInteger MFExploraDefaultUploadServerPort = 17345;
static NSString * MFExploraDefaultUploadDatabaseDirectory = @"DatabaseUpdates";

#pragma mark - Settings for server address

+(NSString *)serverAddress
{
    NSString * address = [[NSUserDefaults standardUserDefaults]valueForKey:MFExploraServerAddressKey];
    
    if(address.length <= 0)
    {
        address = MFExploraDefaultServerAddress;
    }
    
    return address;
}

+(NSString *)httpServerAddress
{
    NSString * address = [Commons serverAddress];
    
    if([address hasPrefix:@"http"])
    {
        return address;
    }
    else
    {
        return [@"http://" stringByAppendingString:address];
    }
}

+(void)setServerAddress:(NSString *)address
{
    if(address.length > 0)
    {
        [[NSUserDefaults standardUserDefaults]setValue:address
                                                forKey:MFExploraServerAddressKey];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MFExploraServerAddressKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Settings for upload server

+(NSString *)uploadServerAddress
{
    NSString * address = [[NSUserDefaults standardUserDefaults] valueForKey:MFExploraUploadServerAddressKey];
    
    if(address.length <= 0)
    {
        address = MFExploraDefaultUploadServerAddress;
    }
    
    return address;
}

+(void)setUploadServerAddress:(NSString *)address;
{
    if(address.length > 0)
    {
        [[NSUserDefaults standardUserDefaults]setValue:address
                                                forKey:MFExploraUploadServerAddressKey];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MFExploraUploadServerAddressKey];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(NSUInteger)uploadServerPort
{
    NSUInteger port = [[[NSUserDefaults standardUserDefaults]valueForKey:MFExploraUploadServerPortKey]unsignedIntegerValue];
    
    if(port <= 0)
    {
        port = MFExploraDefaultUploadServerPort;
    }
    
    return port;
}

+(void)setUploadServerPort:(NSUInteger)port
{
    if(port > 0)
    {
        [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithUnsignedInteger:port]
                                                forKey:MFExploraUploadServerPortKey];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MFExploraUploadServerPortKey];
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}


+(NSString *)databaseUploadDirectory
{
    NSString * directory = [[NSUserDefaults standardUserDefaults] valueForKey:MFExploraUploadDatabaseDirectoryKey];
    
    if(directory.length <= 0)
    {
        directory = MFExploraDefaultUploadDatabaseDirectory;
    }
    
    return directory;
}

+(void)setDatabaseUploadDirectory:(NSString *)directory
{
    if(directory.length > 0)
    {
        [[NSUserDefaults standardUserDefaults]setValue:directory
                                                forKey:MFExploraUploadDatabaseDirectoryKey];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MFExploraUploadDatabaseDirectoryKey];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - Date formatters

+(NSDateFormatter *)filesystemSafeDateFormatter
{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd_HH'h'mm'm'ss's'"];
        formatter = dateFormatter;
    });
    return formatter;
}

+(NSDateFormatter *)defaultDateFormatter
{
    static NSDateFormatter * formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        formatter = dateFormatter;
    });
    return formatter;
}

#pragma mark - Paths and URLs

+(NSURL *)URLForApplicationLibraryDirectory
{
    return [[[NSFileManager defaultManager]URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask]lastObject];
}

+(NSString *)filePathForApplicationLibraryDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

+(NSString *)filePathForApplicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+(NSString *)filePathForApplicationTemporaryDirectory
{
    return NSTemporaryDirectory();
}

+(NSURL *)URLForApplicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
}

+(NSString *)filePathForApplicationCachesDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+(NSString *)URLForApplicationCacheDirectory
{
    return [NSURL fileURLWithPath:[Commons filePathForApplicationCachesDirectory]];
}

#pragma mark - Settings for DB

+(BOOL)useReadWriteDatabase
{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:MFExploraUseRWDatabaseKey]boolValue];
}

+(void)setUseReadWriteDatabase:(BOOL)useRWorNot
{
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:useRWorNot] forKey:MFExploraUseRWDatabaseKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(BOOL)useDevelopmentDatabase
{
    return [[[NSUserDefaults standardUserDefaults]valueForKey:MFExploraUseDevelopmentDatabaseKey]boolValue];
}

+(void)setUseDevelopmentDatabase:(BOOL)useOrNot
{
    [[NSUserDefaults standardUserDefaults]setValue:[NSNumber numberWithBool:useOrNot] forKey:MFExploraUseDevelopmentDatabaseKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}


#pragma mark - Settings for saved session

+(NSString *)currentSessionID
{
    return [[NSUserDefaults standardUserDefaults]valueForKey:MFExploraCurrentSessionIDKey];
}

+(void)setCurrentSessionID:(NSString *)sessionID
{
    if(sessionID.length > 0)
    {
        [[NSUserDefaults standardUserDefaults]setValue:sessionID forKey:MFExploraCurrentSessionIDKey];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MFExploraCurrentSessionIDKey];
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark - Others

+(NSString *)filesystemSafeMACAddress
{
    NSString * MACAddress = [Commons MACAddress];
    
    return [MACAddress stringByReplacingOccurrencesOfString:@":" withString:@""];
}

+(NSString *)MACAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        MFLogError(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    //MFLogError(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}


@end
