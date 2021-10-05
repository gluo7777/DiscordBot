import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import axios from 'axios';
import { DiscordEventRequest } from './types';
import { get_env, get_secret } from './util';

// https://discord.com/api/v8/interactions
const discord_api_url = get_env('discord_api_url')
const get_application_id = get_secret(get_env('discord_api_key'));

/**
 * Acknowledges initial request from Discord.
 */
export const handler = async (
    event: DiscordEventRequest
) : Promise<string> => {
    console.log('Command request', event);
    // POST /webhooks/<application_id>/<interaction_token> to send a new followup message
    // https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
    const jsonBody = JSON.parse(event.jsonBody);
    const interaction_id = jsonBody['id'];
    const response = {
        type: 4,
        data: {
            tts: false,
            content: "Hello World!",
            embeds: [],
            allowed_mentions: {
                parse: []
            }
        }
    };
    const application_id = await get_application_id;
    const webhook_url = `${discord_api_url}/webhooks/${await application_id}/${interaction_id}`;
    const discord_rsp = await axios.post(webhook_url, {
        jsonBody: response
    });
    console.log('Command response', discord_rsp);
    return 'OK';
}