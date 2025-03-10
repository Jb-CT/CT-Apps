/**
 * @class ApiRequest
 * @description Constructs an HTTP request for API calls using provided credentials and payload.
 */
public with sharing class ApiRequest {

    /**
     * @description The URL endpoint for the API.
     */
    public String apiUrl { get; set; }

    /**
     * @description The HTTP headers to include with the request, containing credentials.
     */
    public Map<String, String> headers { get; set; }

    /**
     * @description The JSON body to send in the request.
     */
    public String jsonBody { get; set; }
    
    /**
     * @description Constructor to initialize an API request with credentials and a JSON payload.
     * @param credentials A map containing API credentials (API_URL, ACCOUNT_ID, PASSCODE).
     * @param jsonBody The JSON payload to send.
     */
    public ApiRequest(Map<String, String> credentials, String jsonBody) {
        this.apiUrl = credentials.get('API_URL');
        this.jsonBody = jsonBody;
        this.headers = new Map<String, String>{
            'X-CleverTap-Account-Id' => credentials.get('ACCOUNT_ID'),
            'X-CleverTap-Passcode' => credentials.get('PASSCODE'),
            'Content-Type' => 'application/json'
        };
    }
    
    /**
     * @description Checks if any required credentials are missing.
     * @return True if API_URL, Account ID, or Passcode is missing; otherwise, false.
     */
    public Boolean hasMissingCredentials() {
        return String.isBlank(apiUrl) ||
               String.isBlank(headers.get('X-CleverTap-Account-Id')) ||
               String.isBlank(headers.get('X-CleverTap-Passcode'));
    }
}