# Overview

## Cura Setup - Ender 3

1. Non Ultimaker Printer
1. Add a non-networked printer
1. Scroll down and expand `Creality3D`
1. Select `Creality Ender-3 / Ender-3 v2`
1. You shouldn't need to change `Printer` or `Extruder` settings. Ensure `X` and `Y` are both set to 235. Some websites say the "build volume" of the Ender 3 is 220mm, but this is the build volume *after accounting for the bed clips*. You actually need to set the build volume to 235mm by 235mm in order to have Cura slice prints in the center of the build plate.

## Custom Settings

- Y offset of -5 (mm)

## Upgrades

- All Metal Extruder Feeder [here](https://www.amazon.com/gp/product/B081DN6RM2/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
- Capricorn Bowden Tubing
- New Bowden Tubing Pneumatic Couplers
- Yellow Bed-Level Springs for Creality Ender 3
- MK8 Stainless Steel Nozzle (0.4mm) [here](https://www.amazon.com/gp/product/B07XB746Q5/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&th=1)
- Micro-Swiss All Metal Hotend Kit for Creality Ender 3 [here](https://www.amazon.com/gp/product/B0789V2D7C/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
- BIGTREETECH SKR Mini E3 V2.0 Motherboard [here](https://www.amazon.com/gp/product/B081JLJV87/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1)
- TFT35 E3 V3 Touch Screen Onboard TMC2209 Upgraded 32bit Silent Main Board

## Leveling Square

I've created a leveling square comprised of a single layer of filament. The layer is not actually thick enough for Cura to create GCODE to print the layer, so the solution I've come up with is adding a Brim to the object in Cura. By doing this, I can customize the number of layers to allow for as much leveling as I would like.

The leveling square STL file is [here](../file/Leveling%20Square%20v1.3mf)

In Cura, make sure to center and print with a Brim. The more layers of brim, the more leveling that can be done. I like to go with 8 layers.

Size down the leveling square so that the path of the brim is not extruded in line with the clips on the bed. If the object is not scaled down in Cura, the nozzle will run into the clips.
