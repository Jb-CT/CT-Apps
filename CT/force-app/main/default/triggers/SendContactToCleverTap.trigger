trigger SendContactToCleverTap on Contact (after insert, after update) {
    CleverTapIntegrationHandler.processContacts(Trigger.new);
}