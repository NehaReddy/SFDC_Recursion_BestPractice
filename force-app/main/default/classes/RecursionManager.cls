public with sharing class RecursionManager {
   private static Integer recursionCount = 0;

   private static final Integer MAX_RECURSION_DEPTH = 16;

   public static Boolean shouldProcess() {
    // If recursion count exceeds the limit, prevent further execution
    if (recursionCount >= MAX_RECURSION_DEPTH) {
        return false; // Stop further processing
    }
    // Otherwise, increment the count and allow processing
    recursionCount++;
    return true;
    }

    // Method to decrement recursion count (usually used in a "finally" block)
    public static void decrementRecursionCount() {
        if (recursionCount > 0) {
            recursionCount--;
        }
    }

    // Method to reset recursion count (useful if needed for specific test cases or scenarios)
    public static void resetRecursionCount() {
        recursionCount = 0;
    }

}