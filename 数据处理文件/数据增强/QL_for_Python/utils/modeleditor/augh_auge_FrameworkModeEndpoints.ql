/**
 * @name Framework-Mode Endpoint Discovery for Model Editor
 * @description Discovers and catalogs all accessible API endpoints (methods and attributes) 
 *              that are exposed to library consumers. Excludes test code and auto-generated files.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import the ModelEditor module that enables model editing capabilities
import modeling.ModelEditor

// Identify all framework endpoints and extract their properties for tabular presentation
from Endpoint frameworkEndpoint
select 
  // Endpoint identification information
  frameworkEndpoint,
  frameworkEndpoint.getNamespace(),
  frameworkEndpoint.getClass(),
  frameworkEndpoint.getFunctionName(),
  
  // Endpoint type and parameter specifications
  frameworkEndpoint.getParameters(),
  frameworkEndpoint.getSupportedType(),
  
  // Endpoint operational metadata
  frameworkEndpoint.getSupportedStatus(),
  frameworkEndpoint.getFileName(),
  frameworkEndpoint.getKind()