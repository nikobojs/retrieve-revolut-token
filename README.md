# Revolut Business API Client Token Generation

This bash script will guide you through the generation of a refresh token for a Revolut business customer. Specifically, it provides read access to the [Revolut Business API](https://developer.revolut.com/docs/business/business-api).

The script assumes that you have generated public and private keys as described in [step 3.1 of the official guide](https://developer.revolut.com/docs/guides/manage-accounts/get-started/make-your-first-api-request#1-add-your-certificate).

**Warning:** The script does not handle errors or exceptions; please review the output carefully.

The script contains these steps:

1. **Send Public Key to Revolut user**: Send your public key to the Revolut user.
2. **Create Business API Key**: Ask the Revolut user to create a Business API key and insert the public key.
3. **Insert Client ID and Redirection URI**: Ask the Revolut user to copy/paste the Client ID and Redirection URI.
4. **Generate JWT Header and Payload**: The script generates the JWT header and payload with the provided information.
5. **Generate Signature**: The script adds the signature to the JWT, which is now done.
6. **Enable API Key on Revolut**: Ask the Revolut user to enable the API key on the Revolut web app, but not submit it right away.
7. **Add Scope to URL and Authorize**: Ask the Revolut user to add the query parameter (`scope=READ`) and navigate to the URL. Ask the Revolut user to authorize/submit the form.
8. **Insert Authorization Code**: Ask the Revolut user to send the `code` query parameter from the redirect URL.
9. **Get Refresh Token**: Using the client assertion JWT and authorization code, the script will authorize and fetch a refresh token from the Revolut API.

**Usage**

1. Run the script in your terminal.
2. Follow the prompts to provide necessary information (public key, Client ID, Redirection URI, and authorization code).
3. Review the generated JWT and the output/tokens.json file.

**Dependencies**

* `openssl`
* `jq`
* `curl`

