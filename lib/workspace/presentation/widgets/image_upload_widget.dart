import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/workspace/application/image_service.dart';
import 'package:valet/workspace/application/permission_helper.dart';
import 'package:valet/workspace/application/platform_helper.dart';
import 'package:valet/workspace/presentation/widgets/image_preview_gallery.dart';
import 'package:valet/startup/startup.dart';

/// 图片上传组件
class ImageUploadWidget extends StatefulWidget {
  final RecordType recordType;
  final int recordId;
  final Function(List<RecordImage>)? onImagesChanged;
  final bool readOnly;
  final int maxImages;

  const ImageUploadWidget({
    super.key,
    required this.recordType,
    required this.recordId,
    this.onImagesChanged,
    this.readOnly = false,
    this.maxImages = 5,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  late ImageService _imageService;
  
  List<RecordImage> _images = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _imageService = getIt<ImageService>();
    _loadImages();
  }

  /// 加载图片列表
  Future<void> _loadImages() async {
    // 如果是临时记录ID（时间戳），跳过加载
    if (widget.recordId > 1000000000000) {
      setState(() => _isLoading = false);
      return;
    }
    
    if (widget.recordId <= 0) return; // 新记录暂时不加载图片
    
    setState(() => _isLoading = true);
    
    try {
      final images = await _imageService.getRecordImages(
        recordType: widget.recordType,
        recordId: widget.recordId,
      );
      
      setState(() {
        _images = images;
        _isLoading = false;
      });
      
      widget.onImagesChanged?.call(_images);
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载图片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 选择并上传图片
  Future<void> _pickAndUploadImage() async {
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能上传${widget.maxImages}张图片')),
      );
      return;
    }

    try {
      // 检查相册权限（移动端）
      if (PlatformHelper.isMobile) {
        final hasPermission = await PermissionHelper.requestStoragePermission(context);
        if (!hasPermission) {
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 拍照并上传图片（支持桌面端摄像头）
  Future<void> _takeAndUploadPhoto() async {
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能上传${widget.maxImages}张图片')),
      );
      return;
    }

    try {
      if (PlatformHelper.isMobile) {
        // 移动端检查相机权限
        final hasPermission = await PermissionHelper.requestCameraPermission(context);
        if (!hasPermission) {
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        await _uploadImage(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(PlatformHelper.isDesktop ? '摄像头拍照失败: $e' : '拍照失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 上传图片
  Future<void> _uploadImage(String filePath) async {
    setState(() => _isLoading = true);

    try {
      // 显示上传中的提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('正在上传图片...'),
              ],
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      }

      final response = await _imageService.uploadImage(
        filePath: filePath,
        recordType: widget.recordType,
        recordId: widget.recordId,
      );

      // 创建新的RecordImage对象
      final newImage = RecordImage(
        imageId: response.imageId,
        recordType: widget.recordType,
        recordId: widget.recordId,
        imagePath: response.imagePath,
        uploadTime: DateTime.now(),
      );

      setState(() {
        _images.add(newImage);
        _isLoading = false;
      });

      widget.onImagesChanged?.call(_images);

      if (mounted) {
        // 隐藏上传中的提示
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // 显示成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('图片上传成功 (${_images.length}/${widget.maxImages})'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        // 隐藏上传中的提示
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('图片上传失败: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 删除图片
  Future<void> _deleteImage(RecordImage image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除图片'),
        content: const Text('确认要删除这张图片吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      try {
        await _imageService.deleteImage(image.imageId);
        
        setState(() {
          _images.remove(image);
          _isLoading = false;
        });
        
        widget.onImagesChanged?.call(_images);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('图片删除成功 (${_images.length}/${widget.maxImages})'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('图片删除失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 预览图片
  void _previewImage(RecordImage image) {
    final currentIndex = _images.indexOf(image);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImagePreviewGallery(
          images: _images,
          initialIndex: currentIndex >= 0 ? currentIndex : 0,
          readOnly: widget.readOnly,
          onDeleteImage: widget.readOnly ? null : (imageToDelete) {
            _deleteImageFromPreview(imageToDelete);
          },
        ),
      ),
    );
  }

  /// 从预览中删除图片
  Future<void> _deleteImageFromPreview(RecordImage image) async {
    try {
      await _imageService.deleteImage(image.imageId);
      
      setState(() {
        _images.remove(image);
      });
      
      widget.onImagesChanged?.call(_images);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('图片删除成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('图片删除失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 构建图片组件，支持本地文件和网络图片
  Widget _buildImageWidget(RecordImage image) {
    final imageUrl = _imageService.getImageUrl(image.imageId);
    
    // 检查是否为本地文件路径
    if (imageUrl.startsWith('file://')) {
      final localPath = imageUrl.substring(7); // 移除 'file://' 前缀
      return Image.file(
        File(localPath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 24, color: Colors.grey),
              SizedBox(height: 4),
              Text(
                '加载失败',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else {
      // 网络图片
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade100,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 24, color: Colors.grey),
              SizedBox(height: 4),
              Text(
                '加载失败',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和上传按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '相关图片 (${_images.length}/${widget.maxImages})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!widget.readOnly && _images.length < widget.maxImages)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 桌面端不显示拍照按钮，移动端显示拍照按钮
                  if (PlatformHelper.isMobile)
                    IconButton(
                      onPressed: _isLoading ? null : _takeAndUploadPhoto,
                      icon: const Icon(Icons.camera_alt),
                      tooltip: '拍照',
                    ),
                  IconButton(
                    onPressed: _isLoading ? null : _pickAndUploadImage,
                    icon: PlatformHelper.isDesktop 
                        ? const Icon(Icons.upload_file) 
                        : const Icon(Icons.photo_library),
                    tooltip: PlatformHelper.isDesktop ? '上传文件' : '从相册选择',
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 图片网格
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_images.isEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.readOnly 
                        ? Icons.image_not_supported_outlined
                        : (PlatformHelper.isDesktop ? Icons.cloud_upload : Icons.add_photo_alternate),
                    size: 32,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.readOnly 
                        ? '暂无相关图片'
                        : (PlatformHelper.isDesktop 
                            ? '点击上方按钮选择文件上传' 
                            : '点击上方按钮拍照或选择图片'),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: (_images.length / 3).ceil() * 130.0, // 动态计算高度
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final image = _images[index];
                return _buildImageTile(image);
              },
            ),
          ),
      ],
    );
  }

  /// 构建图片瓦片
  Widget _buildImageTile(RecordImage image) {
    return GestureDetector(
      onTap: () => _previewImage(image),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            // 图片
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Hero(
                tag: 'image_${image.imageId}',
                child: _buildImageWidget(image),
              ),
            ),
            
            // 删除按钮
            if (!widget.readOnly)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _deleteImage(image),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
