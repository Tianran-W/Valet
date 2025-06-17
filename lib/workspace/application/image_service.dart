import 'package:valet/service/api/api_service.dart';
import 'package:valet/workspace/models/image_model.dart';
import 'package:valet/service/logger_service.dart';

/// 图片管理服务类
class ImageService {
  final ApiService _apiService;
  static const String _tag = 'ImageService';

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
      
      // 调用API上传
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
    required int materialId,
  }) async {
    try {
      logger.info('正在获取记录图片: recordType: ${recordType.value}, recordId: $materialId', tag: _tag);
      
      final result = await _apiService.workspaceApi.getRecordImages(
        recordType: recordType,
        materialId: materialId,
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
    return _apiService.workspaceApi.getImageUrl(imageId);
  }
}
