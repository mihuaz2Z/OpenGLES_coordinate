//
//  RWOpenGLview.m
//  RWOpenGL
//
//  Created by Ruiwen Feng on 2017/6/14.
//  Copyright © 2017年 Ruiwen Feng. All rights reserved.
//

#import "RWOpenGLview.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface RWOpenGLview () <UIScrollViewDelegate>
@property (copy,nonatomic) void(^programSetup)(void);
@property (copy,nonatomic) void(^vaoSetup)(void);
//@property (copy,nonatomic) void(^programSetup)(void);

@end

@implementation RWOpenGLview

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reset)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];
        
        [self _glSetup];
        
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self _glSetup];

    }
    return self;
}

-(void)handlePinches:(UIPinchGestureRecognizer *)gesture{
    if (gesture.velocity > 0) {
        [self zoomIn];
    }
    else if (gesture.velocity < 0){
        [self zoomOut];
    }
}

- (void)zoomIn {
    
}

- (void)zoomOut {
    
}

- (void)reset {
    
}


-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
   return self;
}

- (void)_glSetup {
    if (_eaglLayer) {
        return;
    }
    [self _setupLayer];
    [self _setupContext];
    
    if ([self respondsToSelector:NSSelectorFromString(@"glSetup")]) {
        [self performSelector:@selector(glSetup)];
    }
}

- (void)glSetupProgramSetup:(void(^)(void))programSetup_Block kit_vaoOrvbo_Setup:(void(^)(void))vaoSetup_Block{
    programSetup_Block();
    vaoSetup_Block();
}

- (void)_setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)_setupContext
{
    // 设置OpenGLES的版本为3.0
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 3.0 context");
        exit(1);
    }
    
    // 将当前上下文设置为我们创建的上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}


#pragma mark - ======= =======

- (GLuint)genProgramVertexShaderString:(NSString*)vertexString fragmentShaderString:(NSString*)fragmentString {
    
    GLuint vertexShader = [self compileShader:vertexString withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:fragmentString withType:GL_FRAGMENT_SHADER];

    GLuint programObject = glCreateProgram();
    if (programObject == 0)
    {
        return 0;
    }
    
    glAttachShader(programObject, vertexShader);
    glAttachShader(programObject, fragmentShader);
    
    glLinkProgram(programObject);

    GLint linked;
    glGetProgramiv(programObject, GL_LINK_STATUS, &linked);
    if (!linked)
    {
        GLint infoLen = 0;
        
        glGetProgramiv(programObject, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1)
        {
            char *infoLog = (char *)malloc(sizeof(char)* infoLen);
            
            glGetProgramInfoLog(programObject, infoLen, NULL, infoLog);
            printf("Error linking program:\n%s\n", infoLog);
            
            free(infoLog);
        }
        
        glDeleteProgram(programObject);
        return FALSE;
    }
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return programObject;
}

//编译shader
- (GLuint)compileShader:(NSString*)shaderString withType:(GLenum)shaderType
{
    //创建shader句柄
    GLuint shaderHandle = glCreateShader(shaderType);
    
    
    const GLchar* source = (GLchar *)[shaderString UTF8String];
    
    //将文件内容设置给shader
    glShaderSource(shaderHandle, 1,&source,NULL);
    //编译shader
    glCompileShader(shaderHandle);
    GLint infoLen = 0;
    //获取状态
    glGetShaderiv(shaderHandle, GL_INFO_LOG_LENGTH, &infoLen);
    if (infoLen > 1) {
        GLchar messages[infoLen];
        glGetShaderInfoLog(shaderHandle,infoLen, 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
    }
    
    return shaderHandle;
}


#pragma mark - ======= =======
- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    [self destoryRenderAndFrameBuffer];
    [self setupFrameAndRenderBuffer];
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - =======Clean=======
- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}


- (void)setupFrameAndRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)dealloc
{
    [self destoryRenderAndFrameBuffer];
}

@end
