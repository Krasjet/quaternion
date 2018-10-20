# Demo

所有的Demo动画和MATLAB/Octave代码都在文件夹里，点进去才能看到。其中，有`_octave`后缀的代码文件只能够在Octave中运行。没有`_octave`后缀的代码文件只能够在MATLAB中运行。

由于Octave绘图的性能很差，可能会非常卡，所以我仍推荐使用MATLAB来运行，Octave仅作为备用方案使用。

## slerp_cube

Slerp插值中3D空间以及4D空间中的2D插值平面的一个对比。在这个Demo中，3D空间中的是一个立方体。

在MATLAB绘制的动画中，左图代表的是3D空间中的向量，右图是将4D空间中的四元数投影到了2D平面。

## slerp_vec

与slerp_cube类似，但是在这个Demo中，3D空间中的是一个向量。这个向量正交于Δq的旋转轴（主要是懒得投影），所以向量之间的夹角等于旋转的角度。也就是说，它展示的是向量旋转时旋转平面上的情况。

在MATLAB绘制的动画中，左图是将3D向量投影到了初始向量和最终向量所在的2D平面中（也就是旋转平面），右图是将4D空间中的四元数投影到了2D平面。

## squad_vs_bezier

向量的Squad（或者说Quad）与三次Bézier曲线之间的一个对比。

在MATLAB的动画中，左图是Squad（Quad）曲线，右图是三次Bézier曲线。