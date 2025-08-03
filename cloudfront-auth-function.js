function handler(event) {
    var request = event.request;
    var headers = request.headers;
    
    // Credentials will be injected by Terraform template
    var username = 'AUTH_USERNAME_PLACEHOLDER';
    var password = 'AUTH_PASSWORD_PLACEHOLDER';
    
    // Check if Authorization header exists
    if (!headers.authorization || !headers.authorization.value) {
        return {
            statusCode: 401,
            statusDescription: 'Unauthorized',
            headers: {
                'www-authenticate': { value: 'Basic realm="Secure Area"' }
            }
        };
    }
    
    // Decode Authorization header
    var authValue = headers.authorization.value;
    if (!authValue.startsWith('Basic ')) {
        return {
            statusCode: 401,
            statusDescription: 'Unauthorized',
            headers: {
                'www-authenticate': { value: 'Basic realm="Secure Area"' }
            }
        };
    }
    
    // Extract and decode credentials
    var encodedCredentials = authValue.substring(6);
    var decodedCredentials = atob(encodedCredentials);
    var credentials = decodedCredentials.split(':');
    
    if (credentials.length !== 2) {
        return {
            statusCode: 401,
            statusDescription: 'Unauthorized',
            headers: {
                'www-authenticate': { value: 'Basic realm="Secure Area"' }
            }
        };
    }
    
    var providedUsername = credentials[0];
    var providedPassword = credentials[1];
    
    // Validate credentials
    if (providedUsername === username && providedPassword === password) {
        return request;
    }
    
    return {
        statusCode: 401,
        statusDescription: 'Unauthorized',
        headers: {
            'www-authenticate': { value: 'Basic realm="Secure Area"' }
        }
    };
} 