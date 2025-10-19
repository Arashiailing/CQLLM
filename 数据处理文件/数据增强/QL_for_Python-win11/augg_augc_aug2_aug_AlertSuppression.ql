/**
 * @name Alert suppression
 * @description Provides detailed analysis of alert suppression features in Python source code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import utilities for managing alert suppression functionality
private import codeql.util.suppression.AlertSuppression as SuppressionUtils
// Import tools for processing Python code comments
private import semmle.python.Comment as PythonComment

// Represents code structure elements with advanced location tracking
class CodeNode instanceof PythonComment::AstNode {
  // Determine if the node matches the specified location parameters
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, concludeLine, concludeCol)
  }

  // Generate a text representation of the code node
  string toString() { result = super.toString() }
}

// Represents comments spanning a single line with accurate location data
class OneLineComment instanceof PythonComment::Comment {
  // Verify if the comment matches the provided location information
  predicate hasLocationInfo(
    string sourceFile, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, beginLine, beginCol, concludeLine, concludeCol)
  }

  // Extract the text content from the comment
  string getText() { result = super.getContents() }

  // Generate a text representation of the comment
  string toString() { result = super.toString() }
}

// Apply the suppression relationship creation pattern using the SuppressionUtils template
import SuppressionUtils::Make<CodeNode, OneLineComment>

/**
 * A noqa suppression comment. Both pylint and pyflakes respect this, so lgtm ought to too.
 */
// Identifies comments that follow the noqa suppression convention
class NoqaIgnoreComment extends SuppressionComment instanceof OneLineComment {
  // Constructor that identifies noqa comment formats
  NoqaIgnoreComment() {
    OneLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the identifier for this suppression annotation
  override string getAnnotation() { result = "lgtm" }

  // Define the scope covered by this suppression annotation
  override predicate covers(
    string sourceFile, int beginLine, int beginCol, int concludeLine, int concludeCol
  ) {
    // Ensure the comment location matches and requires line-start positioning
    this.hasLocationInfo(sourceFile, beginLine, _, concludeLine, concludeCol) and
    beginCol = 1
  }
}