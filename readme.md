## Links

- https://discord.com/developers/docs/interactions/application-commands
- https://discordpy.readthedocs.io/en/stable/
- https://gemisis.medium.com/building-a-serverless-discord-bot-on-aws-5dc7d972c9c6
- https://aws.amazon.com/blogs/compute/operating-lambda-performance-optimization-part-1/
- https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions
- https://docs.stillu.cc/faq/misc/glossary.html
- https://discord.com/developers/docs/topics/community-resources#interactions
- https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html

create application commands
https://discord.com/developers/docs/interactions/application-commands
or create slash command
https://discord.com/developers/docs/interactions/application-commands#slash-commands

## How to add app/bot

You need someone with a role that permits them to add bots to perform the next steps.

To add app (and allow it to create commands): server admin must grant scopes via oauth2 url: https://discord.com/api/oauth2/authorize?client_id=<app_id>&scope=applications.commands

To add bot, create bot user, server admin must do the same by: https://discordapp.com/oauth2/authorize?client_id=<Bot_Client_ID>&scope=bot&permissions=0