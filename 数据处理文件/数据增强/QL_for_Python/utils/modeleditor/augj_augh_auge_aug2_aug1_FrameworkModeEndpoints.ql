/**
 * @name Model Editor Framework Mode API Endpoints
 * @description Identifies and enumerates all publicly accessible API endpoints (methods/attributes) exposed by the library,
 *              excluding test code and automatically generated implementations. This query provides visibility into
 *              the public API surface area of the Model Editor framework when operating in framework mode.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint apiEndpoint
select 
  // Core endpoint object - primary representation of the API surface
  apiEndpoint,
  // Endpoint identifier - the public-facing name exposed to consumers
  apiEndpoint.getFunctionName(),
  // Endpoint classification - distinguishes between methods, attributes, etc.
  apiEndpoint.getKind(),
  // Namespace context - identifies the module/package hierarchy
  apiEndpoint.getNamespace(),
  // Class container - provides inheritance and structural context
  apiEndpoint.getClass(),
  // Parameter signature - defines accepted input parameters
  apiEndpoint.getParameters(),
  // Supported status codes - indicates possible HTTP response statuses
  apiEndpoint.getSupportedStatus(),
  // Data type support - specifies compatible input/output data types
  apiEndpoint.getSupportedType(),
  // Source location - file path for code navigation and debugging
  apiEndpoint.getFileName()