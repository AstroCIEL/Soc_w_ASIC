import numpy as np
import matplotlib.pyplot as plt

# 读取 16×16 MNIST
train_images = np.load("mnist16_train_images.npy")   # shape: (60000, 16, 16)
train_labels = np.load("mnist16_train_labels.npy")   # shape: (60000,)

# 选取某一张图片（你可以修改 index）
index = 50

img = train_images[index]   # 16×16 的 uint8 矩阵
label = train_labels[index]

print("标签（该图片的数字是）：", label)
print("图像 shape:", img.shape)
print("图像 dtype:", img.dtype)

print("16×16 像素矩阵：")
print(img)

# 显示图像
plt.imshow(img, cmap='gray')
plt.title(f"MNIST 16×16 (Label = {label})")
plt.show()
