#!/usr/bin/env bash
echo "[DO THIS NOW] send the public key to the revolut user"
read -p "Press any key to continue... " -n1 -s
echo
echo "[DO THIS NOW] ask the revolut user to create a Business API key and add the public key"
read -p "Press any key to continue... " -n1 -s
echo
echo "[DO THIS NOW] ask the revolut user to send the Client ID and the Redirection URI"
read -p "Press any key to continue... " -n1 -s
echo
read -p "Enter Redirect URI (iss) - without 'https://' and trailing slash: " REDIRECT_URI
read -p "Enter Client ID (sub): " CLIENT_ID

mkdir -p output

echo "generating file output/header.json.."
cat << EOT > output/header.json
{
  "alg": "RS256",
  "typ": "JWT"
}
EOT
cat output/header.json | jq

# current epoch time + (90 days converted to seconds)
# 90 * 24 * 60 * 60 = 7776000
NINETY_DAYS=7776000
EXPIRE_DATE=$(($(date +%s) + $NINETY_DAYS))
echo "setting payload to expire in 90 days. Please note this date:"
echo "- $(date -d @$EXPIRE_DATE)"

echo "generating file output/payload.json.."
cat << EOT > output/payload.json
{
  "iss": "$REDIRECT_URI",
  "sub": "$CLIENT_ID",
  "aud": "https://revolut.com",
  "exp": $EXPIRE_DATE
}
EOT
cat output/payload.json | jq

echo "adding encoded and normalised header to jwt.."
cat output/header.json | tr -d '\n' | tr -d '\r' | openssl enc -base64 -A | tr +/ -_ | tr -d '=' > output/client_assertion.txt
echo -n "." >> output/client_assertion.txt

echo "add encoded and normalised payload to jwt.."
cat output/payload.json | tr -d '\n' | tr -d '\r' | openssl enc -base64 -A | tr +/ -_ | tr -d '=' >> output/client_assertion.txt

echo "generating signature.."
cat output/client_assertion.txt | tr -d '\n' | tr -d '\r' | openssl dgst -sha256 -sign privatecert.pem | openssl enc -base64 -A | tr +/ -_ | tr -d '=' > output/sign.txt
echo -n "." >> output/client_assertion.txt

echo "adding signature to jwt.."
cat output/sign.txt >> output/client_assertion.txt

echo "[DO THIS NOW] ask the revolut user to Enable on the API key"
read -p "Press any key to continue... " -n1 -s
echo

echo "[DO THIS NOW] ask the revolut user to add '&scope=READ' to the URL"
read -p "Press any key to continue... " -n1 -s
echo

echo "[DO THIS NOW] ask the revolut user click 'Authorize' and send the Authorization Code in query params"
read -p "Press any key to continue... " -n1 -s
echo

read -p "Enter Authorization Code: " AUTH_CODE

CLIENT_JWT=$(<output/client_assertion.txt)
echo "Does this JWT look about right?"
echo $CLIENT_JWT
read -p "Press any key to continue... " -n1 -s
echo

echo "requesting refresh-token..."
RESULT=$(curl https://b2b.revolut.com/api/1.0/auth/token \
  -H "Content-Type: application/x-www-form-urlencoded"\
  --data "grant_type=authorization_code"\
  --data "code=$AUTH_CODE"\
  --data "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer"\
  --data "client_assertion=$CLIENT_JWT")

echo "Got authorization response (should contain refresh_token) - saved in outputs/token.json:"
echo $RESULT | jq
echo $RESULT > output/tokens.json

