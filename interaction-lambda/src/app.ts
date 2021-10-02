import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { Lambda } from 'aws-sdk';
import { verifyKey } from 'discord-interactions';

const lambda = new Lambda();

export const handler = async (
    event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
    const { body, queryStringParameters } = event;
    if (!queryStringParameters || !body) {
        return error_401('query string or body is null.');
    }
    const timestamp = queryStringParameters['X-Signature-Timestamp'];
    const signature = queryStringParameters['X-Signature-Ed25519'];
    if (!timestamp || !signature) {
        return error_401('timestamp or signature is null.');
    }
    const isValidRequest = verifyKey(body, signature, timestamp, 'MY_CLIENT_PUBLIC_KEY');
    if (!isValidRequest) {
        return error_401('signature validation was unsuccessful.')
    }
    const input = JSON.parse(body);
    const inputType: number = input['type'];
    if (inputType === 1) {
        return {
            statusCode: 200,
            body: JSON.stringify({
                type: 1
            })
        };
    } else {
        return {
            statusCode: 200,
            body: JSON.stringify({
                type: 4,
                data: {
                    tts: false,
                    content: 'Wow, you sent a command. How nice!',
                    embeds: [],
                    allowed_mentions: {
                        parse: []
                    }
                }
            })
        };
    }

}

/**
 * Discord expects a 200 for success and 401 for any errors (not only authorization errors)
 * @param msg 
 * @returns response with 401 status code
 */
const error_401 = (msg: string = "Invalid input"): APIGatewayProxyResult => {
    return {
        statusCode: 401,
        body: JSON.stringify(`Bad request signature - ${msg}`)
    }
}