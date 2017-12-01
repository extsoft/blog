---
layout: post
title: "Enabling Touch ID for sudo"
description: "How to use Touch ID with sudo."
tags: [mac, tips & tricks, bookmark]
link: https://twitter.com/cabel/status/931292107372838912
comments: true
---
Add `auth sufficient pam_tid.so` to the top of `/etc/pam.d/sudo` and enjoy!
