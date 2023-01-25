import 'dart:convert';

String amplifyconfig = jsonEncode({
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "IdentityManager": {"Default": {}},
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {
              "PoolId": "us-west-2:69536ea7-481a-41db-b26f-4d7dd4ab7957",
              "Region": "us-west-2"
            }
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-west-2_01flwXB0J",
            "AppClientId": "52e6ndjldi49mdn4ujnfo4c6ju",
            "Region": "us-west-2"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "OAuth": {
              "WebDomain": "auth.navalport.com",
              "AppClientId": "113atadbf2h443868g85ud56lp", //possible bug
              "SignInRedirectURI": "neptune://",
              "SignOutRedirectURI": "neptune://",
              "Scopes": [
                "phone",
                "email",
                "openid",
                "profile",
                "aws.cognito.signin.user.admin"
              ]
            }
          }
        }
      }
    },
    "IdentityManager": {"Default": {}},
    "AppSync": {
      "Default": {
        "ApiUrl":
            "https://xfndlme62zdydgiyh6x5ip6564.appsync-api.us-west-2.amazonaws.com/graphql",
        "Region": "us-west-2",
        "AuthMode": "AMAZON_COGNITO_USER_POOLS",
        "ClientDatabasePrefix": "npsns_API_KEY"
      }
    }
  }
});
