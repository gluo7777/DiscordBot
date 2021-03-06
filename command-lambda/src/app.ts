import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import axios from 'axios';
import { DiscordEventRequest } from './types';
import { get_env, get_secret } from './util';

// https://discord.com/api/v8/interactions
const discord_api_url = get_env('discord_api_url')
const get_application_id = get_secret(get_env('discord_api_key'));
const get_bot_token = get_secret(get_env('discord_bot_token'));

/**
 * Acknowledges initial request from Discord.
 */
export const handler = async (
    event: DiscordEventRequest
): Promise<string> => {
    console.log('Command request', event);
    // POST /webhooks/<application_id>/<interaction_token> to send a new followup message
    // https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
    const jsonBody = JSON.parse(event.jsonBody);
    const interaction_token = jsonBody['token'];
    const application_id = await get_application_id;
    const bot_token = await get_bot_token;
    const webhook_url = `${discord_api_url}/webhooks/${await application_id}/${interaction_token}`;
    const discord_rsp = await axios.post(webhook_url, {
        tts: false,
        content: "Hello World!",
        embeds: [],
        allowed_mentions: {
            parse: []
        },
    }, {
        headers: {
            'Authorization': `Bot ${bot_token}`
        }
    });
    console.log('Command response', discord_rsp);
    return 'OK';
}