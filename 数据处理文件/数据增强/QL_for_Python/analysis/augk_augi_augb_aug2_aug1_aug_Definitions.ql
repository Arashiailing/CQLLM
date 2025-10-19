/**
 * @name Navigate to Definitions
 * @description Enhanced navigation utility that traces Python expressions to their source definitions,
 *              enabling efficient code comprehension and maintenance through precise location mapping.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import core Python analysis modules for comprehensive static code examination
import python
import analysis.DefinitionTracking

// Select expressions with valid source definitions and categorization metadata
from 
  NiceLocationExpr expr,           // Target expression requiring definition resolution
  Definition defn,                  // Source definition providing implementation context
  string category                   // Classification of definition type (variable/function/class)
where 
  // Establish definition relationship between expression and its source
  defn = definitionOf(expr, category)
  // Validate location availability for both expression and definition
  and exists(expr.getLocation())
  and exists(defn.getLocation())
// Output navigation triplet: expression, definition location, and category
select expr, defn, category