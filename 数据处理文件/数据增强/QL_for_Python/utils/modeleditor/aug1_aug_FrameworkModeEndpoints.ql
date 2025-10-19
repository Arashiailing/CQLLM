/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Catalogs all accessible endpoints (methods and attributes) within the model editor's framework mode.
 *              This query filters out test code and generated artifacts to focus on production endpoints.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor module to access endpoint analysis capabilities
import modeling.ModelEditor

// Extract endpoint information from the ModelEditor framework
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