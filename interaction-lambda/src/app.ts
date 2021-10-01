import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

/**
 * Acknowledges initial request from Discord.
 */
export const handler = async (
    event: APIGatewayProxyEvent
) : Promise<APIGatewayProxyResult> => {
    console.log("Lambda was invoked!");
    const queries = JSON.stringify(event.queryStringParameters);
    return {
        statusCode: 200,
        body: `Queries: ${queries}`
    };
}