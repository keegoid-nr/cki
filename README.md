# cki

**Collect Kubernetes Info**

Assist in troubleshooting Kubernetes clusters.

The following cURL or Wget commands will download and run a script which will collect cluster info, resources at the cluster level, and resources from within the specified namespace.

```
nspace=<SET_YOUR_NAMESPACE_HERE>; curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
```

```
nspace=<SET_YOUR_NAMESPACE_HERE>; wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
```

Any resources your Kubernetes user does not have access to will be skipped.

---

*Special thanks to [NVM](https://github.com/nvm-sh/nvm) for inspiration.*
