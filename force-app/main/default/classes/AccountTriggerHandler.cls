public with sharing class AccountTriggerHandler {
    public static void handleAccountBeforeUpdate(List<Account> accounts) {
        // Before update logic, no recursion logic needed here in this example
    }

    public static void handleAccountAfterUpdate(List<Account> accounts) {
        System.debug('Entering handleAccountAfterUpdate method');

        if (!RecursionManager.shouldProcess()) {
            System.debug('RecursionManagerAccount'+RecursionManager.shouldProcess());
            return; // Stop further processing if recursion depth exceeded
        }
        try {
        // Collect account Ids for querying related contacts
        Set<Id> accountIdsToUpdate = new Set<Id>();
        Map<Id, String> updatedAccountPhones = new Map<Id, String>();

        // Identify accounts where Phone field has changed
        for (Account acc : accounts) {
            if (acc.Phone != null && acc.Phone != ((Account)Trigger.oldMap.get(acc.Id)).Phone) {
                accountIdsToUpdate.add(acc.Id);
                updatedAccountPhones.put(acc.Id, acc.Phone);
            }
        }

        // If no account phone has been updated, no need to proceed
        if (accountIdsToUpdate.isEmpty()) {
            return;
        }

        // Query all related Contacts for these Account IDs
        List<Contact> contactsToUpdate = [SELECT Id, AccountId, Phone 
                                          FROM Contact 
                                          WHERE AccountId IN :accountIdsToUpdate];

        // Update the Phone on related contacts
        for (Contact contact : contactsToUpdate) {
            if (updatedAccountPhones.containsKey(contact.AccountId)) {
                contact.Phone = updatedAccountPhones.get(contact.AccountId);
            }
        }

        // Perform the update on Contacts
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
    } catch (Exception e) {
        System.debug('Error in Account trigger: ' + e.getMessage());
    } finally {
        // Always decrement the recursion count in the "finally" block to ensure it happens even if an exception occurs
        RecursionManager.decrementRecursionCount();
        System.debug('Recursion guard reset');
    }
    }
}