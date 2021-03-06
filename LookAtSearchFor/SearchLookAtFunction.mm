//
//  SearchLookAtFunction.m
//  LookAtSearchFor
//
//  Created by Ruiwen Feng on 2017/6/28.
//  Copyright © 2017年 Ruiwen Feng. All rights reserved.
//

#import "SearchLookAtFunction.h"

#define sPerVertex	100
#define sSize  (sPerVertex * 6 * 3)

@implementation SearchLookAtFunction {
    
    GLuint cylinder_Program;
    GLuint v_Position_location;
    GLuint cylinderMvp_location;
    GLuint cylinderBuffer;
    GLfloat cylinder[sSize];
}

- (void)genData {
    float perRadius = 2 * 3.1415926 / (float)sPerVertex;
    
    int index = 0;

    for (int b = 0; b < sPerVertex; b++) {//W
        float x1 = (float)cosf(b* perRadius);
        float y1 = (float)sinf(b* perRadius);
        float z1 = (float)1;
        
        float x2 = (float)cosf(b * perRadius);
        float y2 = (float)sinf(b * perRadius);
        float z2 = (float)0;
        
        float x3 = (float)cosf((b + 1) * perRadius);
        float y3 = (float)sinf((b + 1) * perRadius);
        float z3 = (float)0;
        
        float x4 = (float)cosf((b + 1) * perRadius);
        float y4 = (float)sinf((b + 1) * perRadius);
        float z4 = (float)1;
        
        cylinder[index++] = x1; cylinder[index++] = y1; cylinder[index++] = z1;
        cylinder[index++] = x2; cylinder[index++] = y2; cylinder[index++] = z2;
        cylinder[index++] = x3; cylinder[index++] = y3; cylinder[index++] = z3;
        
        cylinder[index++] = x3; cylinder[index++] = y3; cylinder[index++] = z3;
        cylinder[index++] = x4; cylinder[index++] = y4; cylinder[index++] = z4;
        cylinder[index++] = x1; cylinder[index++] = y1; cylinder[index++] = z1;
    }

    
    for (NSUInteger i = 0 ; i < 24*3; i +=3) {
        printf("%f %f %f\n",cylinder[i],cylinder[i+1],cylinder[i+2]);
    }
    
}


- (void)glSetup {
    
    [self glSetupProgramSetup:^{
        
        NSBundle * bundle = [NSBundle mainBundle];
        NSString * vertext_path = [bundle pathForResource:@"Cylinder" ofType:@"vsh"];
        NSString * fragment_path = [bundle pathForResource:@"Cylinder" ofType:@"fsh"];
        NSString * vertext_string = [NSString stringWithContentsOfFile:vertext_path encoding:NSUTF8StringEncoding error:nil];
        NSString * fragment_string = [NSString stringWithContentsOfFile:fragment_path encoding:NSUTF8StringEncoding error:nil];
        cylinder_Program = [self genProgramVertexShaderString:vertext_string fragmentShaderString:fragment_string];
        
    } kit_vaoOrvbo_Setup:^{
        [self genData];

        glUseProgram(cylinder_Program);
        cylinderMvp_location = glGetUniformLocation(cylinder_Program, "cylinderMvp");
        v_Position_location = glGetAttribLocation(cylinder_Program, "v_Position");
        
        
        glGenBuffers(1, &cylinderBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, cylinderBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(cylinder), cylinder, GL_STATIC_DRAW);
        // Position attribute
        glVertexAttribPointer(v_Position_location, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid*)0);
        glEnableVertexAttribArray(v_Position_location);
        
        // Use the program object
        
        
        glViewport(0, 0, self.frame.size.width, self.frame.size.height);
        
        GLKMatrix4 project = GLKMatrix4Identity;
        project = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), 1.0, 0.1, 100);
        GLKMatrix4 lookat = GLKMatrix4Identity;
        lookat = GLKMatrix4MakeLookAt(1,1,1, 0, 0,0, 0, 1,0);
        GLKMatrix4 rotationx = GLKMatrix4Identity;
        rotationx = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1, 0, 0);
        lookat = GLKMatrix4Multiply(lookat,rotationx);
        GLKMatrix4 scale = GLKMatrix4Identity;
        scale = GLKMatrix4MakeScale(0.5f, 0.5f, 0.5f);
        lookat = GLKMatrix4Multiply(lookat,scale);
        GLKMatrix4 mvp = GLKMatrix4Multiply(project, lookat);
        glUniformMatrix4fv(cylinderMvp_location, 1, GL_FALSE, mvp.m);
    }];
}


- (void)disPlay {
    glClearColor(1.0f, 1.0f, 0.0f, 1.0f);
    glDrawArrays(GL_LINE_STRIP, 0, sSize/3);
    [self.context presentRenderbuffer:self.colorRenderBuffer];
}




@end
