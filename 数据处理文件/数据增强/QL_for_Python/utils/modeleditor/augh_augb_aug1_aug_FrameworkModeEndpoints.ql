/**
 * @name Framework-mode endpoint catalog for model editor
 * @description This query provides a comprehensive catalog of all accessible endpoints 
 *              (both methods and attributes) available in the model editor's framework mode.
 *              The analysis intentionally excludes test code and auto-generated artifacts to
 *              ensure focus solely on production-grade endpoints.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import the ModelEditor module which provides endpoint analysis functionality
import modeling.ModelEditor

// Source all framework-mode endpoints from the ModelEditor system
from Endpoint frameworkEndpoint
select 
  // Primary endpoint reference object
  frameworkEndpoint,
  // Namespace/path where the endpoint is defined
  frameworkEndpoint.getNamespace(),
  // Class that contains or implements this endpoint
  frameworkEndpoint.getClass(),
  // Name of the method or function representing the endpoint
  frameworkEndpoint.getFunctionName(),
  // Complete parameter signature accepted by the endpoint
  frameworkEndpoint.getParameters(),
  // Collection of HTTP status codes supported by this endpoint
  frameworkEndpoint.getSupportedStatus(),
  // Source file location where the endpoint is implemented
  frameworkEndpoint.getFileName(),
  // Data types that the endpoint can process or return
  frameworkEndpoint.getSupportedType(),
  // Classification indicating whether this is a method or attribute endpoint
  frameworkEndpoint.getKind()