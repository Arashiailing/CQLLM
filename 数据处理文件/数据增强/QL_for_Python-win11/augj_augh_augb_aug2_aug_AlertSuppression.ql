/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python codebases.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import necessary utilities for alert suppression handling
private import codeql.util.suppression.AlertSuppression as SuppressionUtils
// Import utilities for Python comment analysis
private import semmle.python.Comment as PythonComment

// Represents AST nodes with enhanced location tracking capabilities
class AstNode instanceof PythonComment::AstNode {
  // Verify if node corresponds to specific location coordinates
  predicate hasLocationInfo(
    string filePath, int startLineNum, int startColNum, int endLineNum, int endColNum
  ) {
    super.getLocation().hasLocationInfo(filePath, startLineNum, startColNum, endLineNum, endColNum)
  }

  // Generate string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with precise location tracking
class SingleLineComment instanceof PythonComment::Comment {
  // Determine if comment matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int startLineNum, int startColNum, int endLineNum, int endColNum
  ) {
    super.getLocation().hasLocationInfo(filePath, startLineNum, startColNum, endLineNum, endColNum)
  }

  // Extract the text content from the comment
  string getText() { result = super.getContents() }

  // Provide string representation of the comment
  string toString() { result = super.toString() }
}

// Apply suppression relationship generation using SuppressionUtils template
import SuppressionUtils::Make<AstNode, SingleLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Represents suppression comments following the noqa convention
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor that identifies noqa comment patterns
  NoqaSuppressionComment() {
    this.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the scope of code coverage for this suppression annotation
  override predicate covers(
    string filePath, int startLineNum, int startColNum, int endLineNum, int endColNum
  ) {
    // Ensure comment location matches and enforce line-start positioning
    this.hasLocationInfo(filePath, startLineNum, _, endLineNum, endColNum) and
    startColNum = 1
  }
}