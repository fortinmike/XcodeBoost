//
//  MFClangHelper.m
//  XcodeBoost
//
//  Created by Michaël Fortin on 2014-04-06.
//  Copyright (c) 2014 Michaël Fortin. All rights reserved.
//

#import "MFClangHelper.h"
#import "Index.h"

// Reference: https://www.mikeash.com/pyblog/friday-qa-2014-01-24-introduction-to-libclang.html
//            http://clang.llvm.org/docs/index.html

@implementation MFClangHelper

- (NSArray *)printDiagnostics
{
	CXTranslationUnit tu = [self translationUnit];
	
	unsigned diagnosticCount = clang_getNumDiagnostics(tu);
	
	for(unsigned i = 0; i < diagnosticCount; i++)
	{
        CXDiagnostic diagnostic = clang_getDiagnostic(tu, i);
		CXSourceLocation location = clang_getDiagnosticLocation(diagnostic);
		unsigned line, column;
		clang_getSpellingLocation(location, NULL, &line, &column, NULL);
		CXString text = clang_getDiagnosticSpelling(diagnostic);
		
		NSLog(@"%s", clang_getCString(text));
		
		clang_disposeString(text);
	}
	
	return nil;
}

- (CXTranslationUnit)translationUnit
{
	// TODO: Use project's include paths
	const char *args[] =
	{
		"-I/usr/include",
		"-I."
	};
	int numArgs = sizeof(args) / sizeof(*args);
	
	CXIndex index = clang_createIndex(0, 0);
	CXTranslationUnit translationUnit = clang_parseTranslationUnit(index, "somefile.m", args, numArgs, NULL, 0, CXTranslationUnit_None);
	
	return translationUnit;
}

@end