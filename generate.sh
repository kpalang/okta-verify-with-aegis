#!/bin/bash

# Check for requirements
if ! command -v "trurl" > /dev/null; then
  echo "trurl not found. Get the latest release here https://github.com/curl/trurl"
  exit 1
fi

if ! command -v "qrencode" > /dev/null; then
  echo "qrencode not found. Get the latest release here https://github.com/fukuchi/libqrencode"
  exit 1
fi

if ! command -v "zbarimg" > /dev/null; then
  echo "zbarimg not found. Get the latest release here https://github.com/mchehab/zbar"
  exit 1
fi


if ! command -v "jq" > /dev/null; then
  echo "jq not found. Get the latest release here https://jqlang.github.io/jq/"
  exit 1
fi

###

qr_img=$1
domain=$2
issuer=$(echo "$3" | perl -MURI::Escape -ne 'chomp($_); print uri_escape($_)')
url=$(zbarimg -q --raw $qr_img)

url_decoded=$(echo $url | perl -MURI::Escape -ne 'print uri_unescape($_)')

email=$(echo $url_decoded | trurl --url-file - -g '{host}')
authorization=$(echo $url_decoded | trurl --url-file - -g '{query:t}')
authenticatorId=$(echo $url_decoded | trurl --url-file - -g '{query:f}')

display_name="Aegis"

payload=$(cat <<EOF
{
	"authenticatorId": "$authenticatorId",
	"device": {
		"clientInstanceBundleId": "com.okta.android.auth",
		"clientInstanceDeviceSdkVersion": "DeviceSDK 0.19.0",
		"clientInstanceVersion": "6.8.1",
		"clientInstanceKey": {
			"alg": "RS256",
			"e": "AQAB",
			"okta:isFipsCompliant": false,
			"okta:kpr": "SOFTWARE",
			"kty": "RSA",
			"use": "sig",
			"kid": "OpSRC6wLx4oPnqGBUuLz-WL7_knbK_UhClzjvt1cpOw",
			"n": "u0Y1ygDJ61AghDiEqeGW7lCv4iW2gLOON0Aw-Tm53xQW7qB94MUNVjua8KuYyxS-1pxf58u0pCpVhQxSgZJGht5Z7Gmc0geVuxRza3B_TFLd90SFlEdE3te6IkH28MqDu2rQtonYowVedHXZpOii6QBLPjqP6Zm3zx9r7WokpSvY9fnp8zjixuAUuA0XYhv6EwedfvSiz3t84N-nV0R1cN5Ni8os6sG4K6F8ZSr7E4aXTzvOfJIWa9MC1Lx_J4M7HIUuUH7LV7PN_h5yYk8b-2fW4g3_3h13mQ-blx2qMXclr6uuBc13tLLks7LzY3S34y2K060gHMMWCM4MQ77Mrw"
		},
		"deviceAttestation": {},
		"displayName": "$display_name",
		"fullDiskEncryption": false,
		"isHardwareProtectionEnabled": false,
		"manufacturer": "unknown",
		"model": "Google",
		"osVersion": "25",
		"platform": "ANDROID",
		"rootPrivileges": true,
		"screenLock": false,
		"secureHardwarePresent": false
	},
	"key": "okta_verify",
	"methods": [
		{
			"isFipsCompliant": false,
			"supportUserVerification": false,
			"type": "totp"
		}
	]
}
EOF
)

curl --request POST \
  --url "https://$domain.okta.com/idp/authenticators" \
  --header 'Accept: application/json; charset=UTF-8' \
  --header 'Accept-Encoding: gzip, deflate' \
  --header "Authorization: OTDT $authorization" \
  --header 'Content-Type: application/json; charset=UTF-8' \
  --header 'User-Agent: D2DD7D3915.com.okta.android.auth/6.8.1 DeviceSDK/0.19.0 Android/7.1.1 unknown/Google' \
  --data "$payload" \
  > response.txt

jq -r '.methods[0].sharedSecret' response.txt > secret.txt
secret=$(cat secret.txt)

echo "otpauth://totp/$email?secret=$secret&issuer=$issuer" > authUrl.txt
qrencode -l H -t utf8 $(cat authUrl.txt)
