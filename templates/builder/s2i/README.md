# Installation procedure in OpenShift clusters without local docker install

## Creating the installer image

Create a base image that contains ubi8 or ubi9 base image and add proc-ps and gunzip for the installer. Use the Dockerfile under /installer folder as a template. You need to download the linux IBM webMethods Installer with your Entitlement key from IBM fix Central and place this inside the s2i folder.

## Trigger creation of a buildconfig via oc cli

oc new build config wm-installer --binary

Configure any PROXY settings if necessary:

oc set env bc/wm-installer HTTPS_PROXY=https://myproxy:2222
oc set env bc/wm-installer NO_PROXY=xxx.com,yyy.com

## Trigger build from local directory

oc start-build bc/wm-installer --from=.

This will stream anything from your current working dir to OpenShift and trigger a build using the Dockerfile. With the Installer image we can now trigger a Multistage build that 

## 