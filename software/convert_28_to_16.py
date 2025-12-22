import numpy as np
from torchvision import datasets
from tqdm import tqdm
from PIL import Image

# 加载原始 MNIST
train_set = datasets.MNIST(root="./mnist_data", train=True, download=True, transform=None)
test_set = datasets.MNIST(root="./mnist_data", train=False, download=True, transform=None)

def convert_dataset(mnist_dataset):
    images_16 = []
    labels_16 = []

    for img, label in tqdm(mnist_dataset):
        # 使用 BILINEAR 进行 28×28 → 16×16 的缩放
        img_16 = img.resize((16, 16), Image.BILINEAR)
        images_16.append(np.array(img_16))  # uint8
        labels_16.append(label)

    images_16 = np.array(images_16, dtype=np.uint8)
    labels_16 = np.array(labels_16, dtype=np.uint8)

    return images_16, labels_16


# 转换训练集
train_images_16, train_labels_16 = convert_dataset(train_set)

# 转换测试集
test_images_16, test_labels_16 = convert_dataset(test_set)

# 保存文件
np.save("mnist16_train_images.npy", train_images_16)
np.save("mnist16_train_labels.npy", train_labels_16)
np.save("mnist16_test_images.npy", test_images_16)
np.save("mnist16_test_labels.npy", test_labels_16)

print("保存完成！")
