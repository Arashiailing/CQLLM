/**
 * @name Model Editor Framework Mode API Endpoints
 * @description Identifies publicly accessible API endpoints in the Model Editor framework, 
 *              excluding test artifacts and auto-generated code. Provides comprehensive 
 *              metadata about each endpoint including namespace, class context, and 
 *              operational characteristics.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint apiEndpoint
select 
  // Primary API endpoint reference
  apiEndpoint,
  // Hierarchical namespace containing the endpoint
  apiEndpoint.getNamespace(),
  // Parent class defining the endpoint
  apiEndpoint.getClass(),
  // Method/function identifier
  apiEndpoint.getFunctionName(),
  // Formal parameter specification
  apiEndpoint.getParameters(),
  // Supported HTTP response status codes
  apiEndpoint.getSupportedStatus(),
  // Source file path and location
  apiEndpoint.getFileName(),
  // Accepted data type specifications
  apiEndpoint.getSupportedType(),
  // Endpoint classification category
  apiEndpoint.getKind()