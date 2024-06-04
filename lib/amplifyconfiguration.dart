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
            "Default": {"PoolId": "us-west-2:69536ea7-481a-41db-b26f-4d7dd4ab7957", "Region": "us-west-2"}
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-west-2_01flwXB0J",
            "AppClientId": "113atadbf2h443868g85ud56lp",
            "Region": "us-west-2"
          }
        },
        // "Auth": {
        //   "Default": {
        //     "authenticationFlowType": "USER_SRP_AUTH",
        //     "OAuth": {
        //       "WebDomain": "auth.navalport.com",
        //       "AppClientId": "113atadbf2h443868g85ud56lp", //possible bug
        //       "SignInRedirectURI": "mooringapp://",
        //       "SignOutRedirectURI": "mooringapp://",
        //       "Scopes": ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
        //     }
        //   }
        // }
      }
    },
    // "IdentityManager": {"Default": {}},
  }
});
