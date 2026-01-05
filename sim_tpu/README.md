# 使用 TPU 仿真 MLP 第一层

`Makefile` 已经写好，在该目录下，`make all` 即可完成仿真并打开 Verdi 查看仿真波形。可能用到的波形文件可以在 Verdi 中加载`signal.rc` 来进行查看。

注意 `Makefile` 中，VCS 接受了一个宏的定义 `+define+LOAD_TXT`，就是用来将寄存器初始化为所需的数据的。如果这个宏不被定义，则在 rst 后所有寄存器正常初始化为 0。

VPU输出信号可以与 `data/layer1_output_before_relu.txt` 中的结果进行比对。