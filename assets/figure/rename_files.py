#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
批量重命名文件夹中的图片和视频文件
图片格式: figure_x_img_y.webp
视频格式: figure_x_video.mp4
"""

import os
import glob
from pathlib import Path

def rename_files_in_folder(folder_path, folder_number):
    """重命名指定文件夹中的文件"""
    folder_path = Path(folder_path)
    
    if not folder_path.exists() or not folder_path.is_dir():
        print(f"跳过: {folder_path} 不存在或不是文件夹")
        return
    
    # 获取所有 .webp 图片文件
    image_files = sorted(folder_path.glob("*.webp"))
    
    # 获取所有 .mp4 视频文件
    video_files = list(folder_path.glob("*.mp4"))
    
    print(f"\n处理文件夹: {folder_path.name}")
    print(f"  找到 {len(image_files)} 个图片文件")
    print(f"  找到 {len(video_files)} 个视频文件")
    
    # 重命名图片文件
    for idx, img_file in enumerate(image_files, start=1):
        new_name = f"figure_{folder_number}_img_{idx}.webp"
        new_path = folder_path / new_name
        
        if img_file.name != new_name:
            # 检查目标文件是否已存在
            if new_path.exists() and new_path != img_file:
                print(f"  警告: {new_name} 已存在，跳过重命名 {img_file.name}")
            else:
                img_file.rename(new_path)
                print(f"  ✓ {img_file.name} -> {new_name}")
        else:
            print(f"  - {img_file.name} 已经是正确名称")
    
    # 重命名视频文件
    if len(video_files) > 0:
        video_file = video_files[0]  # 通常只有一个视频文件
        new_name = f"figure_{folder_number}_video.mp4"
        new_path = folder_path / new_name
        
        if video_file.name != new_name:
            if new_path.exists() and new_path != video_file:
                print(f"  警告: {new_name} 已存在，跳过重命名 {video_file.name}")
            else:
                video_file.rename(new_path)
                print(f"  ✓ {video_file.name} -> {new_name}")
        else:
            print(f"  - {video_file.name} 已经是正确名称")
    else:
        print(f"  警告: 未找到视频文件")

def main():
    """主函数"""
    base_dir = Path(__file__).parent
    
    print("开始批量重命名文件...")
    print(f"工作目录: {base_dir}")
    
    # 获取所有数字文件夹
    folders = sorted([d for d in base_dir.iterdir() 
                     if d.is_dir() and d.name.isdigit()], 
                    key=lambda x: int(x.name))
    
    print(f"\n找到 {len(folders)} 个文件夹")
    
    for folder in folders:
        folder_number = folder.name
        rename_files_in_folder(folder, folder_number)
    
    print("\n" + "="*50)
    print("批量重命名完成！")

if __name__ == "__main__":
    main()

