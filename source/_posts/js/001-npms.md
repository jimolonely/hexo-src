---
title: npm's problem
tags:
  - npm
  - javascript
p: js/001-npms
date: 2018-07-22 10:04:03
---

# How to Prevent Permissions Errors

[How to Prevent Permissions Errors](https://docs.npmjs.com/getting-started/fixing-npm-permissions)

1. Back-up your computer before you start.

2. Make a directory for global installations:
```
 mkdir ~/.npm-global
```
3. Configure npm to use the new directory path:
```
 npm config set prefix '~/.npm-global'
```
4. Open or create a ~/.profile file and add this line:
```
 export PATH=~/.npm-global/bin:$PATH
```
5. Back on the command line, update your system variables:
```
 source ~/.profile
```
6. Test: Download a package globally without using sudo.
```
    npm install -g jshint
```
