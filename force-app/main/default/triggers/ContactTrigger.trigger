trigger ContactTrigger on Contact (before update, after update) {
    if (Trigger.isBefore) {
        // Before update logic (e.g., validation or initial changes)
        ContactTriggerHandler.handleContactBeforeUpdate(Trigger.new);
    }
    else if (Trigger.isAfter) {
        // After update logic (e.g., making changes to related records)
        ContactTriggerHandler.handleContactAfterUpdate(Trigger.new);
    }
}