/**
 * @name Fetch API endpoints for model editor framework mode
 * @description Identifies accessible API endpoints (methods/attributes) for library consumers, excluding test/generated code
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint apiEndpoint
select 
  // Core API endpoint reference
  apiEndpoint,
  // Namespace context of the endpoint
  apiEndpoint.getNamespace(),
  // Parent class containing the endpoint
  apiEndpoint.getClass(),
  // Function/method name identifier
  apiEndpoint.getFunctionName(),
  // Parameter signature list
  apiEndpoint.getParameters(),
  // Supported HTTP status codes
  apiEndpoint.getSupportedStatus(),
  // Source file location
  apiEndpoint.getFileName(),
  // Supported data types
  apiEndpoint.getSupportedType(),
  // Endpoint classification type
  apiEndpoint.getKind()