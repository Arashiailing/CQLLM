/**
 * @name Python PointsTo Relationship Statistics Analysis
 * @description Analyzes statistics of point-to relationships in Python code,
 *              including unique facts count, total relations size, and
 *              compression ratio based on context depth.
 */

import python
import semmle.python.pointsto.PointsTo
import semmle.python.pointsto.PointsToContext

// Define output variables: unique facts count, total relations, context depth, and compression rate
from int unique_facts, int total_relations, int ctx_depth, float compression_rate
where
  // Count unique point-to facts (f, value, cls combinations)
  unique_facts =
    strictcount(ControlFlowNode f, Object value, ClassObject cls |
      exists(PointsToContext ctx |
        // Verify point-to relationship exists in some context
        PointsTo::points_to(f, ctx, value, cls, _) and
        // Record the context depth for grouping results
        ctx_depth = ctx.getDepth()
      )
    ) and
  // Count total point-to relations (including all f, value, cls, ctx, orig combinations)
  total_relations =
    strictcount(ControlFlowNode f, Object value, ClassObject cls, PointsToContext ctx,
      ControlFlowNode orig |
      // Validate complete point-to relationship with original node
      PointsTo::points_to(f, ctx, value, cls, orig) and
      // Ensure consistent context depth for accurate grouping
      ctx_depth = ctx.getDepth()
    ) and
  // Calculate compression ratio: represents compression efficiency as percentage
  compression_rate = 100.0 * unique_facts / total_relations
// Output results grouped by context depth
select ctx_depth, unique_facts, total_relations, compression_rate