/**
 * @name Retrieve framework-mode endpoints for Model Editor integration
 * @description Identifies and lists all accessible API endpoints (methods and attributes) 
 *              available for library consumers. Filters out test code and auto-generated files.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import the ModelEditor module which provides functionality for model editing
import modeling.ModelEditor

// Query all endpoint objects and extract their attributes for display in a tabular format
from Endpoint apiEndpoint
select 
  // Core endpoint identification
  apiEndpoint,
  apiEndpoint.getNamespace(),
  apiEndpoint.getClass(),
  apiEndpoint.getFunctionName(),
  
  // Endpoint signature details
  apiEndpoint.getParameters(),
  apiEndpoint.getSupportedType(),
  
  // Endpoint metadata
  apiEndpoint.getSupportedStatus(),
  apiEndpoint.getFileName(),
  apiEndpoint.getKind()