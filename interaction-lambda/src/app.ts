import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { Lambda } from 'aws-sdk';
import { verifyKey } from 'discord-interactions';
import { get_env, error_401 } from './util';

// const lambda = new Lambda();
const public_key = get_env("discord_public_key");

export const handler = async (
    event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
    const { body, headers } = event;
    if (!headers || !body) {
        return error_401('headers or body is null.');
    }
    const timestamp = headers['x-signature-timestamp'];
    const signature = headers['x-signature-ed25519'];
    if (!timestamp || !signature) {
        return error_401('timestamp or signature is null.');
    }
    const isValidRequest = verifyKey(body, signature, timestamp, public_key);
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