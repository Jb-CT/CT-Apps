trigger SendLeadToCleverTap on Lead (after insert, after update) {
    CleverTapIntegrationHandler.processLeads(Trigger.new);
}
