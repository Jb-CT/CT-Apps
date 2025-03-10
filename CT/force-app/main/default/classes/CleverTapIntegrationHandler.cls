/**
 * @class CleverTapIntegrationHandler
 * @description Handles integration operations between Salesforce and CleverTap by delegating record processing to appropriate services.
 */
public with sharing class CleverTapIntegrationHandler {
    /**
     * @description Processes a list of SObject records by enqueuing them for asynchronous CleverTap integration.
     * @param records The list of SObject records to process.
     */
    public static void processRecords(List<SObject> records) {
        if (records == null || records.isEmpty()) {
            return;
        }
        
        // Use the generic queueable class for all object types
        System.enqueueJob(new CleverTapSyncQueueable(records));
    }
    
    /**
     * @description For backward compatibility with existing triggers
     * @param leads The list of Lead records to process.
     */
    public static void processLeads(List<Lead> leads) {
        processRecords(leads);
    }
    
    /**
     * @description For backward compatibility with existing triggers
     * @param contacts The list of Contact records to process.
     */
    public static void processContacts(List<Contact> contacts) {
        processRecords(contacts);
    }
    
    /**
     * @description For backward compatibility with existing triggers
     * @param accounts The list of Account records to process.
     */
    public static void processAccounts(List<Account> accounts) {
        processRecords(accounts);
    }
    
    /**
     * @description For backward compatibility with existing triggers
     * @param opportunities The list of Opportunity records to process.
     */
    public static void processOpportunities(List<Opportunity> opportunities) {
        processRecords(opportunities);
    }
}