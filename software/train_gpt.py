import numpy as np
import torch
from torch import nn
from torch.utils.data import Dataset, DataLoader

# ===========================
# 1. 自定义 Dataset
# ===========================
class MNIST16Dataset(Dataset):
    def __init__(self, images_path, labels_path):
        self.images = np.load(images_path)           # uint8 (N,16,16)
        self.labels = np.load(labels_path)           # uint8 (N,)
        self.images = self.images.astype(np.float32) / 255.0   # 归一化到 0~1

    def __len__(self):
        return len(self.images)

    def __getitem__(self, idx):
        img = self.images[idx]
        img = torch.tensor(img).reshape(-1)   # 展平为 256 维
        label = torch.tensor(self.labels[idx], dtype=torch.long)
        return img, label


# ===========================
# 2. 加载训练集/测试集
# ===========================
train_dataset = MNIST16Dataset("mnist16_train_images.npy", "mnist16_train_labels.npy")
test_dataset  = MNIST16Dataset("mnist16_test_images.npy",  "mnist16_test_labels.npy")

train_loader = DataLoader(train_dataset, batch_size=128, shuffle=True)
test_loader  = DataLoader(test_dataset,  batch_size=256, shuffle=False)


# ===========================
# 3. 定义 MLP 模型
# ===========================
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

model = MLP()

# 使用 GPU（如果可用）
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)


# ===========================
# 4. 定义优化器和损失函数
# ===========================
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)


# ===========================
# 5. 训练
# ===========================
epochs = 30
for epoch in range(epochs):
    model.train()
    total_loss = 0

    for imgs, labels in train_loader:
        imgs = imgs.to(device)
        labels = labels.to(device)

        optimizer.zero_grad()
        outputs = model(imgs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        total_loss += loss.item()

    print(f"Epoch {epoch+1}/{epochs} - Loss: {total_loss:.4f}")


# ===========================
# 6. 测试准确率
# ===========================
model.eval()
correct = 0
total = 0

with torch.no_grad():
    for imgs, labels in test_loader:
        imgs = imgs.to(device)
        labels = labels.to(device)

        outputs = model(imgs)
        _, predicted = torch.max(outputs, 1)

        total += labels.size(0)
        correct += (predicted == labels).sum().item()

acc = correct / total

torch.save(model.state_dict(), "mlp_fp32.pth")
print("测试集准确率: {:.2f}%".format(acc * 100))
