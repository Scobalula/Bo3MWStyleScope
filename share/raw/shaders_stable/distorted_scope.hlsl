// Per Scene Consts sent by the game, we only need 1 value from it.
cbuffer PerSceneConsts : register(b1)
{
  row_major float4x4 projectionMatrix : packoffset(c0);
  row_major float4x4 viewMatrix : packoffset(c4);
  row_major float4x4 viewProjectionMatrix : packoffset(c8);
  row_major float4x4 inverseProjectionMatrix : packoffset(c12);
  row_major float4x4 inverseViewMatrix : packoffset(c16);
  row_major float4x4 inverseViewProjectionMatrix : packoffset(c20);
  float4 eyeOffset : packoffset(c24);
  float4 adsZScale : packoffset(c25);
  float4 hdrControl0 : packoffset(c26);
  float4 hdrControl1 : packoffset(c27);
  float4 fogColor : packoffset(c28);
  float4 fogConsts : packoffset(c29);
  float4 fogConsts2 : packoffset(c30);
  float4 fogConsts3 : packoffset(c31);
  float4 fogConsts4 : packoffset(c32);
  float4 fogConsts5 : packoffset(c33);
  float4 fogConsts6 : packoffset(c34);
  float4 fogConsts7 : packoffset(c35);
  float4 fogConsts8 : packoffset(c36);
  float4 fogConsts9 : packoffset(c37);
  float3 sunFogDir : packoffset(c38);
  float4 sunFogColor : packoffset(c39);
  float2 sunFog : packoffset(c40);
  float4 zNear : packoffset(c41);
  float3 clothPrimaryTint : packoffset(c42);
  float3 clothSecondaryTint : packoffset(c43);
  float4 renderTargetSize : packoffset(c44);
  float4 upscaledTargetSize : packoffset(c45);
  float4 materialColor : packoffset(c46);
  float4 cameraUp : packoffset(c47);
  float4 cameraLook : packoffset(c48);
  float4 cameraSide : packoffset(c49);
  float4 cameraVelocity : packoffset(c50);
  float4 skyMxR : packoffset(c51);
  float4 skyMxG : packoffset(c52);
  float4 skyMxB : packoffset(c53);
  float4 sunMxR : packoffset(c54);
  float4 sunMxG : packoffset(c55);
  float4 sunMxB : packoffset(c56);
  float4 skyRotationTransition : packoffset(c57);
  float4 debugColorOverride : packoffset(c58);
  float4 debugAlphaOverride : packoffset(c59);
  float4 debugNormalOverride : packoffset(c60);
  float4 debugSpecularOverride : packoffset(c61);
  float4 debugGlossOverride : packoffset(c62);
  float4 debugOcclusionOverride : packoffset(c63);
  float4 debugStreamerControl : packoffset(c64);
  float4 emblemLUTSelector : packoffset(c65);
  float4 colorMatrixR : packoffset(c66);
  float4 colorMatrixG : packoffset(c67);
  float4 colorMatrixB : packoffset(c68);
  float4 gameTime : packoffset(c69);
  float4 gameTick : packoffset(c70);
  float4 subpixelOffset : packoffset(c71);
  float4 viewportDimensions : packoffset(c72);
  float4 viewSpaceScaleBias : packoffset(c73);
  float4 ui3dUVSetup0 : packoffset(c74);
  float4 ui3dUVSetup1 : packoffset(c75);
  float4 ui3dUVSetup2 : packoffset(c76);
  float4 ui3dUVSetup3 : packoffset(c77);
  float4 ui3dUVSetup4 : packoffset(c78);
  float4 ui3dUVSetup5 : packoffset(c79);
  float4 clipSpaceLookupScale : packoffset(c80);
  float4 clipSpaceLookupOffset : packoffset(c81);
  uint4 computeSpriteControl : packoffset(c82);
  float4 invBcTexSizes : packoffset(c83);
  float4 invMaskTexSizes : packoffset(c84);
  float4 relHDRExposure : packoffset(c85);
  uint4 triDensityFlags : packoffset(c86);
  float4 triDensityParams : packoffset(c87);
  float4 voldecalRevealTextureInfo : packoffset(c88);
  float4 extraClipPlane0 : packoffset(c89);
  float4 extraClipPlane1 : packoffset(c90);
  float4 shaderDebug : packoffset(c91);
  uint isDepthHack : packoffset(c92);
}

// The data that is emitted from our vertex shader. May vary.
struct VertexShaderOutput
{
	float4 	Position 		: SV_POSITION0;
	float 	Color 			: COLOR1;
	float2 	TexCoord 		: TEXCOORD0;
	float4 	Normal 			: TEXCOORD1;
	float4 	Tangent 		: TEXCOORD2;
	float3 	BiNormal 		: TEXCOORD3;
	float3 	OffPosition 	: OFFPOSITION0;
};

// Samplers
SamplerState textureSampler : register(s0);
SamplerState clampSampler   : register(s1);

// Textures
Texture2D<float4> sceneTexture  : register(t0);
Texture2D<float4> distortionMap : register(t1);
Texture2D<float4> blendMap      : register(t2); // vignette (RGB + A)

// Parameters
float zAmount;
float cAmount;
float dAmount;

// Pixel shader entry
float4 ps_main(in const VertexShaderOutput input) : SV_TARGET
{
	// Distortion sample
	float2 dVal = (distortionMap.Sample(textureSampler, input.TexCoord).xy * 2.0 - 1.0) * dAmount;

	// Screen UV for sampling the scene
	float2 uv = (input.Position.xy / renderTargetSize.xy) * 2 - 1;
	uv *= zAmount;
	uv += dVal;
	uv = uv * 0.5 + 0.5;

	// Scene sample + chromatic aberration
	float4 col;
	col.r = sceneTexture.Sample(textureSampler, float2(uv.x + dVal.x * cAmount, uv.y)).r;
	col.g = sceneTexture.Sample(textureSampler, uv.xy).g;
	col.b = sceneTexture.Sample(textureSampler, float2(uv.x - dVal.y * cAmount, uv.y)).b;
	col.a = 1;

	// --------------------------------------------------------------
	// Vignette: mesh-UV + screen-space combined
	// --------------------------------------------------------------

	// (A) Mesh UV vignette (always present, stuck to scope lens edges)
	float4 vigMesh = blendMap.Sample(textureSampler, input.TexCoord);

	// (B) Screen-space vignette (aspect-correct, no wrap)
	float2 uv01 = input.Position.xy / renderTargetSize.xy;
	float2 p = uv01 - 0.5;
	p.x *= (renderTargetSize.x / renderTargetSize.y);
	float2 vUv = p + 0.5;

	float4 vigScreen = blendMap.Sample(clampSampler, vUv);

	// If either alpha is inverted, flip here (individually):
	// vigMesh.a   = 1.0 - vigMesh.a;
	// vigScreen.a = 1.0 - vigScreen.a;

	// Combine alphas as a "union" so either contributes without double-darkening too harshly
	float aMesh   = saturate(vigMesh.a);
	float aScreen = saturate(vigScreen.a);
	float a = 1.0 - (1.0 - aMesh) * (1.0 - aScreen);

	// Combine vignette RGB tint weighted by each alpha
	float3 rgb = (vigMesh.rgb   * aMesh + vigScreen.rgb * aScreen) / max(aMesh + aScreen, 1e-5);

	// Hardcode strengths (no extra params)
	const float darkenStrength  = 1.0; // 0..1
	const float overlayStrength = 1.0; // 0..1

	float aDark = saturate(a * darkenStrength);
	float aOver = saturate(a * overlayStrength);

	// 1) Darken towards black
	col.rgb *= (1.0 - aDark);

	// 2) Solid overlay of the vignette color
	col.rgb = lerp(col.rgb, rgb, aOver);

	return col;
}