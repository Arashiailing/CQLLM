/**
 * @name Alert suppression
 * @description Provides detailed information about alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for handling suppression logic
private import codeql.util.suppression.AlertSuppression as SuppressionUtils
// Import Python comment processing utilities for analyzing code comments
private import semmle.python.Comment as PythonComment

// Represents AST nodes with enhanced location tracking capabilities
class AstNode instanceof PythonComment::AstNode {
  // Verify if node corresponds to specific location coordinates
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Generate string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with precise location tracking
class SingleLineComment instanceof PythonComment::Comment {
  // Determine if comment matches specified location coordinates
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginColumn, finishLine, finishColumn)
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
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the scope of code coverage for this suppression annotation
  override predicate covers(
    string sourceFile, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Ensure comment location matches and enforce line-start positioning
    this.hasLocationInfo(sourceFile, beginLine, _, finishLine, finishColumn) and
    beginColumn = 1
  }
}