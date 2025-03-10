trigger SendOpportunityToCleverTap on Opportunity (after insert, after update) {
    CleverTapIntegrationHandler.processRecords(Trigger.new);
}