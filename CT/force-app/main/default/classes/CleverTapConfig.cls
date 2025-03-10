/**
 * @class CleverTapConfig
 * @description Provides configuration settings for the CleverTap integration by retrieving API credentials from custom metadata.
 */
public with sharing class CleverTapConfig {
    
    /**
     * @description Gets the CleverTap credentials.
     * @return Map<String, String> containing all necessary credentials.
     */
    public static Map<String, String> getCredentials() {
        // Ensure the user has read access to CleverTap_Config__mdt
        if (!Schema.sObjectType.CleverTap_Config__mdt.isAccessible()) {
            return null;
        }

        List<CleverTap_Config__mdt> configList = [
            SELECT DeveloperName, MasterLabel, CleverTap_API_URL__c, 
                   CleverTap_Account_ID__c, CleverTap_Passcode__c,
                   Region__c
            FROM CleverTap_Config__mdt 
            WHERE MasterLabel != '[Deleted]'
            LIMIT 1
        ];

        if (configList.isEmpty()) {
            return null;
        }

        //need to improve this as its only getting the id and password of the first row
        CleverTap_Config__mdt config = configList[0];

        Map<String, String> credentials = new Map<String, String>{
            'NAME'       => config.MasterLabel,
            'DEV_NAME'   => config.DeveloperName,
            'API_URL'    => config.CleverTap_API_URL__c,
            'ACCOUNT_ID' => config.CleverTap_Account_ID__c,
            'PASSCODE'   => config.CleverTap_Passcode__c,
            'REGION'     => config.Region__c
        };
        
        return credentials;
    }
}