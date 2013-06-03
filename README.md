Quake2.jl
=========

Quake 2 graphics engine written with [Julia](http://julialang.org/) and modern OpenGL.

![Screenshot](pics/q2dm7.jpg)

Features
--------

* Map (.bsp) rendering
* Per-pixel lighting
* Support for bump and parallax effects from heightmaps

Requirements
------------

* [Julia v0.2](https://github.com/JuliaLang/julia/) (still in development - must be built from source)
* Official Julia packages (can be added with `Pkg.add()`):
  * [GLFW](https://github.com/jayschwa/GLFW.jl)
  * [Images](https://github.com/timholy/Images.jl)
  * [ImmutableArrays](https://github.com/twadleigh/ImmutableArrays.jl)
* Unofficial Julia packages (must be added manually):
  * [GL](https://github.com/jayschwa/GL.jl) (requires at least OpenGL 3.x)
* Quake 2 game data (i.e. pak0.pak)

Due to the fast-moving nature of Julia development and its packages, setting up an environment is not easy. In its current state, the code will likely not run outside the author's environment. Work is being done to fix this and make setup easier.

Lighting
--------

Traditional [Phong shading](https://en.wikipedia.org/wiki/Phong_shading) is applied per-pixel and used in conjunction with point lights parsed from the BSP's entity list. Lightmaps baked into the BSP are not currently being used due to their low resolution and lack of direction information.

Bump and parallax effects can be created by providing an optional height map. Normal maps are calculated automatically from the height map at initialization.

![Height map](pics/height.jpg)

![Normal map](pics/normal.jpg)

![Bump and parallax](pics/bump_parallax.jpg)

The bump and parallax effects breathe new life into the original, low resolution Quake 2 textures.

![Diffuse](pics/diffuse.jpg)

![Combined effect](pics/combined.jpg)
