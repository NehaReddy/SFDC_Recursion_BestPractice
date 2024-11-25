public with sharing class BadTriggerRecursionFix {
   
   //Approach 1
    public static Boolean hasRun =false;
   public static Boolean runOnce(){
     if(hasRun){
       return false;
     }
     hasRun = true;
     return true;
   }

   //Usage: use like this in your trigger handler class
   /* If(!BadTriggerRecursionFix.runOnce()){
        return;
    }*/

    //----------------------------------------------------------------

    //Approach 2
    Private static Set<Id> alreadyUsedRecords  = new Set<Id>();
    Public static Boolean runOnce(Set<Id>  triggerIds){
		return alreadyUsedRecords.addAll(triggerIds);
	}
	//Usage :use like this in your trigger handler class
	/*If(!BadTriggerRecursionFix.runOnce(Trigger.newMap.keySet() )){
		return;
	}*/

}
