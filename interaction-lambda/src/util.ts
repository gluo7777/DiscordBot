import { APIGatewayProxyResult, APIGatewayProxyEvent, APIGatewayProxyEventHeaders } from 'aws-lambda';
import { verifyKey } from 'discord-interactions';
import { DiscordEventRequest } from './types';

/**
 * Discord expects a 200 for success and 401 for any errors (not only authorization errors)
 * @param msg 
 * @returns response with 401 status code
 */
export const error_401 = (msg: string): APIGatewayProxyResult => {
    return {
        statusCode: 401,
        body: JSON.stringify(`Invalid input - ${msg}`)
    }
}

export const get_env = (key: string): string => {
    const value = process.env[key];
    if(!value) throw new Error(`Environment variable '${key}' is not defined.`)
    return value;
}

export async function verifyEvent(public_key: string, event: DiscordEventRequest): Promise<boolean> {
    return verifyKey(event.jsonBody, event.signature, event.timestamp, public_key);
}