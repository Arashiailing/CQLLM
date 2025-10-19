/**
 * @name Model Editor Framework Mode API Endpoints
 * @description Identifies accessible API endpoints (methods/attributes) for library consumers, excluding test and generated code
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint endpoint
select 
  // Core API endpoint reference
  endpoint,
  // Namespace context for the endpoint
  endpoint.getNamespace(),
  // Parent class containing the endpoint
  endpoint.getClass(),
  // Function/method name identifier
  endpoint.getFunctionName(),
  // Parameter signature list
  endpoint.getParameters(),
  // Supported HTTP status codes
  endpoint.getSupportedStatus(),
  // Source file location
  endpoint.getFileName(),
  // Supported data types
  endpoint.getSupportedType(),
  // Endpoint classification type
  endpoint.getKind()