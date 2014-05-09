//
//  MFMigrationManager.m
//  Obsidian
//
//  Created by Michaël Fortin on 10/21/2013.
//  Copyright (c) 2013 Michaël Fortin. All rights reserved.
//
//  Note: Inspired by https://github.com/mysterioustrousers/MTMigration
//

#import "MFMigrationManager.h"

@implementation MFMigrationManager
{
	NSString *_currentVersion;
	
	NSString *_initialVersionKey;
	NSString *_lastVersionKey;
	
	NSString *_previousVersion;
}

static NSString *MFMigrationManagerInitialVersionKey = @"MFMigrationManagerInitialVersionKey";
static NSString *MFMigrationManagerLastVersionKey = @"MFMigrationManagerLastVersionKey";

static NSString *MFMigrationManagerVersionRegexString = @"^([0-9]{1,2}\\.)+[0-9]{1,2}(-[0-9]{1,2})?$";

#pragma mark Lifetime

+ (instancetype)migrationManager
{
	return [[self alloc] init];
}

+ (instancetype)migrationManagerWithName:(NSString *)name
{
	return [[self alloc] initWithName:name currentVersion:nil];
}

+ (instancetype)migrationManagerWithCurrentVersion:(NSString *)currentVersion
{
	return [[self alloc] initWithName:nil currentVersion:currentVersion];
}

+ (instancetype)migrationManagerWithName:(NSString *)name currentVersion:(NSString *)currentVersion;
{
	return [[self alloc] initWithName:name currentVersion:currentVersion];
}

- (id)init
{
	return [self initWithName:nil];
}

- (id)initWithName:(NSString *)name
{
	return [self initWithName:name currentVersion:nil];
}

- (id)initWithCurrentVersion:(NSString *)currentVersion
{
	return [self initWithName:nil currentVersion:currentVersion];
}

- (id)initWithName:(NSString *)name currentVersion:(NSString *)currentVersion
{
	self = [super init];
	if (self)
	{
		_currentVersion = currentVersion ?: [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
		
		_initialVersionKey = name ? [MFMigrationManagerInitialVersionKey stringByAppendingFormat:@"-%@", name] : MFMigrationManagerInitialVersionKey;
		_lastVersionKey = name ? [MFMigrationManagerLastVersionKey stringByAppendingFormat:@"-%@", name] : MFMigrationManagerLastVersionKey;
		
		[self storeInitialVersion];
	}
	return self;
}

#pragma mark Public Methods

- (void)whenMigratingToVersion:(NSString *)version run:(void (^)())action
{
	[self assertVersionMatchesRegex:version];
	[self assertVersionSmallerThanCurrentVersion:version];
	[self assertVersionOrderIsValid:version];
	
	if ([self shouldMigrateToVersion:version])
	{
		action();
		
		[self setLastMigrationVersion:version];
		
		if ([self.delegate respondsToSelector:@selector(migrationManager:didMigrateToVersion:)])
			[self.delegate migrationManager:self didMigrateToVersion:version];
	}
}

- (void)reset
{
    [self setLastMigrationVersion:nil];
}

#pragma mark Implementation

- (void)storeInitialVersion
{
	if ([[self initialVersion] isEqualToString:@""])
		[self setInitialVersion:[self currentVersion]];
}

- (void)assertVersionOrderIsValid:(NSString *)version
{
	if (_previousVersion && ![self isVersion:version greaterThan:_previousVersion])
	{
		NSString *reason = [NSString stringWithFormat:@"Migration version %@ is defined after version %@, which is not permitted!", version, _previousVersion];
		@throw [NSException exceptionWithName:@"Migration Exception" reason:reason userInfo:nil];
	}
	
	_previousVersion = version;
}

- (void)assertVersionMatchesRegex:(NSString *)version
{
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:MFMigrationManagerVersionRegexString options:0 error:0];
	BOOL versionIsValid = ([regex numberOfMatchesInString:version options:0 range:NSMakeRange(0, [version length])] == 1);
	
	if (!version || !versionIsValid)
	{
		NSString *reason = [NSString stringWithFormat:@"Invalid version string \"%@\", see regex and spec for appropriate version format", version];
		@throw [NSException exceptionWithName:@"Migration Exception" reason:reason userInfo:nil];
	}
}

- (void)assertVersionSmallerThanCurrentVersion:(NSString *)version
{
	if ([self isVersionGreaterThanCurrentVersion:version])
	{
		NSString *reason = [NSString stringWithFormat:@"Cannot run migration for a version (%@) that is bigger than the current app version (%@)", version, [self currentVersion]];
		@throw [NSException exceptionWithName:@"Migration Exception" reason:reason userInfo:nil];
	}
}

- (BOOL)shouldMigrateToVersion:(NSString *)version
{
	return [self isVersion:version greaterThan:[self initialVersion]] &&
		   [self isVersion:version greaterThan:[self lastMigrationVersion]];
}

- (BOOL)isVersionGreaterThanCurrentVersion:(NSString *)version
{
	NSString *versionWithoutSubVersion = [version componentsSeparatedByString:@"-"][0];
	return [self isVersion:versionWithoutSubVersion greaterThan:[self currentVersion]];
}

- (BOOL)isVersion:(NSString *)version1 greaterThan:(NSString *)version2
{
	return ([version1 compare:version2 options:NSNumericSearch] == NSOrderedDescending);
}

- (NSString *)lastMigrationVersion
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:_lastVersionKey] ?: @"";
}

- (void)setLastMigrationVersion:(NSString *)version
{
	[[NSUserDefaults standardUserDefaults] setValue:version forKey:_lastVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)initialVersion
{
	return [[NSUserDefaults standardUserDefaults] valueForKey:_initialVersionKey] ?: @"";
}

- (void)setInitialVersion:(NSString *)version
{
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:_initialVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Helper Methods

// This method exists for stubbing in tests
- (NSString *)currentVersion
{
	return _currentVersion;
}

@end