import 'package:valet/service/api/api_service.dart';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/service/logger_service.dart';

/// 图片管理服务类
class ImageService {
  final ApiService _apiService;
  static const String _tag = 'ImageService';
  
  // 用于存储临时上传的图片（记录ID为时间戳的情况）
  static final Map<int, List<RecordImage>> _tempImages = {};

  /// 构造函数
  ImageService(this._apiService);

  /// 上传图片
  /// [filePath]: 图片文件路径
  /// [recordType]: 记录类型
  /// [recordId]: 记录ID
  Future<ImageUploadResponse> uploadImage({
    required String filePath,
    required RecordType recordType,
    required int recordId,
  }) async {
    try {
      logger.info('正在上传图片: $filePath, recordType: ${recordType.value}, recordId: $recordId', tag: _tag);
      
      // 检查是否为临时记录ID（时间戳格式，通常很大）
      if (_isTempRecordId(recordId)) {
        // 对于临时记录，我们模拟上传并存储在内存中
        final imageId = DateTime.now().millisecondsSinceEpoch; // 生成临时图片ID
        final response = ImageUploadResponse(
          imageId: imageId,
          imagePath: filePath, // 临时使用本地路径
        );
        
        // 创建临时图片记录
        final tempImage = RecordImage(
          imageId: imageId,
          recordType: recordType,
          recordId: recordId,
          imagePath: filePath,
          uploadTime: DateTime.now(),
        );
        
        // 存储到临时缓存
        _tempImages.putIfAbsent(recordId, () => []).add(tempImage);
        
        logger.debug('临时存储图片: $imageId', tag: _tag);
        return response;
      }
      
      // 正常的API上传
      final result = await _apiService.workspaceApi.uploadImage(
        filePath: filePath,
        recordType: recordType,
        recordId: recordId,
      );
      
      logger.debug('成功上传图片: ${result.imageId}', tag: _tag);
      return result;
    } catch (e) {
      logger.error('上传图片失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('上传图片失败: $e');
    }
  }

  /// 获取记录关联的图片列表
  /// [recordType]: 记录类型
  /// [recordId]: 记录ID
  Future<List<RecordImage>> getRecordImages({
    required RecordType recordType,
    required int recordId,
  }) async {
    try {
      logger.info('正在获取记录图片: recordType: ${recordType.value}, recordId: $recordId', tag: _tag);
      
      // 检查是否为临时记录ID
      if (_isTempRecordId(recordId)) {
        final tempImages = _tempImages[recordId] ?? [];
        logger.debug('获取临时记录图片, 共${tempImages.length}张', tag: _tag);
        return tempImages;
      }
      
      final result = await _apiService.workspaceApi.getRecordImages(
        recordType: recordType,
        recordId: recordId,
      );
      
      logger.debug('成功获取记录图片, 共${result.length}张', tag: _tag);
      return result;
    } catch (e) {
      logger.error('获取记录图片失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('获取记录图片失败: $e');
    }
  }

  /// 删除图片
  /// [imageId]: 图片ID
  Future<void> deleteImage(int imageId) async {
    try {
      logger.info('正在删除图片: $imageId', tag: _tag);
      
      // 检查是否为临时图片（在临时缓存中）
      bool isTemp = false;
      for (final entry in _tempImages.entries) {
        final images = entry.value;
        final imageIndex = images.indexWhere((img) => img.imageId == imageId);
        if (imageIndex >= 0) {
          images.removeAt(imageIndex);
          isTemp = true;
          break;
        }
      }
      
      if (isTemp) {
        logger.debug('成功删除临时图片: $imageId', tag: _tag);
        return;
      }
      
      await _apiService.workspaceApi.deleteImage(imageId);
      
      logger.debug('成功删除图片: $imageId', tag: _tag);
    } catch (e) {
      logger.error('删除图片失败', tag: _tag, error: e, stackTrace: StackTrace.current);
      throw Exception('删除图片失败: $e');
    }
  }

  /// 获取图片URL
  /// [imageId]: 图片ID
  String getImageUrl(int imageId) {
    // 检查是否为临时图片
    for (final images in _tempImages.values) {
      for (final image in images) {
        if (image.imageId == imageId) {
          return 'file://${image.imagePath}'; // 返回本地文件路径
        }
      }
    }
    
    return _apiService.workspaceApi.getImageUrl(imageId);
  }
  
  /// 检查是否为临时记录ID（时间戳格式）
  bool _isTempRecordId(int recordId) {
    // 时间戳通常是13位数字，大于1000000000000
    return recordId > 1000000000000;
  }
  
  /// 获取临时记录的图片列表
  List<RecordImage> getTempImages(int tempRecordId) {
    return _tempImages[tempRecordId] ?? [];
  }
  
  /// 清理临时记录的图片
  void clearTempImages(int tempRecordId) {
    _tempImages.remove(tempRecordId);
  }
}
