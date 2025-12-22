import numpy as np
import torch
from torch import nn

# 定义与训练时一致的MLP模型
class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(16*16, 64),
            nn.ReLU(),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, 10)
        )

    def forward(self, x):
        return self.net(x)

# 加载模型
device = torch.device("cpu")
model = MLP()
model.load_state_dict(torch.load("mlp_fp32.pth", map_location=device))
model.eval()

# 收集各层权重和偏置
weights = []
biases = []
for layer in model.net:
    if isinstance(layer, nn.Linear):
        weights.append(layer.weight.data.numpy())  # 权重形状: (out_features, in_features)
        biases.append(layer.bias.data.numpy())     # 偏置形状: (out_features,)

# 1. 量化权重并计算权重scale
quantized_weights = []
weight_scales = []
for w in weights:
    max_val = np.max(np.abs(w))
    scale = max_val / 127.0 if max_val != 0 else 1.0
    quantized_w = np.round(w / scale).astype(np.int8)
    quantized_w = np.clip(quantized_w, -127, 127)
    quantized_weights.append(quantized_w)
    weight_scales.append(scale)

# 2. 计算输入数据scale并量化全部输入数据
test_images = np.load("mnist16_test_images.npy").astype(np.float32) / 255.0
# 计算全量输入的最大值用于确定scale
full_input_max = np.max(np.abs(test_images))
input_scale = full_input_max / 127.0 if full_input_max != 0 else 1.0

# 量化全部输入数据（fp32 -> int8）
flattened_full_input = test_images.reshape(-1, 16*16)  # 展平所有输入
quantized_input = np.round(flattened_full_input / input_scale).astype(np.int8)
quantized_input = np.clip(quantized_input, -127, 127)  # 裁剪到int8范围

# 采样部分数据用于后续计算激活scale
sample_indices = np.random.choice(len(test_images), 10000, replace=False)
sample_images = test_images[sample_indices]
flattened_samples = sample_images.reshape(-1, 16*16)

# 3. 计算激活输入的scale（新定义：线性层输出经反量化后的fp32数据）
activation_scales = []  # 现在包含3个元素：3个线性层的输出反量化后尺度
linear_outputs = []     # 存储各线性层的fp32输出（矩阵乘+加偏置）

# 注册线性层的输出钩子，收集矩阵乘+偏置后的fp32结果
def linear_hook_fn(module, input, output):
    linear_outputs.append(output.detach().numpy())  # 直接收集线性层输出（未经过ReLU）

hooks = []
for layer in model.net:
    if isinstance(layer, nn.Linear):
        hook = layer.register_forward_hook(linear_hook_fn)
        hooks.append(hook)

# 前向传播收集线性层输出
sample_tensor = torch.tensor(flattened_samples, dtype=torch.float32)
with torch.no_grad():
    model(sample_tensor)

# 计算每个线性层输出的反量化后尺度（新activation_scales定义）
for linear_out in linear_outputs:
    max_val = np.max(np.abs(linear_out))
    scale = max_val / 127.0 if max_val != 0 else 1.0
    activation_scales.append(scale)

for hook in hooks:
    hook.remove()

# 4. 量化偏置
quantized_biases = []
bias_scales = []
prev_input_scales = [input_scale] + activation_scales[:-1]  # 最后一层输出无需作为下一层输入

for i in range(len(biases)):
    b = biases[i]
    s_b = prev_input_scales[i] * weight_scales[i]
    quantized_b = np.round(b / s_b).astype(np.int32)
    quantized_biases.append(quantized_b)
    bias_scales.append(s_b)

# 5. 计算合并系数（3个，对应3个线性层）
# 合并系数 k = (输入scale * 权重scale) / 激活输出scale（当前线性层输出的scale）
merge_coefficients = []
for i in range(len(weights)):
    input_scale_i = prev_input_scales[i]  # 第i层的输入scale
    activation_scale_i = activation_scales[i]  # 第i层输出的scale（新定义）
    k = (input_scale_i * weight_scales[i]) / activation_scale_i
    merge_coefficients.append(k)

# 6. 保存量化结果（只保存merge_coefficients作为基础scale参数，并明确为fp32类型）
save_dict = {}
# 基础scale参数：只保存merge_coefficients，并明确为float32类型
save_dict["merge_coefficients"] = np.array(merge_coefficients, dtype=np.float32)

# 保存量化后的输入数据
save_dict["quantized_input"] = quantized_input

# 权重和偏置按层保存
for i, w in enumerate(quantized_weights):
    save_dict[f"quantized_weight_{i}"] = w
for i, b in enumerate(quantized_biases):
    save_dict[f"quantized_bias_{i}"] = b

np.savez("mlp_int8_quantized.npz", **save_dict)

# 打印量化信息
print("\n量化完成，各层参数：")
print(f"输入数据 scale: {input_scale:.6f}")
print(f"量化输入数据形状: {quantized_input.shape}")
for i in range(len(weight_scales)):
    print(f"第{i+1}层：")
    print(f"  权重 scale: {weight_scales[i]:.6f}")
    print(f"  偏置 scale: {bias_scales[i]:.6f}")
    print(f"  输出激活 scale: {activation_scales[i]:.6f}")
    print(f"  合并系数: {merge_coefficients[i]:.6f}")
print(f"激活scale数量: {len(activation_scales)}")
print(f"合并系数数量: {len(merge_coefficients)}")
print(f"合并系数数据类型: {np.array(merge_coefficients, dtype=np.float32).dtype}")

# 验证保存结果
print("\n验证保存结果：")
test_load = np.load("mlp_int8_quantized.npz")
print("保存的参数列表：", list(test_load.keys()))

loaded_params = {
    "merge_coefficients": test_load["merge_coefficients"],  # 加载合并系数
    "quantized_input": test_load["quantized_input"],
    "quantized_weights": [test_load[f"quantized_weight_{i}"] for i in range(3)],
    "quantized_biases": [test_load[f"quantized_bias_{i}"] for i in range(3)]
}

print(f"加载的合并系数数量: {len(loaded_params['merge_coefficients'])}")
print(f"加载的合并系数数据类型: {loaded_params['merge_coefficients'].dtype}")
print(f"加载的量化输入数据形状: {loaded_params['quantized_input'].shape}")
