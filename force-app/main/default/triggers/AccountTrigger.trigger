trigger AccountTrigger on Account (before update, after update) {
    if (Trigger.isBefore) {
        // Before update logic (e.g., validation or initial changes)
        AccountTriggerHandler.handleAccountBeforeUpdate(Trigger.new);
    }
    else if (Trigger.isAfter) {
        // After update logic (e.g., making changes to related records)
        AccountTriggerHandler.handleAccountAfterUpdate(Trigger.new);
    }
}