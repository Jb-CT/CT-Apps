/**
 * @class ApiRequestTest
 * @description Test class for ApiRequest to ensure proper HTTP request construction.
 */
@isTest
private class ApiRequestTest {
    
    /**
     * @description Tests constructor with valid credentials
     */
    @isTest
    static void testConstructorValidCredentials() {
        // Setup test data
        Map<String, String> credentials = new Map<String, String>{
            'API_URL' => 'https://test-api.example.com',
            'ACCOUNT_ID' => 'test-account-123',
            'PASSCODE' => 'test-passcode-456'
        };
        String testJson = '{"test":"value"}';
        
        // Test
        Test.startTest();
        ApiRequest request = new ApiRequest(credentials, testJson);
        Test.stopTest();
        
        // Verify
        System.assertEquals('https://test-api.example.com', request.apiUrl, 'API URL should match the provided value');
        System.assertEquals(testJson, request.jsonBody, 'JSON body should match the provided value');
        System.assertEquals('test-account-123', request.headers.get('X-CleverTap-Account-Id'), 'Account ID header should match the provided value');
        System.assertEquals('test-passcode-456', request.headers.get('X-CleverTap-Passcode'), 'Passcode header should match the provided value');
        System.assertEquals('application/json', request.headers.get('Content-Type'), 'Content-Type header should be application/json');
    }
    
    /**
     * @description Tests constructor with null credentials
     */
    @isTest
    static void testConstructorNullCredentials() {
        // Setup test data
        Map<String, String> credentials = null;
        String testJson = '{"test":"value"}';
        
        // Test - should throw exception
        Test.startTest();
        try {
            ApiRequest request = new ApiRequest(credentials, testJson);
            // Add assertion using the request variable to address the unused variable warning
            System.assertNotEquals(null, request, 'Request should not be null');
            System.assert(false, 'Should have thrown NullPointerException');
        } catch (NullPointerException e) {
            // Expected exception
            System.assert(true, 'NullPointerException was correctly thrown');
        } catch (Exception e) {
            System.assert(false, 'Wrong exception type thrown: ' + e.getTypeName());
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests constructor with empty credentials map
     */
    @isTest
    static void testConstructorEmptyCredentials() {
        // Setup test data
        Map<String, String> credentials = new Map<String, String>();
        String testJson = '{"test":"value"}';
        
        // Test
        Test.startTest();
        ApiRequest request = new ApiRequest(credentials, testJson);
        Test.stopTest();
        
        // Verify
        System.assertEquals(null, request.apiUrl, 'API URL should be null when not provided');
        System.assertEquals(testJson, request.jsonBody, 'JSON body should match the provided value');
        System.assertEquals(null, request.headers.get('X-CleverTap-Account-Id'), 'Account ID header should be null when not provided');
        System.assertEquals(null, request.headers.get('X-CleverTap-Passcode'), 'Passcode header should be null when not provided');
        System.assertEquals('application/json', request.headers.get('Content-Type'), 'Content-Type header should be application/json');
    }
    
    /**
     * @description Tests hasMissingCredentials with complete credentials
     */
    @isTest
    static void testHasMissingCredentialsComplete() {
        // Setup
        Map<String, String> credentials = new Map<String, String>{
            'API_URL' => 'https://test-api.example.com',
            'ACCOUNT_ID' => 'test-account-123',
            'PASSCODE' => 'test-passcode-456'
        };
        ApiRequest request = new ApiRequest(credentials, '{}');
        
        // Test
        Test.startTest();
        Boolean result = request.hasMissingCredentials();
        Test.stopTest();
        
        // Verify
        System.assertEquals(false, result, 'Should return false when all required credentials are present');
    }
    
    /**
     * @description Tests hasMissingCredentials with missing API URL
     */
    @isTest
    static void testHasMissingCredentialsMissingApiUrl() {
        // Setup
        Map<String, String> credentials = new Map<String, String>{
            'API_URL' => '',  // Empty API URL
            'ACCOUNT_ID' => 'test-account-123',
            'PASSCODE' => 'test-passcode-456'
        };
        ApiRequest request = new ApiRequest(credentials, '{}');
        
        // Test
        Test.startTest();
        Boolean result = request.hasMissingCredentials();
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result, 'Should return true when API URL is missing');
    }
    
    /**
     * @description Tests hasMissingCredentials with missing Account ID
     */
    @isTest
    static void testHasMissingCredentialsMissingAccountId() {
        // Setup
        Map<String, String> credentials = new Map<String, String>{
            'API_URL' => 'https://test-api.example.com',
            'ACCOUNT_ID' => '',  // Empty Account ID
            'PASSCODE' => 'test-passcode-456'
        };
        ApiRequest request = new ApiRequest(credentials, '{}');
        
        // Test
        Test.startTest();
        Boolean result = request.hasMissingCredentials();
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result, 'Should return true when Account ID is missing');
    }
    
    /**
     * @description Tests hasMissingCredentials with missing Passcode
     */
    @isTest
    static void testHasMissingCredentialsMissingPasscode() {
        // Setup
        Map<String, String> credentials = new Map<String, String>{
            'API_URL' => 'https://test-api.example.com',
            'ACCOUNT_ID' => 'test-account-123',
            'PASSCODE' => ''  // Empty Passcode
        };
        ApiRequest request = new ApiRequest(credentials, '{}');
        
        // Test
        Test.startTest();
        Boolean result = request.hasMissingCredentials();
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result, 'Should return true when Passcode is missing');
    }
    
    /**
     * @description Tests hasMissingCredentials with all missing credentials
     */
    @isTest
    static void testHasMissingCredentialsAllMissing() {
        // Setup
        Map<String, String> credentials = new Map<String, String>{
            'API_URL' => '',
            'ACCOUNT_ID' => '',
            'PASSCODE' => ''
        };
        ApiRequest request = new ApiRequest(credentials, '{}');
        
        // Test
        Test.startTest();
        Boolean result = request.hasMissingCredentials();
        Test.stopTest();
        
        // Verify
        System.assertEquals(true, result, 'Should return true when all credentials are missing');
    }
}