# 🔭 Bo3MWStyleScope 🔭

This repo holds a basic shader for use with Black Ops III weapons that mimics Modern Warfare's zoomed scope shader. The distortion can be controlled by a normal map and some settings.

# Installation

To install download the latest [Release](/releases/latest) and unpack the zip file to Black Ops III's directory. Once done you can move on to usage, it's that simple!

# Usage

Using the scope shader is very simply, it can be a drop in replacement for your scope's `stencil` material that unblurs the lens section of the screen. To do this, set the material you're using for your scope to:

```
Material Catagory: Specialty
Material Type: distorted_scope
```

Once done, you can assign a normal map to handle distortion, if you don't want distortion, leave this blank and set the Distortion Amount to `0`. To control the zoom, simply set the zoom value to what you want. If you decide to use distortion, you'll need to make sure your mesh has suitable UVs and is towards the front of the gun on top of everything else.

For example:

![Example](https://i.imgur.com/C2Y0sM2.png)

Normal Map Example (thanks to Kurururu):

![Normal Map](https://i.imgur.com/CBA9IfU.png)

# Reporting Problems

❤️ You can also join my Discord to report issues or get general help ❤️

[![Join my Discord](https://discordapp.com/api/guilds/719503756810649640/widget.png?style=banner2)](https://discord.gg/RyqyThu)

# Credits

If you use the script there is no requirement to credit me, focus on making your projects extra spicy. 🌶️

# Preview

![Preview](https://i.imgur.com/Yr6ukEg.jpeg)