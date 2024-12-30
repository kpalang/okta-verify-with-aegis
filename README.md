# Using Okta 2FA with regular authenticator apps

This repo is a POC to use Okta's `oktaverify` protocol with other authenticator apps. My need was for [Aegis](https://getaegis.app/).

> [!IMPORTANT]
> Based on [this Gist](https://gist.github.com/kamilhism/9f6f26ce3e10b6685af8c43f33aca808) by [Kamil Hismatullin](https://gist.github.com/kamilhism)

## Requirements
1. [trurl](https://github.com/curl/trurl)
2. [qrencode](https://github.com/fukuchi/libqrencode)
3. [zbar](https://github.com/mchehab/zbar)
4. [jq](https://jqlang.github.io/jq/)

* Arch: `sudo pacman -Syu trurl qrencode zbar jq`
* Fedora: `sudo dnf install trurl qrencode zbar jq`
* Ubuntu: `sudo apt install trurl qrencode zbar-tools jq`

## Usage

1. Get your Okta QR Code in Okta Settings: https://<okta-domain>.okta.com/enduser/settings
![Add authenticator](/images/add_authenticator.png)
![Set up](/images/setup_verification.png)
2. Take a screenshot of roughly the area marked with the red rectangle
![QR Code](/images/qr_code.png)
3. Save the screenshot somewhere next to the `generate.sh` script
4. Generate a new QR Code that Aegis can read
   - Usage: `./generate.sh <path/to/qr.png> <okta-domain> <issuer>`
   - Example `./generate.sh ./qr-png your-org "Something to identify in authenticator"`

5. Scan the resulting QR Code in your authenticator
6. Test logging in to Okta with the new code
7. ??? 
8. Profit

## Cleanup
1. ```./clean.sh```