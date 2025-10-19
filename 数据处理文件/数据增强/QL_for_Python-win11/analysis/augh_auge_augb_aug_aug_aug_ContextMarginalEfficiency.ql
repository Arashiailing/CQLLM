/**
 * Pointer Relationship Depth Distribution Analysis:
 * Analyzes the characteristics of pointer relationships at different depth levels in the codebase, including:
 * - Unique Relationships: Count of unique pointer relationships that first appear at the shallowest depth
 * - Total Relationships: Total count of all pointer relationships at a specific depth level
 * - Efficiency Metric: Percentage of unique relationships relative to total relationships
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// Retrieves the context depth for a control flow node when it points to a specific target object within a class object context
int getContextDepth(ControlFlowNode controlFlowNode, Object targetObject, ClassObject classObject) {
  // Returns the depth of the context where the control flow node points to the target object in the class object context
  exists(PointsToContext context |
    PointsTo::points_to(controlFlowNode, context, targetObject, classObject, _) and
    result = context.getDepth()
  )
}

// Determines the minimum context depth for a control flow node pointing to a specific target object within a class object context
int getMinimumContextDepth(ControlFlowNode controlFlowNode, Object targetObject, ClassObject classObject) {
  // Returns the smallest depth among all possible contexts where the pointing relationship occurs
  result = min(int depth | depth = getContextDepth(controlFlowNode, targetObject, classObject))
}

// Analyzes pointer relationship characteristics across different depth levels
from int uniqueRelationships, int totalRelationships, int depthLevel, float efficiencyPercentage
where
  // Calculate unique relationships: Count of unique pointer relationships where the minimum depth equals the current depth level
  uniqueRelationships = strictcount(ControlFlowNode controlFlowNode, Object targetObject, ClassObject classObject |
    depthLevel = getMinimumContextDepth(controlFlowNode, targetObject, classObject)
  ) and
  // Calculate total relationships: Count of all pointer relationships at the current depth level
  totalRelationships = strictcount(ControlFlowNode controlFlowNode, Object targetObject, ClassObject classObject, 
                         PointsToContext context, ControlFlowNode originNode |
    PointsTo::points_to(controlFlowNode, context, targetObject, classObject, originNode) and
    depthLevel = context.getDepth()
  ) and
  // Calculate efficiency metric: Percentage of unique relationships relative to total relationships (avoiding division by zero)
  totalRelationships > 0 and
  efficiencyPercentage = 100.0 * uniqueRelationships / totalRelationships
// Output results: Depth level, unique relationships count, total relationships count, and efficiency percentage
select depthLevel, uniqueRelationships, totalRelationships, efficiencyPercentage