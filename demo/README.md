# Demo

## slerp_cube

这个展示了Slerp插值中3D空间以及4D空间中的2D插值平面的一个对比，在这个Demo中，3D空间中的是一个立方体。

在MATLAB绘制的动画中，左图代表的是3D空间中的向量，右图是将4D空间中的四元数投影到了2D平面。


## slerp_vec

与slerp_cube类似，但是在这个Demo中，3D空间中的是一个向量。这个向量正交于Δq的旋转轴（主要是懒得投影），所以向量之间的夹角等于旋转的角度。

在MATLAB绘制的动画中，左图是将3D向量投影到了初始向量和最终向量所在的2D平面中，右图是将4D空间中的四元数投影到了2D平面。

## squad_vs_bezier

向量的Squad（Quad）与三次Bézier曲线之间的一个对比。

左图是Squad（Quad）曲线，右图是三次Bézier曲线。