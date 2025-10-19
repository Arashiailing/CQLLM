/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Identifies accessible endpoints (methods and attributes) available in the model editor's framework mode. 
 *              Excludes test and generated code artifacts from results.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor capabilities for endpoint analysis
import modeling.ModelEditor

// Retrieve endpoint metadata with enhanced variable naming
from Endpoint apiEndpoint
select 
  // Core endpoint reference
  apiEndpoint,
  // Namespace containing the endpoint
  apiEndpoint.getNamespace(),
  // Parent class defining the endpoint
  apiEndpoint.getClass(),
  // Method/function name of the endpoint
  apiEndpoint.getFunctionName(),
  // Parameter signature of the endpoint
  apiEndpoint.getParameters(),
  // Supported HTTP status codes
  apiEndpoint.getSupportedStatus(),
  // Source file containing endpoint definition
  apiEndpoint.getFileName(),
  // Supported data types for the endpoint
  apiEndpoint.getSupportedType(),
  // Endpoint classification (method/attribute)
  apiEndpoint.getKind()