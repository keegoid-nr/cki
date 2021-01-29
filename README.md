# cki

**Collect Kubernetes Info**

Assist in troubleshooting Kubernetes clusters.

The following cURL or Wget commands will download and run a script which will collect cluster info, resources at the cluster level, and resources from within the specified namespace.

```
bash -c "$(curl -s https://raw.githubusercontent.com/keegoid-nr/cki/v0.3/cki.sh)"
```

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/keegoid-nr/cki/v0.3/cki.sh)"
```

Any resources your Kubernetes user does not have access to will be skipped.

---

*Special thanks to [NVM](https://github.com/nvm-sh/nvm) for inspiration.*
