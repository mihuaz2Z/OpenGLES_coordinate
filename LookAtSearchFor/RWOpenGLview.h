//
//  RWOpenGLview.h
//  RWOpenGL
//
//  Created by Ruiwen Feng on 2017/6/14.
//  Copyright © 2017年 Ruiwen Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>


@protocol RWOpenGLviewProtocol <NSObject>
- (void)glSetup;
@end

@interface RWOpenGLview : UIView <RWOpenGLviewProtocol>
@property (strong,nonatomic)CAEAGLLayer  *eaglLayer;
@property (strong,nonatomic)EAGLContext  *context;
@property (assign,nonatomic)GLuint        colorRenderBuffer;
@property (assign,nonatomic)GLuint        frameBuffer;

- (GLuint)genProgramVertexShaderString:(NSString*)vertexString fragmentShaderString:(NSString*)fragmentString;
- (void)glSetupProgramSetup:(void(^)(void))programSetup_Block kit_vaoOrvbo_Setup:(void(^)(void))vaoSetup_Block;
- (void)reset;
@end
