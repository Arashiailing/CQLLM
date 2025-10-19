/**
 * @name Model Editor Framework Mode API Endpoints
 * @description Discovers and lists all accessible API endpoints (methods/attributes) available to library consumers, 
 *              filtering out test code and auto-generated implementations. This query helps developers understand
 *              the public API surface of the Model Editor framework in framework mode.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint apiEndpoint
select 
  // Core API endpoint reference - the primary object representing the endpoint
  apiEndpoint,
  // Namespace context for the endpoint - helps identify the module/package the endpoint belongs to
  apiEndpoint.getNamespace(),
  // Parent class containing the endpoint - provides class hierarchy context
  apiEndpoint.getClass(),
  // Function/method name identifier - the actual name of the endpoint as exposed to consumers
  apiEndpoint.getFunctionName(),
  // Parameter signature list - defines the input parameters the endpoint accepts
  apiEndpoint.getParameters(),
  // Supported HTTP status codes - indicates the possible response status codes
  apiEndpoint.getSupportedStatus(),
  // Source file location - helps with code navigation and debugging
  apiEndpoint.getFileName(),
  // Supported data types - specifies the data types the endpoint can work with
  apiEndpoint.getSupportedType(),
  // Endpoint classification type - categorizes the endpoint (e.g., method, attribute, etc.)
  apiEndpoint.getKind()