// Openapi Generator last run: : 2025-05-31T16:24:31.325836
import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties: DioProperties(
    pubName: 'resource_api',
    pubAuthor: 'terra',
    nullableFields: true,
  ),
  inputSpec: InputSpec(path: 'Butler.openapi.json'),
  generatorName: Generator.dio,
  outputDirectory: 'lib/api/generated',
  runSourceGenOnOutput: true,
  skipIfSpecIsUnchanged: false,
)
class ApiGeneration {}