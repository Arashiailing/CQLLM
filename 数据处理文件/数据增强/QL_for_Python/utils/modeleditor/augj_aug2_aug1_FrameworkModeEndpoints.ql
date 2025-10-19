/**
 * @name Model Editor Framework Mode API Endpoints
 * @description Identifies public API interfaces (methods/attributes) exposed by the framework, excluding test and generated code
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint apiEndpoint
select 
  // API interface reference
  apiEndpoint,
  // Namespace hierarchy containing the interface
  apiEndpoint.getNamespace(),
  // Parent class defining the interface
  apiEndpoint.getClass(),
  // Interface method/attribute identifier
  apiEndpoint.getFunctionName(),
  // Formal parameter specification
  apiEndpoint.getParameters(),
  // Permissible HTTP response codes
  apiEndpoint.getSupportedStatus(),
  // Source file origin location
  apiEndpoint.getFileName(),
  // Compatible data type definitions
  apiEndpoint.getSupportedType(),
  // Interface categorization
  apiEndpoint.getKind()