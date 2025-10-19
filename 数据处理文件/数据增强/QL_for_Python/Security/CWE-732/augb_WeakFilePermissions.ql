/**
 * @name Overly permissive file permissions
 * @description Allowing files to be readable or writable by users other than the owner may allow sensitive information to be accessed.
 * @kind problem
 * @id py/overly-permissive-file
 * @problem.severity warning
 * @security-severity 7.8
 * @sub-severity high
 * @precision medium
 * @tags external/cwe/cwe-732
 *       security
 */

import python
import semmle.python.ApiGraphs

// Helper function to extract world-readable/writable permission bits
bindingset[permissionValue]
int get_world_permission(int permissionValue) { 
  result = permissionValue % 8 
}

// Helper function to extract group-readable/writable permission bits
bindingset[permissionValue]
int get_group_permission(int permissionValue) { 
  result = (permissionValue / 8) % 8 
}

// Helper function to convert permission bits to descriptive string
bindingset[permissionValue]
string get_permission_description(int permissionValue) {
  permissionValue % 4 >= 2 and result = "writable"  // Writable if last two bits >= 2
  or
  permissionValue % 4 < 2 and permissionValue != 0 and result = "readable"  // Readable if non-zero but < 2
}

// Helper function to identify overly permissive permission configurations
bindingset[permissionValue]
string get_permissive_permission_type(int permissionValue) {
  result = "world " + get_permission_description(get_world_permission(permissionValue))  // Check world permissions first
  or
  get_world_permission(permissionValue) = 0 and result = "group " + get_permission_description(get_group_permission(permissionValue))  // Fall back to group if world is 0
}

// Predicate to identify os.chmod calls with explicit permission modes
predicate is_chmod_call(API::CallNode callNode, string functionName, int permissionMode) {
  callNode = API::moduleImport("os").getMember("chmod").getACall() and
  permissionMode = callNode.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  functionName = "chmod"
}

// Predicate to identify os.open calls with explicit permission modes
predicate is_open_call(API::CallNode callNode, string functionName, int permissionMode) {
  callNode = API::moduleImport("os").getMember("open").getACall() and
  permissionMode = callNode.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  functionName = "open"
}

// Main query: Identify file permission operations with overly permissive settings
from API::CallNode callNode, string functionName, int permissionMode, string permissionDescription
where
  (is_chmod_call(callNode, functionName, permissionMode) or is_open_call(callNode, functionName, permissionMode)) and
  permissionDescription = get_permissive_permission_type(permissionMode)
select callNode, "Overly permissive mask in " + functionName + " sets file to " + permissionDescription + "."