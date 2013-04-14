//
//  CAProject.m
//  CoffeeScriptAtOnce
//
//  Created by Tatsuya Tobioka on 12/05/12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CAProject.h"
#import "CAUtil.h"
#import "CAProjectManager.h"

NSString *CAProjectDidFinishAddLib = @"CAProjectDidFinishAddLib";

NSString *CAProjectDidFinishImportHtml = @"CAProjectDidFinishImportHtml";
NSString *CAProjectDidFinishImportCss = @"CAProjectDidFinishImportCss";
NSString *CAProjectDidFinishImportJs = @"CAProjectDidFinishImportJs";

NSString *CAProjectDidFailImportHtml = @"CAProjectDidFailImportHtml";
NSString *CAProjectDidFailImportCss = @"CAProjectDidFailImportCss";
NSString *CAProjectDidFailImportJs = @"CAProjectDidFailImportJs";

//NSString *lib = @"$lib";
NSString *lib = @"ext";

enum {
    CAProjectImportModeHtml,  
    CAProjectImportModeCss,  
    CAProjectImportModeJs    
};

@implementation CAProject

@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize createdAt = _createdAt;
@synthesize updatedAt = _updatedAt;
@synthesize gistId = _gistId;

@synthesize isCoffeeScript = _isCoffeeScript;
@synthesize isJQuery = _isJQuery;
@synthesize isOnError = _isOnError;
@synthesize isConsoleLog = _isConsoleLog;

# pragma mark - Initialization

//- (id)init {
- (id)initWithIsCoffeeScript:(BOOL)isCoffeeScript isJQuery:(BOOL)isJQuery {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"template" ofType:nil];
    self = [self _init:path];
    
    self.isCoffeeScript = isCoffeeScript;
    self.isJQuery = isJQuery;

    NSString *allJsContent = [NSMutableString stringWithString:[self loadJs]];
    NSString *jsPattern = [NSString stringWithFormat:@"// %@\n(.+?)\n//", [self _langLabel]];
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:jsPattern options:NSRegularExpressionUseUnixLineSeparators | NSRegularExpressionDotMatchesLineSeparators error:&error];
    
    if (error) {
        [CAUtil showError:[error localizedDescription]];
    }

    NSTextCheckingResult *match = [regexp firstMatchInString:allJsContent options:0 range:NSMakeRange(0, allJsContent.length)];
    
    NSString *jsContent = [allJsContent substringWithRange:[match rangeAtIndex:1]];

    LOG(@"pattern: %@, matche %d content: %@", jsPattern, match.numberOfRanges,  jsContent);
    
    [self saveJs:jsContent];
    
    return self;
}

- (id)initFromProject:(CAProject *)project {
    NSString *path = [project projectPath];
    self = [self _init:path];
    
    int count = 2;
    NSString *format = @"%@ %d";
    NSString *name = [NSString stringWithFormat:format, project.name, count]; 
    while ([[CAProjectManager sharedManager] isExists:name]) {
        name = [NSString stringWithFormat:format, project.name, count++];
    }
    self.name = name;
    
    self.isCoffeeScript = project.isCoffeeScript;
    self.isJQuery = project.isJQuery;
    self.isOnError = project.isOnError;
    self.isConsoleLog = project.isConsoleLog;
    
    return self;
}

- (id)_init:(NSString *)fromPath {
    self = [super init];
    if (self) {
        // identifier
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        _identifier = (NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        NSDate *now = [NSDate date];
        self.createdAt = now;
        self.updatedAt = now;

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;

        NSString *toPath = [self projectPath];
        [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
        LOG(@"from:%@, to:%@", fromPath, toPath);

        if (error) {
            [CAUtil showError:[error localizedDescription]];
        }

        /*
        NSString *libSymPath = [[self _buildPath] stringByAppendingPathComponent:@"lib"];
        NSString *libPath = [self _libPath];
        [fileManager createSymbolicLinkAtPath:libSymPath withDestinationPath:libPath error:&error];
        */
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _identifier = [[decoder decodeObjectForKey:@"identifier"] retain];
    _name = [[decoder decodeObjectForKey:@"name"] retain];
    _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
    _updatedAt = [[decoder decodeObjectForKey:@"updatedAt"] retain];

    _gistId = [[decoder decodeObjectForKey:@"gistId"] retain];
    
    _isCoffeeScript = [decoder decodeBoolForKey:@"isCoffeeScript"];
    _isJQuery = [decoder decodeBoolForKey:@"isJQuery"];
    _isOnError = [decoder decodeBoolForKey:@"isOnError"];
    _isConsoleLog = [decoder decodeBoolForKey:@"isConsoleLog"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:_identifier forKey:@"identifier"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_updatedAt forKey:@"updatedAt"];
    
    [encoder encodeObject:_gistId forKey:@"gistId"];

    [encoder encodeBool:_isCoffeeScript forKey:@"isCoffeeScript"];
    [encoder encodeBool:_isJQuery forKey:@"isJQuery"];
    [encoder encodeBool:_isOnError forKey:@"isOnError"];
    [encoder encodeBool:_isConsoleLog forKey:@"isConsoleLog"];
    
}

- (void)dealloc {
    [_identifier release], _identifier = nil;
    [_name release], _name = nil;
    [_createdAt release], _createdAt = nil;
    [_updatedAt release], _updatedAt = nil;
    [_gistId release], _gistId = nil;
    
    [super dealloc];
}

# pragma mark - View

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@] %@", [self _langLabel], _name];
}

- (NSString *)_langLabel {
    
    NSMutableArray *labels = [NSMutableArray array];
    
    if (_isCoffeeScript) {
        [labels addObject:@"CS"];
    }
    if (_isJQuery) {
        [labels addObject:@"jQ"];
    }

    if (!_isCoffeeScript && !_isJQuery) {
        [labels addObject:@"JS"];
    }
        
    return [NSString stringWithFormat:@"%@", [labels componentsJoinedByString:@","]];
}

# pragma mark - Utility

- (NSString *)projectPath {
    NSString *path = [[[CAProjectManager sharedManager] projectsPath] stringByAppendingPathComponent:self.identifier];
    return path;
}

- (NSString *)_srcPath {
    NSString *path = [[self projectPath] stringByAppendingPathComponent:@"src"];
    return path;
}

- (NSString *)_buildPath {
    NSString *path = [[self projectPath] stringByAppendingPathComponent:@"build"];
    return path;
}

- (NSString *)_libPath {
    NSString *path = [[self projectPath] stringByAppendingPathComponent:@"ext"];
    return path;
}

# pragma mark - File Access

- (NSString *)loadHtml {
    NSString *content = [self _loadFile:@"index.html"];
    return content;
}

- (NSString *)loadBuildHtml {
    NSString *path = [[self _buildPath] stringByAppendingPathComponent:@"index.html"];
    NSError *error = nil;
    
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        [CAUtil showError:[error localizedDescription]];
    }

    return content;
}

- (void)saveHtml:(NSString *)content {
    [self _saveFile:@"index.html" content:content path:[self _srcPath]];
}

- (NSString *)loadCss {
    NSString *content = [self _loadFile:@"style.css"];
    return content;
}

- (void)saveCss:(NSString *)content {
    [self _saveFile:@"style.css" content:content path:[self _srcPath]];
}

- (NSString *)loadJs {
    NSString *content = [self _loadFile:@"script.js"];
    return content;
}

- (void)saveJs:(NSString *)content {
    [self _saveFile:@"script.js" content:content path:[self _srcPath]];
}

- (NSString *)_loadFile:(NSString *)filename {
    NSString *path = [[self _srcPath] stringByAppendingPathComponent:filename];
    NSError *error = nil;
    
    LOG(@"load filepath: %@", path);
    
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    LOG(@"load content: %@", content);
    
    if (error) {
        [CAUtil showError:[error localizedDescription]];
    }

    return content;
}

- (void)_saveFile:(NSString *)filename content:(NSString *)content path:(NSString *)path {
    NSString *filePath = [path stringByAppendingPathComponent:filename];
    NSError *error = nil;
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        [CAUtil showError:[error localizedDescription]];
    }
}

- (void)addLib:(NSString *)urlString {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f];
        
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        
        if (!error) {
            NSString *path = [[self _libPath] stringByAppendingPathComponent:[urlString lastPathComponent]];
            [data writeToFile:path atomically:YES];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CAUtil showError:[error localizedDescription]];
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            // Notification, update status
            NSMutableDictionary *userInfo;
            userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:self forKey:@"project"];
        
            [[NSNotificationCenter defaultCenter] 
             postNotificationName:CAProjectDidFinishAddLib object:self userInfo:userInfo];
        });
    });
}

- (void)removeLib:(NSString *)name {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[self _libPath] stringByAppendingPathComponent:name];
    [fileManager removeItemAtPath:path error:&error];    
    
    if (error) {
        [CAUtil showError:[error localizedDescription]];
    }

}

- (NSURLRequest *)loadLib:(NSString *)lib {
    NSString *path = [[self _libPath] stringByAppendingPathComponent:lib];
    NSURL *url = [NSURL fileURLWithPath:path];
    LOG(@"liburl :%@", url);
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f];
    return request;
}

- (NSArray *)libs {

    NSString *path = [self _libPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSArray *filenames = [fileManager contentsOfDirectoryAtPath:path error:&error];
    NSMutableArray *libs = [NSMutableArray array];
    for (int i = 0; i < filenames.count; i++) {
        NSString *filename = [filenames objectAtIndex:i];
        [libs addObject:filename];
    }
    
    if (error) {
        [CAUtil showError:[error localizedDescription]];
    }

    return libs;
}

# pragma mark - Build

- (NSURLRequest *)build {
    
    //NSString *title = @"<!-- csatonce_title -->";
    //NSString *styles = @"<!-- csatonce_styles -->";
    //NSString *scripts = @"<!-- csatonce_scripts -->";
    NSString *title = @"$title";
    NSString *styles = @"$styles";
    NSString *scripts = @"$scripts";
    
    NSMutableString *htmlContent = [NSMutableString stringWithString:[self loadHtml]];
    [htmlContent replaceOccurrencesOfString:title withString:self.name options:0 range:NSMakeRange(0, htmlContent.length)];    

    [htmlContent replaceOccurrencesOfString:styles withString:[self _styles] options:0 range:NSMakeRange(0, htmlContent.length)];    
    
    [htmlContent replaceOccurrencesOfString:scripts withString:[self _scripts] options:0 range:NSMakeRange(0, htmlContent.length)];    

    [htmlContent replaceOccurrencesOfString:[NSString stringWithFormat:@"$%@", lib] withString:[NSString stringWithFormat:@"../%@", lib] options:0 range:NSMakeRange(0, htmlContent.length)];    
     
    NSMutableString *cssContent = [NSMutableString stringWithString:[self loadCss]];
    NSMutableString *jsContent = [NSMutableString stringWithString:[self loadJs]];
    
    NSString *htmlPath = [[self _buildPath] stringByAppendingPathComponent:@"index.html"];
    NSString *cssPath = [[self _buildPath] stringByAppendingPathComponent:@"style.css"];
    NSString *jsPath = [[self _buildPath] stringByAppendingPathComponent:@"script.js"];
    
    NSError *error = nil;
    [htmlContent writeToFile:htmlPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [cssContent writeToFile:cssPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [jsContent writeToFile:jsPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        [CAUtil showError:[error localizedDescription]];
    }

    NSURL *url = [NSURL fileURLWithPath:htmlPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f]; 
    
    
    LOG(@"buildedjs %@", jsContent);
    
    return request;
}

- (NSString *)_styles {
    NSMutableString *styles = [NSMutableString string];
    
    [styles appendString:@"<link rel=\"stylesheet\" href=\"style.css\" />\n"];
    
    return styles;
}

- (NSString *)_scripts {
    NSMutableString *scripts = [NSMutableString string];
    

    if (self.isConsoleLog || self.isOnError) {
        NSString *csatoncePath = [[NSBundle mainBundle] pathForResource:@"csatonce.js" ofType:nil];
        NSURL *csatonceURL = [NSURL fileURLWithPath:csatoncePath];
        [scripts appendFormat:@"<script src=\"%@\"></script>\n", [csatonceURL absoluteString]];                
    }
    
    if (self.isConsoleLog) {
        NSString *consolePath = [[NSBundle mainBundle] pathForResource:@"console-log.js" ofType:nil];
        NSURL *consoleURL = [NSURL fileURLWithPath:consolePath];        
        [scripts appendFormat:@"<script src=\"%@\"></script>\n", [consoleURL absoluteString]];        
    }

    if (self.isOnError) {
        NSString *onErrorPath = [[NSBundle mainBundle] pathForResource:@"on-error.js" ofType:nil];
        NSURL *onErrorURL = [NSURL fileURLWithPath:onErrorPath];
        [scripts appendFormat:@"<script src=\"%@\"></script>\n", [onErrorURL absoluteString]];        
    }

    if (self.isJQuery) {
        NSString *jQPath = [[NSBundle mainBundle] pathForResource:@"jquery.js" ofType:nil];
        NSURL *jQURL = [NSURL fileURLWithPath:jQPath];
        //[scripts appendString:@"<script src=\"../lib/jquery.js\"></script>\n"];
        //[scripts appendFormat:@"<script src=\"$%@/jquery.js\"></script>\n", lib];
        [scripts appendFormat:@"<script src=\"%@\"></script>\n", [jQURL absoluteString]];
    }
    
    if (self.isCoffeeScript) {
        NSString *coffeePath = [[NSBundle mainBundle] pathForResource:@"coffee-script.js" ofType:nil];
        NSURL *coffeeURL = [NSURL fileURLWithPath:coffeePath];
        [scripts appendString:@"<script type=\"text/coffeescript\" src=\"script.js\"></script>\n"];        
        //[scripts appendString:@"<script src=\"../lib/coffee-script.js\"></script>\n"];        
        //[scripts appendFormat:@"<script src=\"$%@/coffee-script.js\"></script>\n", lib];        
        [scripts appendFormat:@"<script src=\"%@\"></script>\n", [coffeeURL absoluteString]];        
    } else {
        [scripts appendString:@"<script src=\"script.js\"></script>\n"];        
    }
    
    return scripts;
}

- (void)importHtml:(NSString *)urlString {    
    [self _import:urlString mode:CAProjectImportModeHtml notification:CAProjectDidFinishImportHtml errorNotification:CAProjectDidFailImportHtml];
}

- (void)importCss:(NSString *)urlString {    
    [self _import:urlString mode:CAProjectImportModeCss notification:CAProjectDidFinishImportCss errorNotification:CAProjectDidFailImportCss];
}

- (void)importJs:(NSString *)urlString {    
    [self _import:urlString mode:CAProjectImportModeJs notification:CAProjectDidFinishImportJs errorNotification:CAProjectDidFailImportJs];
}

- (void)_import:(NSString *)urlString mode:(int)mode notification:(NSString *)notification errorNotification:(NSString *)errorNotification {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0f];
        
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];

        NSMutableDictionary *userInfo;
        userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:self forKey:@"project"];        

        if (!error) {
            NSString *content = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            if (content.length > 0) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                switch (mode) {
                    case CAProjectImportModeHtml:
                        [self saveHtml:content];
                        break;
                    case CAProjectImportModeCss:
                        [self saveCss:content];
                        break;
                    case CAProjectImportModeJs:
                        [self saveJs:content];
                        break;
                }
                //});
            }
            dispatch_async(dispatch_get_main_queue(), ^{            
                [[NSNotificationCenter defaultCenter] 
                 postNotificationName:notification object:self userInfo:userInfo];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [CAUtil showError:[error localizedDescription]];
                [[NSNotificationCenter defaultCenter] 
                 postNotificationName:errorNotification object:self userInfo:userInfo];
            });
        }
        
    });
}

# pragma mark - Data
- (NSData *)htmlData {
    return [self _data:@"index.html"];
}

- (NSData *)cssData {
    return [self _data:@"style.css"];    
}

- (NSData *)jsData {
    return [self _data:@"script.js"];
}

- (NSData *)_data:(NSString *)filename {
    NSString *path = [[self _srcPath] stringByAppendingPathComponent:filename];

    NSData *data = [NSData dataWithContentsOfFile:path];
    
    return data;
}


@end
