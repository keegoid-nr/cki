#!/bin/bash
sha512sum cki.sh > SHA512SUMS
gpg --detach-sign --armor SHA512SUMS
gpg --keyid-format long --verify SHA512SUMS.asc SHA512SUMS
sha512sum -c SHA512SUMS