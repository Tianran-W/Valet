import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/workspace/application/image_service.dart';
import 'package:valet/startup/startup.dart';

/// 图片预览画廊组件
class ImagePreviewGallery extends StatefulWidget {
  final List<RecordImage> images;
  final int initialIndex;
  final bool readOnly;
  final Function(RecordImage)? onDeleteImage;

  const ImagePreviewGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.readOnly = false,
    this.onDeleteImage,
  });

  @override
  State<ImagePreviewGallery> createState() => _ImagePreviewGalleryState();
}

class _ImagePreviewGalleryState extends State<ImagePreviewGallery> {
  late PageController _pageController;
  late int _currentIndex;
  late ImageService _imageService;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _imageService = getIt<ImageService>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('图片预览 ${_currentIndex + 1}/${widget.images.length}'),
        actions: [
          // 删除按钮
          if (!widget.readOnly && widget.onDeleteImage != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteConfirm(),
            ),
          // 更多操作
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'info':
                  _showImageInfo();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('查看信息'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: widget.images.isEmpty
          ? const Center(
              child: Text(
                '暂无图片',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : PhotoViewGallery.builder(
              itemCount: widget.images.length,
              builder: (context, index) {
                final image = widget.images[index];
                return PhotoViewGalleryPageOptions(
                  imageProvider: _buildImageProvider(image),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: 'image_${image.imageId}',
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 64,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '图片加载失败',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
      bottomNavigationBar: widget.images.length > 1
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  /// 构建图片提供者，支持本地文件和网络图片
  ImageProvider _buildImageProvider(RecordImage image) {
    final imageUrl = _imageService.getImageUrl(image.imageId);
    
    if (imageUrl.startsWith('file://')) {
      final localPath = imageUrl.substring(7); // 移除 'file://' 前缀
      return FileImage(File(localPath));
    } else {
      return CachedNetworkImageProvider(imageUrl);
    }
  }

  /// 显示删除确认对话框
  void _showDeleteConfirm() {
    final image = widget.images[_currentIndex];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图片'),
        content: const Text('确认要删除这张图片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDeleteImage?.call(image);
              
              // 如果删除后没有图片了，关闭预览
              if (widget.images.length <= 1) {
                Navigator.of(context).pop();
              } else {
                // 调整当前索引
                if (_currentIndex >= widget.images.length - 1) {
                  setState(() {
                    _currentIndex = widget.images.length - 2;
                  });
                  _pageController.animateToPage(
                    _currentIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示图片信息
  void _showImageInfo() {
    final image = widget.images[_currentIndex];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('图片信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('图片ID', image.imageId.toString()),
            _buildInfoRow('记录类型', image.recordType.label),
            _buildInfoRow('记录ID', image.recordId.toString()),
            _buildInfoRow('上传时间', _formatDateTime(image.uploadTime)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
