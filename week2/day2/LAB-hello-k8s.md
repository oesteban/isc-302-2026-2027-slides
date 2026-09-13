# Lab: Hello World on Kubernetes

Two paths, same commands. **Path A** targets the ISC cluster (Carnaval).
**Path B** runs a cluster on your own laptop. Everything from step 3 onward
is byte-identical between them, which is the point: the manifest does not
know where it is running.

Status as of 2026-09-08: Path B is **verified working**. Path A is
**blocked on a VPN route**, see the planning notes for this day.

---

## 0. Preflight (do this before the session, not during it)

```bash
kubectl version --client        # need a client; 1.32+ is fine
docker info                     # only needed for Path B
```

If `kubectl` is missing: `brew install kubectl` (macOS),
`sudo apt install kubectl` (Debian/Ubuntu), `winget install Kubernetes.kubectl`
(Windows).

---

## Path A: the ISC cluster (Carnaval)

Carnaval runs **k3s**, a single-binary Kubernetes distribution. The API
server is `k8s.isc3:6443`, which is `192.168.91.115` on the ISC internal
network.

### A1. Get on the VPN

The cluster is not on the public internet and not on the HES-SO staff
network either. It sits behind the ISC VPN, which is **NetBird**.

```bash
netbird status              # expect "Management: Connected"
netbird up                  # opens a browser for SWITCH edu-ID SSO
```

The SSO session expires every ~2 days, so expect to redo `netbird up`
most mornings. You must be enrolled on the ISC roster; an edu-ID alone
is not enough.

Check it actually worked, and check **both halves**, because they fail
independently:

```bash
# 1. name resolution
dscacheutil -q host -a name k8s.isc3        # macOS
getent hosts k8s.isc3                       # Linux
#    -> expect 192.168.91.115

# 2. routing (this is the half that silently fails)
nc -z -v -G 5 192.168.91.115 6443
```

If step 1 answers but step 2 times out, DNS reaches you but packets do
not: your NetBird group is missing the route. Check what you are actually
granted with `netbird status --detail` and read the `Networks:` line.

### A2. Point kubectl at the cluster

```bash
export KUBECONFIG=~/.kube/carnaval.kubeconfig
kubectl config get-contexts
kubectl cluster-info
```

Keep the cluster kubeconfig in its **own file** rather than merging it
into `~/.kube/config`. A stray `kubectl delete` in the wrong context is
the classic accident, and separate files make the blast radius visible.

**Never commit a kubeconfig.** It carries a bearer token that is
equivalent to your password on the cluster. This repository's
`.gitignore` covers `*.kubeconfig`, but the habit matters more than the
rule.

### A3. Check what you are allowed to do

```bash
kubectl auth whoami
kubectl auth can-i --list --namespace <your-namespace>
```

Do this **first**, every time, on any cluster you did not build. It turns
a confusing wall of `Forbidden` errors later into one clear answer now.

Then continue at step 3 below.

---

## Path B: a cluster on your laptop

k3d runs the **same k3s** that Carnaval runs, inside Docker containers.
This is not a simulator: it is the same distribution, so what you learn
transfers.

```bash
brew install k3d                                  # or per k3d.io
k3d cluster create hello302 --agents 2 --wait
```

Roughly 30 seconds. `--agents 2` gives you a control plane plus two
worker nodes, so you can watch the scheduler place pods on different
machines. With a single node there is nothing to see.

```bash
kubectl config get-contexts     # k3d switched you to k3d-hello302
kubectl get nodes -o wide
```

Expect three `Ready` nodes.

---

## 3. A namespace of your own

```bash
kubectl create namespace hello-<yourname>
```

A namespace is the unit of separation between students on a shared
cluster: your objects, your quota, your permissions. Get used to passing
`-n` everywhere. To avoid typing it every time:

```bash
kubectl config set-context --current --namespace=hello-<yourname>
```

## 4. Describe what you want

`hello-k8s.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello
  labels: { app: hello }
spec:
  replicas: 2
  selector:
    matchLabels: { app: hello }
  template:
    metadata:
      labels: { app: hello }
    spec:
      containers:
        - name: hello
          image: nginxdemos/nginx-hello:plain-text
          ports:
            - containerPort: 8080
          resources:
            requests: { cpu: "10m",  memory: "16Mi" }
            limits:   { cpu: "200m", memory: "64Mi" }
          securityContext:
            allowPrivilegeEscalation: false
            runAsNonRoot: true
            runAsUser: 101
            capabilities: { drop: ["ALL"] }
---
apiVersion: v1
kind: Service
metadata:
  name: hello
spec:
  selector: { app: hello }
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
```

Three things to notice, because each is a lesson:

- **`replicas: 2` is a wish, not a command.** You declare the desired
  state; a control loop makes reality match it, continuously. This is the
  single idea that separates Kubernetes from `docker run`.
- **`resources.requests` is how the scheduler decides where a pod fits.**
  Without requests the scheduler is guessing, and on a shared cluster a
  missing request is how one student starves everyone else. On Carnaval
  a `ResourceQuota` will make these mandatory.
- **The Service selects by label, not by pod name.** Pods are cattle with
  generated names that change on every restart; the label is the stable
  handle. This indirection is what makes the next two steps possible.

The image is deliberately chosen: `nginxdemos/nginx-hello` prints **which
pod answered**, so load balancing is something students see rather than
something they are told. It is multi-arch (amd64 and arm64), so it works
on Apple Silicon and on the cluster's x86 nodes alike.

## 5. Apply it and watch

```bash
kubectl apply -f hello-k8s.yaml
kubectl rollout status deploy/hello
kubectl get pods -o wide
```

`-o wide` shows the `NODE` column. On a multi-node cluster the two pods
should land on different nodes.

## 6. Prove the Service load-balances

`kubectl port-forward` pins to a single pod, so it cannot show this. Ask
from *inside* the cluster instead:

```bash
kubectl run curler --rm -i --restart=Never --image=curlimages/curl:8.11.1 -- \
  sh -c 'for i in $(seq 1 8); do curl -s http://hello/ | grep "^Server name"; done'
```

Two names alternate. Note the URL is just `http://hello/`: the Service
name is a DNS name inside the cluster, resolved by CoreDNS.

> Do not add `--quiet` to that command. It suppresses the pod output and
> you get an empty result, which looks like a failure and is not.

## 7. Scale

```bash
kubectl scale deploy/hello --replicas=5
kubectl get pods -o wide
```

Re-run step 6 and five names now appear. Nothing was rebuilt, nothing was
redeployed, and the Service picked up the new pods automatically because
they carry the right label.

## 8. Break it on purpose

```bash
kubectl get pods
kubectl delete pod <one-of-them>
kubectl get pods -w        # Ctrl-C to stop watching
```

A replacement appears immediately and is serving within about **7
seconds** (measured on k3d, 2026-09-08). You never asked for a new pod.
The ReplicaSet controller noticed reality drifted from `replicas: 5` and
corrected it. Say the phrase out loud: *this is the control loop*.

```bash
kubectl get events --sort-by=.lastTimestamp | tail -5
```

The events are the controller narrating its own reasoning: `Killing`,
`SuccessfulCreate`, `Pulled`, `Created`, `Started`.

## 9. See it in a browser

```bash
kubectl port-forward svc/hello 8080:80
```

Then open <http://127.0.0.1:8080/>. This works identically on Carnaval and
on k3d, and needs no Ingress, no LoadBalancer and no cluster
configuration, which is exactly why it is the right tool for a lab. It
tunnels over the API server connection you already have.

Refreshing shows the *same* pod each time: `port-forward` picks one pod
and stays with it. That is a feature worth pointing out, right after
step 6 taught the opposite behaviour.

## 10. Clean up

```bash
kubectl delete -f hello-k8s.yaml
kubectl delete namespace hello-<yourname>     # removes everything in it
```

Path B only:

```bash
k3d cluster delete hello302
```

On a shared cluster, cleaning up is not tidiness, it is the quota you are
returning to the next group.

---

## Troubleshooting, in the order these actually happen

| Symptom | Cause | Fix |
|---|---|---|
| `dial tcp: lookup k8s.isc3: no such host` | Not on the VPN | `netbird up` |
| DNS resolves but connection times out | On the VPN, but no route to the API server | `netbird status --detail`, check `Networks:`; ask ISC admins |
| `error: You must be logged in to the server (Unauthorized)` | Token expired | Get a fresh kubeconfig |
| `Forbidden: User cannot list resource` | RBAC; you are outside your namespace | `kubectl auth can-i --list -n <ns>` |
| Pod stuck `Pending` | No node fits the resource requests, or quota exhausted | `kubectl describe pod <name>`, read `Events` |
| Pod stuck `ImagePullBackOff` | Wrong image name, or no registry access from the nodes | `kubectl describe pod <name>` |
| Pod `CrashLoopBackOff` | The container itself exits | `kubectl logs <name> --previous` |
| `exec format error` | Image has no build for the node's CPU architecture | Use a multi-arch image |

The habit to teach, above any individual fix: **`kubectl describe` and
read the `Events` block at the bottom.** It is where Kubernetes explains
itself, and students will not look there unless told to.
