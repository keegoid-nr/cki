# cki

**Collect Kubernetes Info**

Assist in troubleshooting Kubernetes clusters.

## Run

The following cURL or Wget commands will download and run a script which will collect cluster info, resources at the cluster level, and resources from within the specified namespace.

```
bash -c "$(curl -s https://raw.githubusercontent.com/keegoid-nr/cki/v0.7/cki.sh)"
```

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/keegoid-nr/cki/v0.7/cki.sh)"
```

Any resources your Kubernetes user does not have access to will be skipped.

## Verify PGP Key

You can download the latest releases [here](https://github.com/keegoid-nr/cki/releases). The `cki.sh` file and its checksum are signed and can be verified against the developer's [public PGP key](https://raw.githubusercontent.com/keegoid-nr/cki/main/kmullaney.asc).

Verify that the fingerprint for the downloaded key matches the following:

```
gpg --fingerprint kmullaney@newrelic.com
E67B C11C D9B3 EC3B 81B7  0C35 68BF EBFB 3C1B 8D5A
```

When verifying the checksum, use the long format (the short format is not secure). For example:

```
gpg --keyid-format long --verify SHA512SUMS.gpg SHA512SUMS
```

---

*Special thanks to [NVM](https://github.com/nvm-sh/nvm) for inspiration.*
