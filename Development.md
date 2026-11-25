# Local image build and test

## Prepare config

On host and VM

```sh
sudo mkdir -p /etc/containers/registries.conf.d
sudo nano /etc/containers/registries.conf.d/redtide-dev.conf
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
podman container run -dt -p 0.0.0.0:5000:5000 --name registry docker.io/library/registry:dev
```

Or start if already installed

```sh
podman container start registry
```

### Build and push image to registry

```sh
podman build --pull -f ./Containerfile -t localhost:5000/redtide-dev:dev .

podman push localhost:5000/redtide-dev:dev
```

## Rebase / update

```sh
rpm-ostree rebase ostree-unverified-registry:<host-ip or localhost>:5000/redtide-dev:dev
```

Or upgrade if already rebased (registry must be running on host)

```sh
rpm-ostree upgrade
```

## Cleanup

```sh
podman system prune -af
```

## Test local VM with secure and signed image

This requires the image to be build with `./scripts/build-image.sh --sign`

1. Generate keys

   ```sh
   ./scripts/generate-ostree-keys.sh
   ```

2. Copy public key `ostree-redtide-public.key` to VM `/etc/ostree/remotes.d`

3. Add remote config to ostree

   ```sh
   sudo ostree remote add \
       --no-gpg-verify \
       --sign-verify=ed25519=file:/etc/ostree/remotes.d/ostree-redtide-public.key \
       redtide-dev \
       http://<host-ip or localhost>:5000
   ```

4. Rebase to secure remote

   ```sh
   sudo rpm-ostree rebase ostree-remote-registry:redtide-dev:<host-ip or localhost>:5000/redtide-dev:dev

   ```
