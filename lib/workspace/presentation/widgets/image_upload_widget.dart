import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/workspace/application/image_service.dart';
import 'package:valet/workspace/application/permission_helper.dart';
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

    // 检查相册权限
    final hasPermission = await PermissionHelper.requestStoragePermission(context);
    if (!hasPermission) {
      return;
    }

    try {
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

  /// 拍照并上传图片
  Future<void> _takeAndUploadPhoto() async {
    if (_images.length >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能上传${widget.maxImages}张图片')),
      );
      return;
    }

    // 检查相机权限
    final hasPermission = await PermissionHelper.requestCameraPermission(context);
    if (!hasPermission) {
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
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
            content: Text('拍照失败: $e'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('图片上传成功'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('图片上传失败: $e'),
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
            const SnackBar(
              content: Text('图片删除成功'),
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('图片预览'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: CachedNetworkImage(
                imageUrl: _imageService.getImageUrl(image.imageId),
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, size: 64),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  IconButton(
                    onPressed: _isLoading ? null : _takeAndUploadPhoto,
                    icon: const Icon(Icons.camera_alt),
                    tooltip: '拍照',
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : _pickAndUploadImage,
                    icon: const Icon(Icons.photo_library),
                    tooltip: '从相册选择',
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
            child: const Center(
              child: Text(
                '暂无图片',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          GridView.builder(
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
              child: CachedNetworkImage(
                imageUrl: _imageService.getImageUrl(image.imageId),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 32),
                ),
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
