import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { Lambda } from 'aws-sdk';
import { get_env, error_401, verifyEvent } from './util';
import { DiscordEventRequest } from './types';

const lambda = new Lambda();
const public_key = get_env("discord_public_key");
const command_function_arn = get_env("command_function_arn");

export const handler = async (
    event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
    const { headers, body } = event;
    if (!headers || !body) {
        return error_401('request header or body is missing');
    }

    const timestamp = headers['x-signature-timestamp'];
    const signature = headers['x-signature-ed25519'];
    if (!timestamp)
        return error_401('timestamp is missing from request headers.');
    if (!signature)
        return error_401('signature is missing from request headers.');

    const discordEvent: DiscordEventRequest = {
        timestamp: timestamp,
        signature: signature,
        jsonBody: body
    };
    const verify_event = verifyEvent(public_key, discordEvent);

    const input = JSON.parse(body);
    const inputType: number = input['type'];
    switch (inputType) {
        case 1:
            if (await verify_event) {
                return {
                    statusCode: 200,
                    body: JSON.stringify({
                        type: 1
                    })
                };
            }
            break;
        case 2:
            const invoke_lambda = lambda.invoke({
                FunctionName: command_function_arn,
                Payload: JSON.stringify(discordEvent),
                InvocationType: 'Event'
            }).promise();
            if (await Promise.all([verify_event, invoke_lambda])) {
                return {
                    statusCode: 200,
                    body: JSON.stringify({
                        type: 5
                    })
                };
            }
            break;
        }
    return error_401('request failed');
}