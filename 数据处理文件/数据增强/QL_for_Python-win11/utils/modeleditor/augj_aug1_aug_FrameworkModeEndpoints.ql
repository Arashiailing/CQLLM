/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Identifies and catalogs all accessible endpoints (methods and attributes) 
 *              within the model editor's framework mode. This analysis excludes test code 
 *              and generated artifacts to focus exclusively on production endpoints.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor module to access endpoint analysis capabilities
import modeling.ModelEditor

// Extract endpoint information from the ModelEditor framework mode
from Endpoint modelEditorEndpoint
select 
  // Core endpoint reference
  modelEditorEndpoint,
  // Namespace containing the endpoint
  modelEditorEndpoint.getNamespace() as endpointNamespace,
  // Parent class defining the endpoint
  modelEditorEndpoint.getClass() as parentClass,
  // Method/function name of the endpoint
  modelEditorEndpoint.getFunctionName() as functionName,
  // Parameter signature of the endpoint
  modelEditorEndpoint.getParameters() as parameterSignature,
  // Supported HTTP status codes
  modelEditorEndpoint.getSupportedStatus() as supportedStatusCodes,
  // Source file containing endpoint definition
  modelEditorEndpoint.getFileName() as sourceFile,
  // Supported data types for the endpoint
  modelEditorEndpoint.getSupportedType() as supportedDataTypes,
  // Endpoint classification (method/attribute)
  modelEditorEndpoint.getKind() as endpointClassification