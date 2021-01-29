# cki

**Collect Kubernetes Info**

Assist in troubleshooting Kubernetes clusters.

The following cURL or Wget commands will download and run a script which will collect cluster info, resources at the cluster level, and resources from within the specified namespace.

```
NSPACE=<SET_YOUR_NAMESPACE_HERE>
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/keegoid-nr/cki/v0.2/cki.sh | bash
```

```
NSPACE=<SET_YOUR_NAMESPACE_HERE>
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/keegoid-nr/cki/v0.2/cki.sh | bash
```

Any resources your Kubernetes user does not have access to will be skipped.

---

*Special thanks to [NVM](https://github.com/nvm-sh/nvm) for inspiration.*
