import numpy as np

def load_quantization_params(quant_file):
    """加载量化参数（仅保留merge_coefficients）"""
    quant_data = np.load(quant_file)
    params = {
        # 仅保留merge_coefficients这一种scale
        "merge_coefficients": quant_data["merge_coefficients"],
        # 重新组装权重和偏置部分代码不变
        "quantized_weights": [
            quant_data["quantized_weight_0"],
            quant_data["quantized_weight_1"],
            quant_data["quantized_weight_2"]
        ],
        "quantized_biases": [
            quant_data["quantized_bias_0"],
            quant_data["quantized_bias_1"],
            quant_data["quantized_bias_2"]
        ],
        "quantized_input": quant_data["quantized_input"]
    }
    return params

def mlp_int8_inference(input_int8, quant_params):
    """
    INT8量化推理核心逻辑（修改版）
    :param input_int8: 量化后的输入 (N, 256) INT8
    :param quant_params: 量化参数字典
    :return: 最后一层输出的INT8值 (N, 10)
    """
    # 提取量化参数
    merge_coefficients = quant_params["merge_coefficients"]
    quant_weights = quant_params["quantized_weights"]
    quant_biases = quant_params["quantized_biases"]
    
    # 当前层输入（INT8）
    current_input = input_int8
    
    # 遍历3层Linear + ReLU（最后一层无ReLU）
    for layer_idx in range(3):
        # 1. 获取当前层参数
        w_int8 = quant_weights[layer_idx]  # (out_dim, in_dim) INT8
        b_int32 = quant_biases[layer_idx]  # (out_dim,) INT32
        merge_coeff = merge_coefficients[layer_idx]
        
        # 2. INT8输入 × INT8权重 → INT32累加
        # current_input: (N, in_dim) INT8 → 转INT32
        # w_int8: (out_dim, in_dim) INT8 → 转INT32
        # 矩阵乘法: (N, in_dim) × (in_dim, out_dim) = (N, out_dim)
        matmul_result = np.dot(current_input.astype(np.int32), w_int8.T.astype(np.int32))
        
        # 3. 加上INT32偏置
        add_result = matmul_result + b_int32[np.newaxis, :]  # (N, out_dim) INT32
        
        # 4. 与merge_coefficients相乘后转为INT8
        merged_result = add_result * merge_coeff
        layer_output_int8 = merged_result.astype(np.int8)
        
        # 5. 最后一层直接返回
        if layer_idx == 2:
            return layer_output_int8
        
        # 6. ReLU激活（INT8版本：负数置0）
        next_input_int8 = np.maximum(layer_output_int8, 0)
        
        # 更新当前输入为下一层输入
        current_input = next_input_int8
    
    return None

def main():
    # 直接进行推理（假设输入数据已处理为INT8格式）
    print("开始INT8推理...")
    
    # 
    test_labels = np.load("mnist16_test_labels.npy")  # (N,)
    # test_labels = test_labels[:16]
    
    # 加载量化参数
    print("加载量化参数...")
    quant_params = load_quantization_params("mlp_int8_quantized.npz")
    input_int8 = quant_params["quantized_input"]
    
    # 批量推理（避免内存溢出）
    batch_size = 16
    num_samples = len(input_int8)
    # num_samples = 16
    predictions = []
    
    for start in range(0, num_samples, batch_size):
        end = min(start + batch_size, num_samples)
        batch_input = input_int8[start:end]
        batch_output = mlp_int8_inference(batch_input, quant_params)
        #print(batch_output)
        batch_pred = np.argmax(batch_output, axis=1)
        predictions.extend(batch_pred)
    
    predictions = np.array(predictions)
    
    # 计算准确率
    accuracy = np.mean(predictions == test_labels) * 100
    print(f"\n推理完成！")
    print(f"测试集样本数: {num_samples}")
    print(f"INT8量化推理准确率: {accuracy:.2f}%")
    
    # # 可选：打印部分结果对比
    # print("\n前10个样本预测结果:")
    # for i in range(10):
    #     print(f"样本{i}: 真实标签={test_labels[i]}, 预测标签={predictions[i]}")

if __name__ == "__main__":
    main()
