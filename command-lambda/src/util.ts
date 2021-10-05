import {SecretsManager} from 'aws-sdk';

const secrets_manager = new SecretsManager();

export const get_env = (key: string): string => {
    console.log('retrieving env', key);
    const value = process.env[key];
    if(!value) throw new Error(`Environment variable '${key}' is not defined.`)
    return value;
}

export async function get_secret(secret: string): Promise<string> {
    console.log('retrieving secret', secret);
    const response = await secrets_manager.getSecretValue({SecretId: secret}).promise();
    const {error,data} = response.$response;
    if (error) {
        throw error;
    }
    else {
        // Decrypts secret using the associated KMS CMK.
        // Depending on whether the secret is a string or binary, one of these fields will be populated.
        if (data && 'SecretString' in data) {
            if(!data.SecretString)
                throw Error('SecretString is null');
            return data.SecretString;
        }
        throw Error('SecretString missing from data');
    }
}