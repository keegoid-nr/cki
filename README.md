# cki

**Collect Kubernetes Info**

Assist in troubleshooting Kubernetes clusters.

The following cURL or Wget commands will download and run a script which will collect cluster info, resources at the cluster level, and resources from within the specified namespace.

```
NSPACE=<SET_YOUR_NAMESPACE_HERE>
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
curl -o- https://raw.githubusercontent.com/keegoid-nr/cki/v0.2/cki.sh | bash
=======
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
>>>>>>> b7611da... adjust formatting
=======
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/keegoid-nr/cki/v0.2/cki.sh | bash
>>>>>>> 6444915... fix url
=======
curl -o- https://raw.githubusercontent.com/keegoid-nr/cki/v0.2/cki.sh | bash
>>>>>>> 83eae7d... fix url
=======
curl -o- https://raw.githubusercontent.com/keegoid-nr/cki/v0.3/cki.sh | bash
>>>>>>> ec7da41... test tags
=======
curl -o- https://raw.githubusercontent.com/keegoid-nr/cki/v0.4/cki.sh | bash
>>>>>>> ae47218... bump version to match tag
```

```
NSPACE=<SET_YOUR_NAMESPACE_HERE>
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
wget -qO- https://raw.githubusercontent.com/keegoid-nr/cki/v0.2/cki.sh | bash
=======
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
>>>>>>> b7611da... adjust formatting
=======
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/keegoid-nr/cki/v0.2/cki.sh | bash
>>>>>>> 6444915... fix url
=======
wget -qO- https://raw.githubusercontent.com/keegoid-nr/cki/v0.2/cki.sh | bash
>>>>>>> 83eae7d... fix url
=======
wget -qO- https://raw.githubusercontent.com/keegoid-nr/cki/v0.3/cki.sh | bash
>>>>>>> ec7da41... test tags
=======
wget -qO- https://raw.githubusercontent.com/keegoid-nr/cki/v0.4/cki.sh | bash
>>>>>>> ae47218... bump version to match tag
```

Any resources your Kubernetes user does not have access to will be skipped.

---

*Special thanks to [NVM](https://github.com/nvm-sh/nvm) for inspiration.*
