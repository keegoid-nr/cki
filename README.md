# cki

**Collect Kubernetes Info**

Assist in troubleshooting Kubernetes clusters.

The following cURL or Wget commands will download and run a script which will collect cluster info, resources at the cluster level, and resources from within the specified namespace.

```
<<<<<<< HEAD
curl -o- https://raw.githubusercontent.com/keegoid-nr/cki/v0.2/cki.sh | bash
```

```
wget -qO- https://raw.githubusercontent.com/keegoid-nr/cki/v0.2/cki.sh | bash
=======
curl -o- https://raw.githubusercontent.com/keegoid-nr/cki/v0.6/cki.sh | bash
```

```
wget -qO- https://raw.githubusercontent.com/keegoid-nr/cki/v0.6/cki.sh | bash
>>>>>>> dda46da7fd4de917064c8d23e8a7daf5ed12e17c
```

Any resources your Kubernetes user does not have access to will be skipped.

---

*Special thanks to [NVM](https://github.com/nvm-sh/nvm) for inspiration.*
