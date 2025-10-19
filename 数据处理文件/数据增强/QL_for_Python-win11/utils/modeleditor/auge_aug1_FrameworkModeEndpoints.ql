/**
 * @name Fetch API endpoints for model editor framework mode
 * @description Identifies accessible API endpoints (methods/attributes) for library consumers, excluding test/generated code
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint frameworkEndpoint
select 
  // Primary endpoint reference
  frameworkEndpoint,
  // Structural context information
  frameworkEndpoint.getNamespace(),
  frameworkEndpoint.getClass(),
  // Functional signature details
  frameworkEndpoint.getFunctionName(),
  frameworkEndpoint.getParameters(),
  // Response and type specifications
  frameworkEndpoint.getSupportedStatus(),
  frameworkEndpoint.getSupportedType(),
  // Source location and classification
  frameworkEndpoint.getFileName(),
  frameworkEndpoint.getKind()