//
//  Commons.h
//  CustomContainerViewControllerTest
//
//  Created by Nicolò Tosi on 6/6/13.
//  Copyright (c) 2013 MobFarm. All rights reserved.
//

#ifndef Commons_h
#define Commons_h

#define TOLERANCE 0.1 // !!!

#define IS_ZERO(x) (ABS((x)) < FLT_EPSILON)

static BOOL lineIntersection(CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, CGPoint * where);
static CGPoint lineSecondPoint(CGPoint p0, float angle);
static CGFloat crossProduct2D(CGPoint p0, CGPoint p1);
static CGFloat dotProduct2D(CGPoint p0, CGPoint p1);
static BOOL boxLineIntersection(CGPoint l0, CGPoint l1, CGPoint b0, CGPoint b1, CGPoint b2, CGPoint b3, CGPoint * x0, CGPoint * x1);
static BOOL liesOnSegment(CGPoint p0, CGPoint s0, CGPoint s1);
static CGFloat pointToPointDistance(CGPoint p0, CGPoint p1);
static BOOL pointCoincideToPoint(CGPoint p0, CGPoint p1);
static CGPoint subtractPointToPoint(CGPoint p0, CGPoint p1);

#ifndef ZEROED_RECT
#define ZEROED_RECT(x) CGRectMake(0,0,(x).size.width,(x).size.height)
#endif

#ifndef RECT_POS
#define RECT_POS(z) CGPointMake((z).origin.x + (z).size.width * 0.5, (z).origin.y + (z).size.height * 0.5)
#endif

static CGRect rectWithSize(CGSize size)
{
    return CGRectMake(0, 0, size.width, size.height);
}

static float clip(float v, float min, float max)
{
	return	MAX(min,MIN(v,max));
}

static float circumscribedRadius(CGRect rect)
{
    CGFloat halfWidth = rect.size.width/2;
    CGFloat halfWidthSquared = halfWidth * halfWidth;
    CGFloat halfHeight = rect.size.height/2;
    CGFloat halfHeightSquared = halfHeight * halfHeight;
    return sqrtf(halfHeightSquared + halfWidthSquared);
}

static CGPoint shiftVector(CGFloat distance, float angle)
{
    CGFloat dx, dy;
    
    dx = ceilf(cosf(angle) * distance);
    dy = ceilf(sinf(angle) * distance);
    
    return CGPointMake(dx, dy);
}

static CGPoint shiftCenter(CGPoint start, CGFloat distance, float angle)
{
    CGPoint shift = shiftVector(distance, angle);
    return CGPointMake(start.x + shift.x, start.y + shift.y);
}

static CGPoint translationVector(CGRect rect, float angle)
{
    CGFloat dx, dy;
    CGFloat containerRadius = circumscribedRadius(rect);
    
    dx = clip(containerRadius * cosf(angle), -rect.size.width/2, rect.size.width/2);
    dy = clip(containerRadius * sinf(angle), -rect.size.height/2, rect.size.height/2);
    
    return CGPointMake(dx, dy);
}

static CGFloat pointToPointDistance(CGPoint p0, CGPoint p1)
{
    CGFloat deltaX = p0.x - p1.x;
    CGFloat deltaY = p0.y - p1.y;
    return sqrtf(deltaX * deltaX + deltaY * deltaY);
}

static BOOL boxLineIntersection(CGPoint l0, CGPoint l1, CGPoint b0, CGPoint b1, CGPoint b2, CGPoint b3, CGPoint * x0, CGPoint * x1)
{
    CGPoint firstIP, secondIP;
    BOOL firstIPfound = NO;
    BOOL secondIPfound = NO;
    
    CGPoint p = CGPointMake(FLT_MAX, FLT_MAX);
    
    if(lineIntersection(l0, l1, b0, b1, &p))
    {
        // NSLog(@"found %@", NSStringFromCGPoint(p));
        if(liesOnSegment(p, b0, b1))
        {
            firstIP = p, firstIPfound = YES;
        }
    }
    
    if(lineIntersection(l0, l1, b1, b2, &p))
    {
        // NSLog(@"found %@", NSStringFromCGPoint(p));
        if(liesOnSegment(p, b1, b2))
        {
            if(firstIPfound)
            {
                if(!pointCoincideToPoint(firstIP, p))
                {
                    secondIP = p, secondIPfound = YES;
                }
            }
            else
            {
                firstIP = p, firstIPfound = YES;
            }
        }
    }
    
    if(lineIntersection(l0, l1, b2, b3, &p))
    {
        // NSLog(@"found %@", NSStringFromCGPoint(p));
        if(liesOnSegment(p, b2, b3))
        {
            if(firstIPfound)
            {
                if(!pointCoincideToPoint(firstIP, p))
                {
                    secondIP = p, secondIPfound = YES;
                }
            }
            else
            {
                firstIP = p, firstIPfound = YES;
            }
        }
    }
    
    if(lineIntersection(l0, l1, b3, b0, &p))
    {
        // NSLog(@"found %@", NSStringFromCGPoint(p));
        if(liesOnSegment(p, b3, b0))
        {
            if(firstIPfound)
            {
                if(!pointCoincideToPoint(firstIP, p))
                {
                    secondIP = p, secondIPfound = YES;
                }
            }
            else
            {
                firstIP = p, firstIPfound = YES;
            }
        }
    }
    
    if(secondIPfound)
    {
        
        *x0 = firstIP;
        *x1 = secondIP;
        return YES;
    }
    else if (firstIPfound)
    {
        *x0 = *x1 = firstIP;
        return YES;
    }
    
    return NO;
}

static BOOL liesOnSegment(CGPoint p0, CGPoint s0, CGPoint s1)
{
    CGFloat deltaS = pointToPointDistance(s0, s1);
    CGFloat deltaPS0 = pointToPointDistance(p0, s0);
    CGFloat deltaPS1 = pointToPointDistance(p0, s1);
    
    if(fabsf(deltaS - (deltaPS0 + deltaPS1)) < TOLERANCE)
        return YES;
    
    return NO;
}

static CGPoint subtractPointToPoint(CGPoint p0, CGPoint p1)
{
    return CGPointMake(p1.x - p0.x, p1.y - p0.y);
}

static float dotProduct(CGPoint p0, CGPoint p1)
{
    return p0.x * p1.x + p0.y * p1.y;
}

static CGFloat crossProduct2D(CGPoint p0, CGPoint p1)
{
    return p0.x * p1.y - p0.y * p1.x;
}

static CGPoint lineSecondPoint(CGPoint p0, float angle)
{
    CGFloat dx = cosf(angle);
    CGFloat dy = sinf(angle);
    
    return CGPointMake(p0.x + dx, p0.y + dy);
}

static BOOL pointCoincideToPoint(CGPoint p0, CGPoint p1)
{
    return (fabs(pointToPointDistance(p0, p1)) < TOLERANCE);
}

static BOOL lineIntersection(CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, CGPoint * where)
{
    float det = (p0.x - p1.x) * (p2.y - p3.y) - (p0.y - p1.y) * (p2.x - p3.x);
    
    if(IS_ZERO(det))
        return NO;
    
	float x = ((p2.x - p3.x) * (p0.x * p1.y - p0.y * p1.x) - (p0.x - p1.x) * (p2.x * p3.y - p2.y * p3.x))/det;
	float y = ((p2.y - p3.y) * (p0.x * p1.y - p0.y * p1.x) - (p0.y - p1.y) * (p2.x * p3.y - p2.y * p3.x))/det;
	
    *where = CGPointMake(x, y);
    
	return YES;
}

@interface Commons : NSObject

+(NSString *)randomIdentifier;

+(void)checksumOfFile:(NSString *)file hex:(unsigned char *)hexes;
+(NSString *)checksumStringFromChecksumByteArray:(unsigned char *)checksum;
+(void)convertChecksumString:(NSString *)string toByteArray:(unsigned char *)hexes;
+(BOOL)isFile:(NSString *)file0
   equalToFile:(NSString *)file1;

+(NSString *)MACAddress;
+(NSString *)filesystemSafeMACAddress;

/* Update server */
+(void)setServerAddress:(NSString *)address;
+(NSString *)serverAddress;
+(NSString *)httpServerAddress;

/* Database preferences */
+(BOOL)useDevelopmentDatabase;
+(void)setUseDevelopmentDatabase:(BOOL)useOrNot;
+(BOOL)useReadWriteDatabase;
+(void)setUseReadWriteDatabase:(BOOL)useRWorNot;

/* Saved session ID */
+(void)setCurrentSessionID:(NSString *)sessionID;
+(NSString *)currentSessionID;

/* Upload server */
+(NSString *)uploadServerAddress;
+(void)setUploadServerAddress:(NSString *)address;
+(NSUInteger)uploadServerPort;
+(void)setUploadServerPort:(NSUInteger)port;

+(NSDateFormatter *)defaultDateFormatter;
+(NSDateFormatter *)filesystemSafeDateFormatter;

+(NSString *)databaseUploadDirectory;
+(void)setDatabaseUploadDirectory:(NSString *)directory;

+(NSURL *)URLForApplicationLibraryDirectory;
+(NSString *)filePathForApplicationLibraryDirectory;
+(NSString *)filePathForApplicationDocumentsDirectory;
+(NSURL *)URLForApplicationDocumentsDirectory;
+(NSString *)filePathForApplicationTemporaryDirectory;
+(NSString *)filePathForApplicationCachesDirectory;


@end

#endif
