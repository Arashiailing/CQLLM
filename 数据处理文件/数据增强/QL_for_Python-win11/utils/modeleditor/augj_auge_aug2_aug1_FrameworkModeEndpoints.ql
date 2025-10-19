/**
 * @name Model Editor Framework Mode API Endpoints
 * @description Identifies and catalogs all publicly accessible API endpoints (methods/attributes) within the Model Editor framework.
 *              This query excludes test code and auto-generated implementations to provide a clean view of the framework's public API surface.
 *              It serves as a reference for developers integrating with the Model Editor framework in framework mode.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint frameworkEndpoint
select 
  // Core API endpoint reference - the fundamental object representing the endpoint
  frameworkEndpoint,
  // Namespace context - identifies the module/package containing the endpoint
  frameworkEndpoint.getNamespace(),
  // Parent class - provides class hierarchy and inheritance context
  frameworkEndpoint.getClass(),
  // Function/method name - the identifier exposed to framework consumers
  frameworkEndpoint.getFunctionName(),
  // Parameter signature - defines the input contract for the endpoint
  frameworkEndpoint.getParameters(),
  // Supported HTTP status codes - indicates possible response status codes
  frameworkEndpoint.getSupportedStatus(),
  // Source file location - aids in code navigation and debugging
  frameworkEndpoint.getFileName(),
  // Supported data types - specifies the data types the endpoint can process
  frameworkEndpoint.getSupportedType(),
  // Endpoint classification - categorizes the endpoint (method, attribute, etc.)
  frameworkEndpoint.getKind()