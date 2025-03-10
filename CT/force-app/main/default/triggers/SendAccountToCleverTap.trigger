trigger SendAccountToCleverTap on Account (after insert, after update) {
    CleverTapIntegrationHandler.processAccounts(Trigger.new);
}
