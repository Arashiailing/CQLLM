/**
 * @name Model Editor Framework-Mode Endpoint Catalog
 * @description Generates a catalog of endpoints (methods and attributes) accessible in the model editor's framework mode. 
 *              The query excludes test and generated code artifacts from the results to focus on production code.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor capabilities for endpoint analysis
import modeling.ModelEditor

// Identify framework-mode endpoints while excluding test/generated artifacts
from Endpoint editorEndpoint
select 
  // Core endpoint identification
  editorEndpoint,
  editorEndpoint.getKind(),
  editorEndpoint.getFunctionName(),
  
  // Structural context information
  editorEndpoint.getClass(),
  editorEndpoint.getNamespace(),
  
  // Functional specification details
  editorEndpoint.getParameters(),
  editorEndpoint.getSupportedType(),
  editorEndpoint.getSupportedStatus(),
  
  // Source code location reference
  editorEndpoint.getFileName()