<jittershader name="default">
	<description>Default Slab </description>
	<param name="scale" type="float" default="1.0" />
	<param name="tex0" type="int" default="0" />
	<param name="modelViewProjectionMatrix" type="mat4" state="MODELVIEW_PROJECTION_MATRIX" />
	<param name="textureMatrix0" type="mat4" state="TEXTURE0_MATRIX" />
	<param name="position" type="vec3" state="POSITION" />
	<param name="texcoord" type="vec2" state="TEXCOORD" />
	<param name="color" type="vec4" state="COLOR" />
	<language name="glsl" version="1.5">
		<bind param="scale" program="fp" />
		<bind param="tex0" program="fp" />
		<bind param="modelViewProjectionMatrix" program="vp" />
		<bind param="textureMatrix0" program="vp" />
		<bind param="position" program="vp" />
		<bind param="texcoord" program="vp" />
		<bind param="color" program="vp" />
		<program name="vp" type="vertex"  >
		<![CDATA[
			#version 330 core
			
			in vec3 position;
			in vec2 texcoord;
			in vec4 color;
			out jit_PerVertex {
				vec2 texcoord;
				vec4 color;
			} jit_out;
			uniform mat4 modelViewProjectionMatrix;
			uniform mat4 textureMatrix0;
			
			void main(void) {
				gl_Position = modelViewProjectionMatrix*vec4(position, 1.);
				jit_out.texcoord = vec2(textureMatrix0*vec4(texcoord, 0., 1.));
				jit_out.color = color;
			}
		]]>
		</program>
		
		<program name="fp" type="fragment"  >
		<![CDATA[
			#version 330 core
			
			in jit_PerVertex {
				vec2 texcoord;
				vec4 color;
			} jit_in;
			layout (location = 0) out vec4 outColor;
			
			uniform sampler2DRect tex0;
			uniform float scale;
			void main(void) {
				outColor = texture(tex0, jit_in.texcoord) * jit_in.color * scale;
			}
		]]>
		</program>
	</language>
</jittershader>
