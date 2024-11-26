public with sharing class ContactTriggerHandler {
    public static void handleContactBeforeUpdate(List<Contact> contacts) {
        // Before update logic, no recursion logic needed here in this example
    }

    public static void handleContactAfterUpdate(List<Contact> contacts) {
        System.debug('Entering handleContactAfterUpdate method');
        // Use the RecursionManager to check if we should continue processing
        if (!RecursionManager.shouldProcess()) {
            System.debug('RecursionManagerCOntact'+RecursionManager.shouldProcess());
            return; // Stop further processing if recursion depth exceeded
        }

        try {
            // Set to collect Account IDs that need to be updated
            Set<Id> accountIdsToUpdate = new Set<Id>();

            // Collect AccountIds where the Phone has changed
            for (Contact con : contacts) {
                Contact oldCon = (Contact)Trigger.oldMap.get(con.Id);
                if (con.Phone != null && con.Phone != oldCon.Phone && con.AccountId != null) {
                    accountIdsToUpdate.add(con.AccountId);
                }
            }

            // Perform DML on Accounts if necessary
            if (!accountIdsToUpdate.isEmpty()) {
                // Query Accounts based on the collected Account IDs
                List<Account> accountsToUpdate = [SELECT Id, Phone FROM Account WHERE Id IN :accountIdsToUpdate];

                // Map Account ID to the Phone number that needs to be set
                Map<Id, String> accountPhoneMap = new Map<Id, String>();

                // Loop through contacts to set Account Phone based on the first contact's Phone
                for (Contact con : contacts) {
                    if (con.Phone != null && con.AccountId != null && con.Phone != ((Contact)Trigger.oldMap.get(con.Id)).Phone) {
                        // If the phone has changed, update the Account's phone if not already set
                        if (!accountPhoneMap.containsKey(con.AccountId)) {
                            accountPhoneMap.put(con.AccountId, con.Phone);
                        }
                    }
                }

                // Now, update the Accounts based on the Phone from the map
                for (Account acc : accountsToUpdate) {
                    if (accountPhoneMap.containsKey(acc.Id)) {
                        acc.Phone = accountPhoneMap.get(acc.Id); // Set the Account's phone to the contact's phone
                    }
                }
              
                // Perform the DML update on the Accounts
                update accountsToUpdate;
                System.debug('Updated contacts with new phone numbers');
            }
        }
        catch (Exception e) {
            System.debug('Error in Contact trigger: ' + e.getMessage());
        } finally {
            // Always decrement the recursion count in the "finally" block to ensure it happens even if an exception occurs
            RecursionManager.decrementRecursionCount();
            System.debug('Recursion guard reset');
        }
    }

}