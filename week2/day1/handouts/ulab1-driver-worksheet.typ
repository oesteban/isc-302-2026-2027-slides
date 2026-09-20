// ---------------------------------------------------------------------------
// ulab1-driver-worksheet.typ — one A4 sheet per group, for µLab 1 of week 2 day 1.
//
// The referee's grid records how the group worked. This records what the group
// produced, and it carries the four steps from the deck so that the answer to
// "what were we supposed to do again?" is on the table rather than on a slide
// that has moved on.
//
// The sheet is cut in two by a checkpoint bar. Everything above it is the core
// and is sized for TEN minutes; everything below is extension work and can take
// another twenty. The bar is deliberately the loudest thing on the page: a
// group that reaches it has solved the challenge, and the referee ticks it
// there and then rather than at the caucus, so nobody is left guessing whether
// they are done.
//
// Committed BLANK and it must stay that way: a filled sheet carries a GitHub
// handle and is personally identifying. It is handed to the teacher at the end
// of the round, never returned, never photographed, and never enters git. See
// the PII doctrine in the repository CLAUDE.md.
//
//   typst compile ulab1-driver-worksheet.typ
//
// Requires the ISC fonts:  source src/fonts/install_fonts.sh
// from https://github.com/ISC-HEI/isc-hei-typst-templates
// ---------------------------------------------------------------------------

#import "@preview/isc-hei-document:0.8.1": *

#show: project.with(
  doc-type: "document",
  show-cover: false,
  show-toc: false,
  fancy-line: true,
  title: "µLab worksheet · Kubernetes in one container",
  subtitle: [302 Data infrastructures · week 2, day 1],
  authors: ("",),
  date: datetime(year: 2026, month: 9, day: 21),
  revision: "1.0",
  language: "en",
  logo: auto,
)

#set text(size: 9pt)
#set heading(numbering: none)

#let accent = rgb("#dc0069")
#let hair = 0.4pt + luma(190)

#let lbl(it, fill: accent) = text(size: 7pt, weight: "bold", tracking: 0.09em, fill: fill, upper(it))

#let rule(w) = box(width: w, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)

#let panel(title, body) = block(
  width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, breakable: false,
  stroke: (top: 1.4pt + accent, rest: hair),
)[
  #lbl(title)
  #v(3pt)
  #body
]

#let panelb(title, body) = block(
  width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, breakable: true,
  stroke: (top: 1.4pt + accent, rest: hair),
)[
  #lbl(title)
  #v(3pt)
  #body
]

#let writing(n) = {
  for _ in range(n) {
    block(width: 100%, height: 15pt, above: 3pt, below: 0pt, stroke: (bottom: hair))[]
  }
}

#let tick = box(width: 8pt, height: 8pt, stroke: 0.6pt + luma(140), radius: 1pt)

#let step(n, title, body) = grid(
  columns: (auto, 1fr), column-gutter: 6pt, align: (top, top),
  text(size: 8pt, weight: "bold", fill: accent)[#n#h(3pt)#tick],
  [#text(size: 8.5pt, weight: "bold")[#title] \ #text(size: 8pt)[#body]],
)

// The one thing on the sheet that must not be missed.
#let checkpoint = block(
  width: 100%, inset: (x: 8pt, y: 7pt), radius: 3pt, breakable: false,
  fill: accent,
)[
  #grid(columns: (auto, 1fr), column-gutter: 9pt, align: (horizon, top),
    box(width: 15pt, height: 15pt, radius: 2pt, fill: white, stroke: 1pt + white),
    [
      #text(size: 9.5pt, weight: "bold", fill: white)[
        Reached this line? Then you have solved the challenge.
      ]
      #v(2pt)
      #text(size: 8.5pt, fill: white)[
        *Referee: tick the box on the left now*, and write the time. Do not wait
        for the caucus. \
        Then carry on below — the extensions are not optional, they are the rest
        of the round.
      ]
      #v(3pt)
      #text(size: 8pt, fill: white)[
        Solved at #box(width: 22mm, stroke: (bottom: 0.6pt + white), height: 9pt)
        #h(10pt) Referee's initials #box(width: 22mm, stroke: (bottom: 0.6pt + white), height: 9pt)
      ]
    ])
]

// ── header ────────────────────────────────────────────────────────────────
#grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 8pt)[Group], rule(100%),
  text(size: 8pt)[Date #rule(20mm) #h(6pt) Time], rule(24mm),
)
#v(6pt)
#grid(columns: (auto, 1fr, auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
  text(size: 8pt)[Driver #text(fill: luma(140))[(types)]], rule(100%),
  text(size: 8pt)[Mapper #text(fill: luma(140))[(looks up)]], rule(100%),
  text(size: 8pt)[Referee #text(fill: luma(140))[(demos)]], rule(100%),
)
#v(5pt)
#text(size: 7.5pt, fill: luma(140), style: "italic")[
  Hand this in at the end of the round. The referee presents this work in 90 seconds
  at the caucus, so the referee has to follow it, not just watch it.
]
#v(5pt)

// ══ CORE — ten minutes ════════════════════════════════════════════════════
#panelb("1 · Start the cluster, then get a client · steps 1 and 2")[
  #step("1", "Create a container that is a Kubernetes cluster")[
    #raw("mkdir kube\ndocker run -d --name k8s --privileged --tmpfs /run --tmpfs /var/run \\\n  -p 6443:6443 -v \"$PWD/kube:/output\" \\\n  rancher/k3s:v1.36.4-k3s1 server --disable=traefik \\\n  --write-kubeconfig /output/config --write-kubeconfig-mode 644", lang: "console")
    #v(3pt)
    #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
      raw("-d"),
      text(size: 7.8pt)[Detached. It runs in the background and you get your prompt back.],
      raw("--name k8s"),
      text(size: 7.8pt)[A name of your choosing. Without it Docker still identifies the container, but by its id:
        #raw("8d7726f96f7475544440565a92a034cda1f767726619081595bab18cfdf76987").
        Every later command would have to carry that, or its short form #raw("8d7726f96f74").],
      raw("--privileged"),
      text(size: 7.8pt)[Lifts the usual restrictions. k3s mounts cgroups and runs *its own* container runtime inside this container.],
      raw("--tmpfs /run"),
      text(size: 7.8pt)[Two small writable in-memory filesystems k3s needs (also #raw("/var/run")).],
      raw("-p 6443:6443"),
      text(size: 7.8pt)[*HOST:CONTAINER.* Port 6443 #emph[on your laptop] is forwarded to 6443 #emph[inside the container]. 6443 is where the cluster's *API server* listens, and step 2 is going to talk to it.],
      raw("-v \"$PWD/kube:/output\""),
      text(size: 7.8pt)[Bind-mounts your new #raw("kube") folder into the container, so a file written there lands on your laptop.],
      raw("rancher/k3s:v1.36.4-k3s1"),
      text(size: 7.8pt)[The image. #raw("rancher/k3s") is the repository, #raw("v1.36.4-k3s1") the tag. You named no registry, so Docker went to *Docker Hub*.],
      raw("server"),
      text(size: 7.8pt)[*Not a docker flag.* Everything after the image name is the command handed to the program inside. #raw("server") tells k3s to be the cluster.],
      raw("--disable=traefik"),
      text(size: 7.8pt)[Also k3s's. Traefik is an *ingress controller*: it routes HTTP arriving from outside to services inside. It claims ports 80 and 443 and adds startup time; nothing today arrives from outside.],
      raw("--write-kubeconfig"),
      text(size: 7.8pt)[Writes the cluster's address and credentials to #raw("/output/config"), which is your #raw("kube/config"). #raw("-mode 644") makes it readable without #raw("sudo").],
    )
    #v(3pt)
    #text(size: 8pt)[
      After a few seconds #raw("kube/config") exists on your laptop. Open it. One line reads
      #raw("server: https://127.0.0.1:6443") — that is the only address anything will need.
    ]
  ]
  #v(5pt)
  #step("2", "Get a kubectl, and point it at that address")[
    #text(size: 8pt)[
      #raw("kubectl") is *not part of the cluster*. It is an ordinary program that sends HTTPS
      requests to the address above, so it can live anywhere. Pick one.
    ]
    #v(4pt)
    #text(size: 8.5pt, weight: "bold")[(a) On Linux — install it on your laptop]
    #v(1pt)
    #raw("sudo snap install kubectl --classic\nexport KUBECONFIG=$PWD/kube/config", lang: "console")
    #v(2pt)
    #text(size: 7.8pt, fill: luma(120))[
      It reaches the cluster through the port you published in step 1. This is exactly how
      you would drive a real cluster from your own machine.
    ]
    #v(4pt)
    #text(size: 8.5pt, weight: "bold")[(b) Anywhere, including macOS and Windows — run kubectl in its own container]
    #v(1pt)
    #raw("docker run --rm -it --network container:k8s \\\n  -v \"$PWD/kube:/kube:ro\" -e KUBECONFIG=/kube/config \\\n  --entrypoint sh alpine/kubectl", lang: "console")
    #v(3pt)
    #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
      raw("--rm"),
      text(size: 7.8pt)[Delete this container the moment you leave it. The cluster in step 1 used #raw("-d") because it must outlive your prompt; this one is disposable and you can start another whenever you like.],
      raw("-it"),
      text(size: 7.8pt)[#raw("-i") keeps the input open, #raw("-t") gives a terminal. Together: an interactive shell instead of a single command.],
      raw("--network container:k8s"),
      text(size: 7.8pt)[Do not give this container its own network — *join the one the cluster container already has*. That is why #raw("127.0.0.1:6443") works in here: it is the cluster's own loopback, which is exactly the address written in #raw("kube/config").],
      raw("-v \"$PWD/kube:/kube:ro\""),
      text(size: 7.8pt)[Bind-mount again, the other way round: your #raw("kube") folder appears inside this container at #raw("/kube"). #raw(":ro") makes it *read-only* — a client has no business editing the cluster's credentials.],
      raw("-e KUBECONFIG=/kube/config"),
      text(size: 7.8pt)[Sets an environment variable inside the container. #raw("kubectl") reads #raw("KUBECONFIG") to find out which cluster to talk to. Note the path is #emph[the one inside this container], not the one on your laptop.],
      raw("--entrypoint sh"),
      text(size: 7.8pt)[Overrides what the image runs by default. #raw("alpine/kubectl") is built to run #raw("kubectl") and nothing else, so without this you would get one command per #raw("docker run"). Swapping in a shell lets you type many.],
      raw("alpine/kubectl"),
      text(size: 7.8pt)[The image: kubectl and a small Alpine base, nothing else. No registry named, so *Docker Hub* again.],
    )
    #v(3pt)
    #text(size: 8pt)[
      Type plain #raw("kubectl") from here. Prove where you are: #raw("command -v k3s") finds
      nothing, because there is no cluster in this container — only a client.
    ]
    #v(4pt)
    #block(width: 100%, inset: (x: 6pt, y: 5pt), radius: 2pt,
           stroke: 1pt + accent, fill: rgb("#fff0f6"))[
      #text(size: 8.5pt, weight: "bold")[Either way, you are outside the cluster.]
      #v(1pt)
      #text(size: 8pt)[
        Nothing from here on is typed *inside* the cluster. That is the normal arrangement:
        the cluster is one thing, the client is another, and they meet over one HTTPS
        address. Which did you pick, (a) or (b)?
        #box(width: 12mm, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)
      ]
    ]
    #v(5pt)
    #text(size: 8.5pt, weight: "bold")[Now check that it reaches the cluster.]
    #v(1pt)
    #text(size: 8pt)[
      #raw("kubectl get nodes") asks the API server for the machines that make up the cluster.
      There will be exactly one: the container you started in step 1. If this prints a table,
      your client found the cluster and everything after this will work.
    ]
    #v(2pt)
    #raw("kubectl get nodes", lang: "console")
    #v(2pt)
    #text(size: 8pt)[Expect something close to:]
    #v(1pt)
    #raw("NAME           STATUS   ROLES           AGE   VERSION\n7c19eb7874a1   Ready    control-plane   11s   v1.36.4+k3s1", lang: "console")
    #v(3pt)
    #text(size: 7.8pt, fill: luma(120))[
      Instead got #raw("The connection to the server localhost:8080 was refused")? Then kubectl
      never found the config and fell back to a built-in default. Check that #raw("kube/config")
      exists and is not empty, and that you are running from the folder that contains #raw("kube").
    ]
  ]
]

#v(5pt)

#panel("2 · Some definitions")[
  #text(size: 8.5pt)[
    Step 1 produced a Kubernetes cluster inside one container. Step 2 produced a
    #raw("kubectl") outside it that can reach the cluster's API. These are the words the
    next four steps use.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 5pt, align: (top, top),

    text(size: 8.5pt, weight: "bold")[kubectl],
    text(size: 8pt)[
      The cluster's command-line client. It runs nothing itself: each command becomes an
      HTTPS request to #raw("https://127.0.0.1:6443"), and the reply is printed. The same
      split as the #raw("docker") command and the Docker daemon — one is typed, the other
      does the work.
    ],

    text(size: 8.5pt, weight: "bold")[pod],
    text(size: 8pt)[
      *A running container, as Kubernetes counts it.* #raw("docker run") produces a
      container; Kubernetes produces a pod, with the container inside it. A pod may hold
      two or three containers that must share a machine and a single IP address; here, each
      holds one. *Pods are never created directly.*
    ],

    text(size: 8.5pt, weight: "bold")[Deployment],
    text(size: 8pt)[
      *A request, in writing.* This one says: #emph[keep three pods of
      #raw("ghcr.io/oesteban/whalesay") running]. Submitting it starts nothing. It records
      what should be true.
    ],

    text(size: 8.5pt, weight: "bold")[controller],
    text(size: 8pt)[
      *The program inside the cluster that makes the request true.* It reads the Deployment
      (three wanted), counts the pods that exist (two), starts one. A second later it counts
      again, and it never stops counting. \
      Hence a deleted pod reappears: the pod was removed, the request was not.
    ],

    text(size: 8.5pt, weight: "bold")[Job],
    text(size: 8pt)[
      *A different request:* #emph[run this image once, until it finishes]. Its controller
      starts one pod, waits for a successful exit, and stops. Nothing is replaced.
    ],
  )
  #v(5pt)
  #block(width: 100%, inset: (x: 6pt, y: 5pt), radius: 2pt, fill: luma(245))[
    #text(size: 8pt)[
      One more, because it appears on screen: *CrashLoopBackOff*. The whale prints and exits,
      so the controller starts it again. The interval grows — 10s, then 20s, then 40s,
      doubling to a five-minute ceiling — and during the wait, this is the status shown. It
      does *not* mean the container crashed. It means #emph[stopped again, waiting before
      the next attempt].
    ]
  ]
]

#panelb("3 · Drive the cluster · steps 3 to 6")[
  #text(size: 8.5pt, weight: "bold", fill: accent)[
    Type these with the kubectl you set up in step 2.
  ]
  #v(4pt)
  #step("3", "Ask the cluster to keep a whale running")[
    #raw("kubectl create deployment whale --image=ghcr.io/oesteban/whalesay --replicas=3", lang: "console")
    #v(1pt)
    #text(size: 8pt)[
      A *Deployment* says: this many of these should exist, at all times. You do not
      say when to start anything.
    ]
    #v(3pt)
    #text(size: 8pt, weight: "bold")[Why is the registry spelled out here, when step 1 named none?]
    #v(1pt)
    #text(size: 8pt)[
      Because there are two copies of this image and they are *not the same thing*.
      Run these two #emph[on your laptop], not in the cluster shell:
    ]
    #v(2pt)
    #raw("docker buildx imagetools inspect ghcr.io/oesteban/whalesay
docker buildx imagetools inspect oesteban/whalesay", lang: "console")
    #v(2pt)
    #text(size: 8pt)[
      The first prints a #raw("Manifests:") list with #raw("Platform: linux/amd64") *and*
      #raw("Platform: linux/arm64"). The second prints no list at all: it is a single image,
      #raw("linux/amd64") only.
    ]
    #v(2pt)
    #text(size: 8pt)[
      An Apple Silicon Mac runs an *arm64* Linux VM, and k3s's containerd has no emulation
      to fall back on. The Docker Hub copy would give #raw("exec format error") and the pod
      would never start. The GHCR copy was built for both by GitHub Actions on Friday.
    ]
    #v(3pt)
    #text(size: 8pt, fill: luma(90))[
      *On Linux or Windows, on Intel or AMD:* the Docker Hub copy runs perfectly well.
      Check the manifests above, then try it alongside:
      #raw("kubectl create deployment hub --image=oesteban/whalesay --replicas=1", lang: "console")
      Which architecture is your laptop? #box(width: 30mm, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)
    ]
  ]
  #v(4pt)
  #step("4", "Look at the pods the controller made for you")[
    #raw("kubectl get pods", lang: "console") — once straight away, once about a minute later.
    #v(1pt)
    #text(size: 8pt)[
      This lists the *pods* the Deployment created on your behalf. Two columns
      matter: *STATUS*, what the pod is doing right now, and *RESTARTS*, how many
      times the container inside it has been started again.
    ]
    #v(2pt)
    #text(size: 7.8pt, fill: luma(120))[
      Take both readings in the *first two minutes*. The retries slow down as they go
      (see #emph[CrashLoopBackOff] in block 2), so two late readings can show the same
      number and tell you nothing.
    ]
  ]
  #v(4pt)
  #step("5", "Ask for the same image to run once, instead of forever")[
    #raw("kubectl create job whale --image=ghcr.io/oesteban/whalesay -- cowsay 'a cluster ran me'", lang: "console")
    #v(1pt)
    #text(size: 8pt)[
      A *Job* says: run this to completion, once. Same image, same cluster, same
      command — only the kind of object is different.
    ]
  ]
  #v(4pt)
  #step("6", "Read what it printed")[
    #raw("kubectl logs job/whale", lang: "console")
    #v(1pt)
    #text(size: 8pt)[
      #raw("kubectl logs") prints whatever a container wrote to its output. You did not
      have to find the pod: naming the Job was enough.
    ]
  ]
]

#v(5pt)

#panel("4 · What you started")[
  #text(size: 8.5pt)[From #raw("kubectl get nodes"):]
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[NAME], rule(100%),
    text(size: 8pt)[VERSION], rule(100%),
    text(size: 8pt)[STATUS], rule(100%),
    text(size: 8pt)[AGE when first Ready], rule(100%),
  )
]

#v(5pt)

#panel("5 · The two readings, and the reason")[
  #grid(columns: (1fr, 1fr), column-gutter: 10pt,
    [
      #text(size: 8pt, weight: "bold")[First reading]
      #v(2pt)
      #grid(columns: (auto, 1fr), column-gutter: 5pt, row-gutter: 6pt, align: bottom,
        text(size: 8pt)[STATUS], rule(100%),
        text(size: 8pt)[RESTARTS], rule(100%),
      )
    ],
    [
      #text(size: 8pt, weight: "bold")[A minute later]
      #v(2pt)
      #grid(columns: (auto, 1fr), column-gutter: 5pt, row-gutter: 6pt, align: bottom,
        text(size: 8pt)[STATUS], rule(100%),
        text(size: 8pt)[RESTARTS], rule(100%),
      )
    ])
  #v(6pt)
  #text(size: 8.5pt)[
    Run #raw("docker ps") on your laptop: compare CONTAINER ID with the NAME in panel 4. \
The container did not crash. It printed its whale and exited *successfully*.
    So why is Kubernetes starting it again?
  ]
  #writing(2)
  #v(4pt)
  #text(size: 8.5pt)[
    The Job in step 5 used *the same image* and did not do this. What did you
    change, in one sentence?
  ]
  #writing(2)
  #v(5pt)
  #block(width: 100%, inset: (x: 6pt, y: 5pt), radius: 2pt,
         stroke: 1pt + accent, fill: rgb("#fff0f6"))[
    #text(size: 8.5pt, weight: "bold")[Then read what Kubernetes actually claims.]
    #v(1pt)
    #text(size: 8pt)[
      #raw("kubectl describe pod <one of them>", lang: "console") and find the block called
      *Last State*.
    ]
    #v(3pt)
    #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
      text(size: 8pt)[Exit Code], rule(100%),
      text(size: 8pt)[Reason], rule(100%),
    )
    #v(4pt)
    #text(size: 8pt)[
      Now read the message beside *State: Waiting*. It contains the words
      #raw("restarting failed container"). \
      *Was it a failure?* Reconcile those two lines, in one sentence.
    ]
    #writing(2)
  ]
]

#v(5pt)

#panel("6 · What the logs will tell you")[
  #text(size: 8.5pt)[
    Logs are the first place you look when something is wrong, and they are not
    only for things that are wrong. Try all four, inside the cluster.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 5pt, align: (top, top),
    raw("kubectl logs deploy/whale"),
    text(size: 8pt)[There are three pods. Which one did it pick, and how do you know?],
    raw("kubectl logs <pod> --previous"),
    text(size: 8pt)[The container that *already died*. Why would that ever be the only copy left?],
    raw("kubectl logs -l app=whale --prefix"),
    text(size: 8pt)[All three at once. What does the prefix tell you?],
    raw("kubectl logs <pod> --timestamps"),
    text(size: 8pt)[Now you can see *when*. How far apart are the restarts?],
  )
  #v(5pt)
  #text(size: 8.5pt)[
    A pod is gone and you want to know why. Which of those four do you reach for,
    and what would you have lost if you had waited an hour?
  ]
  #writing(2)
]

#v(6pt)

#checkpoint

#v(8pt)

// ══ EXTENSIONS — up to twenty minutes ═════════════════════════════════════
#panelb("7 · Now use the image you built on Friday")[
  #text(size: 8.5pt)[
    Everything so far ran *someone else's* image. Repeat step 2 with your own, the
    one your GitHub Actions workflow published on Friday:
  ]
  #v(2pt)
  #raw("kubectl create deployment mine --image=ghcr.io/<your-handle>/whalesay", lang: "console")
  #v(3pt)
  #text(size: 8pt)[
    Your handle #box(width: 45mm, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)
    #h(8pt) Did it pull? #box(width: 20mm, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)
  ]
  #v(5pt)
  #text(size: 8.5pt)[
    If it did not, #raw("kubectl describe pod") will name the reason. Write it down,
    then fix it.
  ]
  #writing(2)
  #v(4pt)
  #text(size: 8.5pt)[
    Nobody told the cluster where #raw("ghcr.io") is, and nobody gave it a password.
    So: what *is* a registry, and what had to be true of your package for this to
    work at all?
  ]
  #writing(3)
  #v(4pt)
  #text(size: 8.5pt)[
    On Friday you pushed to *GHCR*. When you type #raw("docker pull alpine") you get
    an image from *Docker Hub*, and you never type a registry name. Where did that
    default come from, and what is the full name your #raw("alpine") actually has?
  ]
  #writing(2)
]

#v(6pt)

#panel("8 · The controller's own account")[
  #text(size: 8.5pt)[
    In panel 5 you read *Last State* from #raw("kubectl describe pod"). The same output ends
    with an *Events* block. Read it, then widen to the whole cluster:
  ]
  #v(2pt)
  #raw("kubectl get events --sort-by=.lastTimestamp | tail -8", lang: "console")
  #v(4pt)
  #text(size: 8.5pt)[
    Nobody wrote this log. Who did, and what is it a record of — what you asked for,
    or what the cluster did about it?
  ]
  #writing(2)
]

#v(6pt)

#panel("9 · Two image stores, one name")[
  #text(size: 8.5pt)[
    Inside the cluster: #raw("crictl images", lang: "console"). \
    On your laptop, in another terminal: #raw("docker images", lang: "console").
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[whalesay in #raw("crictl")?], rule(100%),
    text(size: 8pt)[in #raw("docker")?], rule(100%),
  )
  #v(6pt)
  #text(size: 8.5pt)[
    Nobody copied anything from your laptop into the cluster. So how did the image
    get there?
  ]
  #writing(2)
]

#v(6pt)

#panel("10 · A wish is not a command")[
  #text(size: 8.5pt)[
    #raw("kubectl scale deployment whale --replicas=5", lang: "console"), wait, then
    #raw("kubectl scale deployment whale --replicas=0", lang: "console"). Count the pods after each.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[pods at 5], rule(100%),
    text(size: 8pt)[pods at 0], rule(100%),
  )
  #v(6pt)
  #text(size: 8.5pt)[
    Now delete the *Job's* pod: #raw("kubectl delete pod <the job pod>", lang: "console").
    Does it come back? Does a Deployment's pod come back? Why are the answers different?
  ]
  #writing(2)
]

#v(6pt)

#panel("11 · Extra mile · satisfy the Deployment instead of abandoning it")[
  #text(size: 8.5pt)[
    In step 5 you stopped the restarting by changing the *object*. There is a
    second way that leaves it a Deployment: same image, no rebuild, no re-push,
    sitting at #raw("RESTARTS 0") and #raw("Running"). Write the command.
  ]
  #writing(2)
  #v(3pt)
  #text(size: 8.5pt)[
    You have now satisfied a Deployment two ways. Which would you use for a web
    server, and which for a nightly report?
  ]
  #writing(2)
  #v(3pt)
  #text(size: 7.5pt, fill: luma(130))[
    No hint. The image runs one program and then stops; nothing says it has to.
  ]
]

#v(8pt)
#align(center)[
  #text(size: 8pt, fill: luma(130), style: "italic")[
    Done when the referee can say, without reading this sheet, why the same image
    restarts forever as a Deployment and finishes as a Job.
  ]
]
