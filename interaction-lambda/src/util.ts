import { APIGatewayProxyResult } from 'aws-lambda';

/**
 * Discord expects a 200 for success and 401 for any errors (not only authorization errors)
 * @param msg 
 * @returns response with 401 status code
 */
export const error_401 = (msg: string = "Invalid input"): APIGatewayProxyResult => {
    return {
        statusCode: 401,
        body: JSON.stringify(`Bad request signature - ${msg}`)
    }
}

export const get_env = (key: string): string => {
    const value = process.env[key];
    if(!value) throw new Error(`Environment variable '${key}' is not defined.`)
    return value;
}