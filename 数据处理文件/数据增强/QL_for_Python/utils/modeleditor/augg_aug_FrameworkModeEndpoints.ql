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

// Retrieve framework-mode endpoint metadata with enhanced variable naming
from Endpoint frameworkEndpoint
select 
  // Core endpoint reference
  frameworkEndpoint,
  // Namespace containing the endpoint
  frameworkEndpoint.getNamespace(),
  // Parent class defining the endpoint
  frameworkEndpoint.getClass(),
  // Method/function name of the endpoint
  frameworkEndpoint.getFunctionName(),
  // Parameter signature of the endpoint
  frameworkEndpoint.getParameters(),
  // Supported HTTP status codes
  frameworkEndpoint.getSupportedStatus(),
  // Source file containing endpoint definition
  frameworkEndpoint.getFileName(),
  // Supported data types for the endpoint
  frameworkEndpoint.getSupportedType(),
  // Endpoint classification (method/attribute)
  frameworkEndpoint.getKind()