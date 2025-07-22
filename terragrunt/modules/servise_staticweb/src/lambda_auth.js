// 環境変数の値を設定
const USER_POOL_ID = '${user_pool_id}';
const CLIENT_ID = '${client_id}';
const COGNITO_DOMAIN = '${cognito_domain}';

const { Authenticator } = require('cognito-at-edge');

const authenticator = new Authenticator({
  // Replace these parameter values with those of your own environment
  region: 'ap-northeast-1', // user pool region
  userPoolId: USER_POOL_ID, // user pool ID
  userPoolAppId: CLIENT_ID, // user pool app client ID
  userPoolDomain: COGNITO_DOMAIN, // user pool domain
});

exports.handler = async (request) => authenticator.handle(request);