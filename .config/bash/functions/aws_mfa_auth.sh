function aws_mfa_auth() {
  local input_profile="$1"
  local target_aws_profile="${input_profile}-mfa"

  if [ "$input_profile" = "" ]; then
    echo "Provide an input profile as an argument: prod or dev"
    return 1
  fi

  if [[ "$input_profile" != "prod" && "$input_profile" != "dev" ]]; then
    echo "Invalid profile. Use prod or dev."
    return 1
  fi

  local mfa_serial
  mfa_serial=$( aws iam list-mfa-devices --profile "$input_profile" | jq -r '.MFADevices[0].SerialNumber' )

  if [ "$mfa_serial" = "" ]; then
    echo "Failed to fetch MFA Serial."
    return 1
  fi

  echo "Enter MFA code:"
  read -r mfa_code

  local token_json
  token_json=$( \
    aws sts get-session-token \
    --profile "$input_profile" \
    --serial-number="$mfa_serial" \
    --token-code="$mfa_code" \
  )

  if [ "$token_json" = "" ]; then
    echo "Failed to get session token."
    return 1
  fi

  aws configure set \
    "profile.$target_aws_profile.aws_access_key_id" \
    "$( echo "$token_json" | jq -r '.Credentials.AccessKeyId' )" \
    --profile "$target_aws_profile"

  aws configure set \
    "profile.$target_aws_profile.aws_secret_access_key" \
    "$( echo "$token_json" | jq -r '.Credentials.SecretAccessKey' )" \
    --profile "$target_aws_profile"

  aws configure set \
    "profile.$target_aws_profile.aws_session_token" \
    "$( echo "$token_json" | jq -r '.Credentials.SessionToken' )" \
    --profile "$target_aws_profile"

  # Validate that the credentials are set successfully
  if ! aws sts get-caller-identity --profile "$target_aws_profile" > /dev/null 2>&1; then
    echo "Failed to set up MFA authentication."
    return 1
  fi

  export AWS_PROFILE="$target_aws_profile"

  echo
  echo "/=$target_aws_profile ..."
  echo
}
