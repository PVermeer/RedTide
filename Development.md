# Local image build and test

## Prepare VM Silverblue
```sh
sudo nano /etc/containers/registries.conf
```
Add
```toml
[[registry]]
location = "localhost:5000"
insecure = true
```
## Podman

### Run local registery for rebase / update
```sh
podman container run -dt -p 5000:5000 --name registry docker.io/library/registry:2

# Or start if already installed
podman container start registry
```
### Build and push image to registry
```sh
podman build --pull -f ./Containerfile -t localhost:5000/redtide:latest .

podman push --format=oci localhost:5000/redtide:latest
```

## Rebase / update
```sh
rpm-ostree rebase ostree-unverified-registry:localhost:5000/redtide:latest

# Or upgrade if already rebased
rpm-ostree upgrade
```
