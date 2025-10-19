/**
 * @name Overly permissive file permissions
 * @description File operations that set overly permissive access may expose sensitive data.
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

// Extracts the world-readable/writable permission bits from a permission value
bindingset[permissionValue]
int extract_world_permission_bits(int permissionValue) { 
  result = permissionValue % 8 
}

// Extracts the group-readable/writable permission bits from a permission value
bindingset[permissionValue]
int extract_group_permission_bits(int permissionValue) { 
  result = (permissionValue / 8) % 8 
}

// Converts permission bits to a descriptive string indicating the type of access
bindingset[permissionValue]
string describe_permission_access(int permissionValue) {
  permissionValue % 4 >= 2 and result = "writable"  // Writable if last two bits >= 2
  or
  permissionValue % 4 < 2 and permissionValue != 0 and result = "readable"  // Readable if non-zero but < 2
}

// Identifies overly permissive permission configurations and returns a description
bindingset[permissionValue]
string identify_permissive_permissions(int permissionValue) {
  result = "world " + describe_permission_access(extract_world_permission_bits(permissionValue))  // Check world permissions first
  or
  extract_world_permission_bits(permissionValue) = 0 and result = "group " + describe_permission_access(extract_group_permission_bits(permissionValue))  // Fall back to group if world is 0
}

// Detects os.chmod calls with explicit permission modes
predicate detect_chmod_with_permissions(API::CallNode apiCall, string apiName, int permissionValue) {
  apiCall = API::moduleImport("os").getMember("chmod").getACall() and
  permissionValue = apiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  apiName = "chmod"
}

// Detects os.open calls with explicit permission modes
predicate detect_open_with_permissions(API::CallNode apiCall, string apiName, int permissionValue) {
  apiCall = API::moduleImport("os").getMember("open").getACall() and
  permissionValue = apiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  apiName = "open"
}

// Main query: Find file permission operations with overly permissive settings
from API::CallNode apiCall, string apiName, int permissionValue, string permissionIssue
where
  (detect_chmod_with_permissions(apiCall, apiName, permissionValue) or detect_open_with_permissions(apiCall, apiName, permissionValue)) and
  permissionIssue = identify_permissive_permissions(permissionValue)
select apiCall, "Overly permissive mask in " + apiName + " sets file to " + permissionIssue + "."