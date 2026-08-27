# Local image build and test

## Prepare config
On host and VM
```sh
sudo nano /etc/containers/registries.conf
```
Add
```toml
[[registry]]
location = "<host-ip or localhost>:5000"
insecure = true
```
If on remote / VM host-ip is:
```sh
ip route | grep default | awk '{print $3}'
```

## Podman

### Run local registery for rebase / update
```sh
podman container run -dt -p 0.0.0.0:5000:5000 --name registry docker.io/li
brary/registry:2
```

Or start if already installed
```sh
podman container start registry
```
### Build and push image to registry
```sh
podman build --pull -f ./Containerfile -t localhost:5000/redtide:latest .

podman push --format=oci localhost:5000/redtide:latest
```

## Rebase / update
```sh
rpm-ostree rebase ostree-unverified-registry:<host-ip or localhost>:5000/redtide:latest
```

Or upgrade if already rebased (registry must be running on host)
```sh
rpm-ostree upgrade
```

## Cleanup
```sh
podman system prune -af
```
