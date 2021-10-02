import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import {Lambda} from 'aws-sdk';

const lambda = new Lambda();

export const handler = async (
    event: APIGatewayProxyEvent
) : Promise<APIGatewayProxyResult> => {
    if(!event.queryStringParameters){
        return error_401();
    }
    const timestamp = event.queryStringParameters['x-signature-timestamp'];
    const signature = event.queryStringParameters['x-signature-ed25519'];
    const body = event.body;
    if( [timestamp,signature,body].some(v => v === null) ){
        return error_401('timestamp, signature, or body is missing.');
    }
    const queries = JSON.stringify(event.queryStringParameters);
    return {
        statusCode: 200,
        body: JSON.stringify({
            msg: 'there will be a message here soon.'
        })
    };
}

/**
 * Discord expects a 200 for success and 401 for any errors (not only authorization errors)
 * @param msg 
 * @returns response with 401 status code
 */
const error_401 = (msg: string = "Invalid input"): APIGatewayProxyResult => {
    return {
        statusCode: 422,
        body: JSON.stringify({
            'message': msg
        })
    }
}