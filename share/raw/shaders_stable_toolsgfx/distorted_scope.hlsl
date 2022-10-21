// Per Scene Consts sent by the game, we only need 1 value from it.
cbuffer PerSceneConsts : register(b1)
{
	// The size of the current render target, set in the game options so can change.
	float4 renderTargetSize : packoffset(c44);
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

// Our sampler defined in the techset.
SamplerState textureSampler : register(s0);
// Our scene texture, we hint to game we want this via the techset.
Texture2D<float4> sceneTexture : register(t0);
// Our distortion map defined in the techset.
Texture2D<float4> distortionMap : register(t1);

// Our zoom amount defined in the techset and can be adjusted in APE.
float zAmount;
// Our chromatic aberration defined in the techset and can be adjusted in APE.
float cAmount;
// Our distortion amount defined in the techset and can be adjusted in APE.
float dAmount;

// Our pixel shader entry point.
float4 ps_main(in const VertexShaderOutput input) : SV_TARGET
{
	// Get the value from the distortion map, you can fit this to the shape
	// of your scope, or just use the included sphere distortion map for most scopes.
	float2 dVal = (distortionMap.Sample(textureSampler, input.TexCoord).xy * 2.0 - 1.0) * dAmount;
	// Get the current screen pixel as a UV coordinate based off the viewport size.
	// Convert to -1 to 1 so we can scale outwards from the center.
	float2 uv = (input.Position.xy / renderTargetSize.xy) * 2 - 1;
	// Apply our distortion and zoom value.
	uv *= zAmount;
	uv += dVal;
	// Revert back to 0 to 1.
	uv = uv * 0.5 + 0.5;
	// Set the all thing
	float4 col;
	// Apply some chromatic aberration to the final image to give it that "lense" like appearance.
	col.r = sceneTexture.Sample(textureSampler, float2(uv.x + dVal.x * cAmount, uv.y) ).r;
	col.g = sceneTexture.Sample(textureSampler, uv.xy).g;
	col.b = sceneTexture.Sample(textureSampler, float2(uv.x - dVal.y * cAmount, uv.y) ).b;
	col.a = 1;
	// We are now ready to break like Harry's perks.
	return col;
}