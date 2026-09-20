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
      From this prompt, commands are typed as plain #raw("kubectl"), with no #raw("docker")
      in front.
    ]
    #v(3pt)
    #text(size: 8pt)[
      There are now *two containers running*, and a second terminal shows both:
    ]
    #v(2pt)
    #raw("docker ps
NAMES    IMAGE                       STATUS
client   alpine/kubectl              Up 2 seconds
k8s      rancher/k3s:v1.36.4-k3s1    Up 4 minutes", lang: "console")
    #v(2pt)
    #text(size: 8pt)[
      One is the cluster, one is the client. Leaving the client stops only the client:
      #raw("--rm") deletes it, and the cluster carries on without it.
    ]
    #v(4pt)
    #block(width: 100%, inset: (x: 6pt, y: 5pt), radius: 2pt,
           stroke: 1pt + accent, fill: rgb("#fff0f6"))[
      #text(size: 8.5pt, weight: "bold")[Either way, you are outside the cluster.]
      #v(1pt)
      #text(size: 8pt)[
        Nothing from here on is typed *inside* the cluster. The cluster is one program and
        the client is another, and the only thing joining them is the address in
        #raw("kube/config"). Which did you pick, (a) or (b)?
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
    #v(5pt)
    #text(size: 8.5pt, weight: "bold")[Write down what that table said.]
    #v(1pt)
    #text(size: 8pt)[
      This is the cluster from step 1, described by the cluster itself. The figures come back
      in panel 4.
    ]
    #v(3pt)
    #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
      text(size: 8pt)[NAME], rule(100%),
      text(size: 8pt)[VERSION], rule(100%),
      text(size: 8pt)[STATUS], rule(100%),
      text(size: 8pt)[AGE], rule(100%),
    )
  ]
]

#v(5pt)

#panel("2 · Some definitions")[
  #text(size: 8.5pt)[
    Step 1 produced a Kubernetes cluster inside one container. Step 2 produced a
    #raw("kubectl") outside it that can reach the cluster's API. Steps 3 to 6 use the words
    below.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 5pt, align: (top, top),

    text(size: 8.5pt, weight: "bold")[kubectl],
    text(size: 8pt)[
      The cluster's command-line client. It runs nothing itself: every command becomes an
      authenticated HTTPS request to the cluster's API, and the reply is printed. \
      On an HPC cluster running *Slurm*, work is submitted by first logging in to a *login
      node* and running #raw("sbatch") there. Kubernetes has no login node. #raw("kubectl")
      carries the credentials from #raw("kube/config") and authenticates each request on its
      own, so the machine it runs on is doing the login node's job.
    ],

    text(size: 8.5pt, weight: "bold")[pod],
    text(size: 8pt)[
      *A running container, as Kubernetes counts it.* #raw("docker run") produces a
      container; Kubernetes produces a pod, with the container inside it. A pod may hold
      several containers that have to share one machine and one IP address, but holding a
      single container is the ordinary case. *Pods are never created directly.*
    ],

    text(size: 8.5pt, weight: "bold")[Deployment],
    text(size: 8pt)[
      *A written request, stored by the cluster,* of the form #emph[keep N pods of image X
      running]. Creating one starts no container: the request is sent, the cluster saves it,
      and the command returns. The pods appear a moment later, started by something else. \
      Why request it rather than start it? On a real cluster there are many machines, and
      picking one by hand would mean tracking which has room. Worse, machines and processes
      fail: a container started by hand stays dead, while a request that is stored can go on
      being satisfied after the failure.
    ],

    text(size: 8.5pt, weight: "bold")[controller],
    text(size: 8pt)[
      *A program inside the cluster that reads the stored requests and changes the cluster
      until they are met.* Take a Deployment that says three pods. The controller counts the
      pods that exist. Two, so it starts one. Four, and it would stop one. Then it counts
      again, and it keeps counting for as long as the request is stored. \
      This is why a deleted pod comes back: deleting a pod changes the count, not the
      request.
    ],

    text(size: 8.5pt, weight: "bold")[Job],
    text(size: 8pt)[
      *A different stored request:* #emph[run image X once, until it finishes]. Its
      controller starts one pod, waits for a successful exit, and stops. Nothing is
      replaced.
    ],
  )
]

#panelb("3 · Drive the cluster · steps 3 to 6")[
  #text(size: 8.5pt, weight: "bold", fill: accent)[
    Type these with the kubectl set up in step 2.
  ]
  #v(4pt)
  #step("3", "Create a Deployment")[
    #text(size: 8pt)[
      The aim of this round is to watch what a cluster does when a container stops. So the
      object to create is a Deployment: a stored request for three pods that should be
      running. Three rather than one, only so that there is more to watch.
    ]
    #v(3pt)
    #block(width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, fill: luma(245))[
      #text(size: 8pt)[
        *Read step 4 first.* What happens next happens in seconds, and step 4 is how to see
        it. Nothing is lost by being slow, but the first few seconds are the interesting
        ones.
      ]
    ]
    #v(3pt)
    #raw("kubectl create deployment whale --image=ghcr.io/oesteban/whalesay --replicas=3", lang: "console")
    #v(3pt)
    #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
      raw("create"),
      text(size: 7.8pt)[The verb: make a new object. Others are #raw("get"), #raw("describe"), #raw("scale"), #raw("delete"), #raw("logs").],
      raw("deployment"),
      text(size: 7.8pt)[The *kind* of object to create. #raw("job"), #raw("pod"), #raw("service") are other kinds.],
      raw("whale"),
      text(size: 7.8pt)[The *name*, chosen freely. Every later command refers to it by this name. It also becomes the label #raw("app=whale") and the prefix of every pod name it creates, which is why the pods come out called #raw("whale-544548b554-kpnfx").],
      raw("--image=..."),
      text(size: 7.8pt)[Which image the pods run. The only part the cluster has to fetch from a registry.],
      raw("--replicas=3"),
      text(size: 7.8pt)[How many pods the request asks for. Leave it out and the default is 1.],
    )
    #v(3pt)
    #text(size: 7.8pt, fill: luma(120))[
      Why #raw("ghcr.io/...") spelled out, when step 1 named no registry at all? There is a
      second copy of this image on Docker Hub, and it does not work on every laptop. Panel 11,
      the annex, has the answer and a command to check it.
    ]
  ]
  #v(5pt)
  #step("4", "Watch what the cluster does with it")[
    #text(size: 8pt)[
      #raw("kubectl get pods") prints the list once and returns, which is no use for
      something that changes every few seconds. #raw("watch") runs a command over and over and
      redraws the screen in place, so the table stays three lines long and the columns change
      under the eye.
    ]
    #v(2pt)
    #raw("watch kubectl get pods", lang: "console")
    #v(3pt)
    #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
      raw("watch"),
      text(size: 7.8pt)[Re-runs whatever follows it, every two seconds, redrawing rather than scrolling. #raw("-n 1") makes it every second. *Ctrl-C* ends it. Nothing to do with #raw("kubectl"): it is an ordinary command-line tool.],
      raw("get"),
      text(size: 7.8pt)[List objects, one line each. No name given, so it lists them all.],
      raw("pods"),
      text(size: 7.8pt)[The kind to list. #raw("pod"), #raw("pods") and the short #raw("po") all work. #raw("kubectl get deployments") and #raw("kubectl get jobs") list the other two kinds.],
    )
    #v(3pt)
    #text(size: 8pt)[Three pods, one line each, redrawn every two seconds:]
    #v(2pt)
    #raw("Every 2.0s: kubectl get pods                    2026-09-21 09:38:01\n\nNAME                     READY  STATUS      RESTARTS      AGE\nwhale-544548b554-lbrnj   0/1    Completed   2 (21s ago)   23s\nwhale-544548b554-pbc2b   0/1    Completed   2 (21s ago)   23s\nwhale-544548b554-xrkvc   0/1    Completed   2 (21s ago)   23s", lang: "console")
    #v(3pt)
    #text(size: 8pt)[
      Watch for two minutes. *STATUS* flickers between #raw("Running"), #raw("Completed") and
      #raw("CrashLoopBackOff") — the container only runs for a fraction of a second, so
      #raw("Running") is rarely caught. *RESTARTS* is the column that tells the story: it only
      ever goes up. Record an early line and a later one in panel 4, then *Ctrl-C*.
    ]
    #v(3pt)
    #block(width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, fill: luma(245))[
      #text(size: 8pt)[
        *#raw("CrashLoopBackOff") is not a problem here, and nothing needs fixing.* It is the
        expected result: a container that finishes is being asked to stay running, so it is
        started again and again, with a growing pause in between. That pause is what the
        status is reporting.
      ]
      #v(3pt)
      #text(size: 8pt)[
        *To run the whole thing again from the start:* delete the Deployment, then repeat
        step 3.
      ]
      #v(2pt)
      #raw("kubectl delete deployment whale", lang: "console")
      #v(2pt)
      #text(size: 7.8pt, fill: luma(120))[
        #raw("delete") removes the stored request, and its pods go with it.
      ]
    ]
  ]
  #step("5", "Create a Job from the same image")[
    #text(size: 8pt)[
      A Job is the other kind of stored request: run the image once, until it finishes. The
      image and the cluster are the same as in step 3, and only the kind is different — so
      anything that happens differently is caused by the kind alone.
    ]
    #v(2pt)
    #raw("kubectl create job whale --image=ghcr.io/oesteban/whalesay -- cowsay 'a cluster ran me'", lang: "console")
    #v(3pt)
    #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
      raw("job"),
      text(size: 7.8pt)[The kind. Everything else on this line works exactly as it did in step 3.],
      raw("--"),
      text(size: 7.8pt)[*Ends kubectl's own arguments.* What follows is not for kubectl: it is the command to run inside the container, and it replaces the one built into the image. The same idea as #raw("--entrypoint") in step 2, and of #raw("ENTRYPOINT") in a Dockerfile.],
      raw("cowsay 'a cluster ran me'"),
      text(size: 7.8pt)[That command and its single argument. #raw("cowsay") is the program inside the image; the quoted text is what it prints.],
    )
    #v(2pt)
    #text(size: 8pt)[
      Then #raw("kubectl get pods") once more. The Job's pod is the one whose name carries a
      single hash rather than two.
    ]
    #v(3pt)
    #block(width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, fill: luma(245))[
      #text(size: 8pt)[
        *A name can only be used once.* Running that same line a second time fails:
      ]
      #v(2pt)
      #raw("error: failed to create job: jobs.batch \"whale\" already exists", lang: "console")
      #v(2pt)
      #text(size: 8pt)[
        To run another one, either give it a different name, or delete the first:
      ]
      #v(2pt)
      #raw("kubectl create job whale2 --image=ghcr.io/oesteban/whalesay -- cowsay 'again'\nkubectl delete job whale", lang: "console")
      #v(3pt)
      #text(size: 8pt)[
        Note that the Deployment from step 3 is *also* called #raw("whale"), and it was not in
        the way. Names have to be unique within a kind, not across kinds — which is why the
        next step has to say #raw("job/whale") and not just #raw("whale").
      ]
    ]
  ]
  #v(5pt)
  #step("6", "Read what the Job printed")[
    #text(size: 8pt)[
      The pod ran #raw("cowsay") and exited. What it printed is still held by the cluster, and
      this is how to see it.
    ]
    #v(2pt)
    #raw("kubectl logs job/whale", lang: "console")
    #v(3pt)
    #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
      raw("logs"),
      text(size: 7.8pt)[Print what a container wrote to its output. Containers have no screen; this is the screen.],
      raw("job/whale"),
      text(size: 7.8pt)[*KIND/NAME.* A Job does not have logs — its *pod* does. Naming the Job is enough: kubectl finds the pod it made. #raw("deploy/whale") works the same way, and a bare pod name also works.],
    )
  ]
]

#panelb("4 · Why the Deployment kept restarting")[
  #text(size: 8.5pt, weight: "bold")[Two lines from the watch in step 4.]
  #v(1pt)
  #text(size: 8pt)[One copied in the first seconds, one copied about a minute later.]
  #v(4pt)
  #grid(columns: (1fr, 1fr), column-gutter: 10pt,
    [
      #text(size: 8pt, weight: "bold")[An early line]
      #v(2pt)
      #grid(columns: (auto, 1fr), column-gutter: 5pt, row-gutter: 6pt, align: bottom,
        text(size: 8pt)[STATUS], rule(100%),
        text(size: 8pt)[RESTARTS], rule(100%),
      )
    ],
    [
      #text(size: 8pt, weight: "bold")[A later line]
      #v(2pt)
      #grid(columns: (auto, 1fr), column-gutter: 5pt, row-gutter: 6pt, align: bottom,
        text(size: 8pt)[STATUS], rule(100%),
        text(size: 8pt)[RESTARTS], rule(100%),
      )
    ])
  #v(7pt)
  #text(size: 8.5pt, weight: "bold")[First, where those pods are running.]
  #v(1pt)
  #text(size: 8pt)[
    In step 2 the node came out with a name like #raw("7c19eb7874a1"). Run #raw("docker ps")
    on the laptop and read the CONTAINER ID column: that node name is the id of the
    container started in step 1. A real cluster has many machines and has to choose one;
    this cluster has a single container acting as its one machine, and the three pods are
    processes inside it.
  ]
  #v(6pt)
  #text(size: 8.5pt, weight: "bold")[Now the question this round is about.]
  #v(1pt)
  #text(size: 8pt)[
    #raw("cowsay") printed its whale and exited. It did not crash: it finished, which for a
    program is the ordinary way to end. The cluster starts it again anyway, and RESTARTS
    keeps climbing. Why?
  ]
  #writing(2)
  #v(4pt)
  #text(size: 8pt)[
    The Job in step 5 ran *the same image* on *the same cluster* and was started exactly
    once. The image did not change and the cluster did not change, so the difference is
    something you wrote. What was it?
  ]
  #writing(2)
  #v(4pt)
  #block(width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, fill: luma(245))[
    #text(size: 7.8pt)[
      *On #raw("CrashLoopBackOff") again:* it is the status shown while the cluster waits
      before starting a stopped container one more time. The wait grows each round, 10s,
      20s, 40s, doubling up to a five-minute ceiling, which is why the table slows down the
      longer it is watched. Nothing has crashed and nothing needs fixing.
    ]
  ]
  #v(5pt)
  #block(width: 100%, inset: (x: 6pt, y: 5pt), radius: 2pt,
         stroke: 1pt + accent, fill: rgb("#fff0f6"))[
    #text(size: 8.5pt, weight: "bold")[Then read the cluster's own account of it.]
    #v(1pt)
    #text(size: 8pt)[
      #raw("get") prints one line per object. #raw("describe") prints everything the cluster
      knows about *one* object, which for a pod is some fifty lines.
    ]
    #v(2pt)
    #raw("kubectl describe pod whale-544548b554-528fl", lang: "console")
    #v(2pt)
    #text(size: 7.8pt, fill: luma(120))[
      Substitute one of your own pod names from #raw("kubectl get pods"); the random part
      differs on every laptop.
    ]
    #v(3pt)
    #text(size: 8pt)[
      About a third of the way down sits a block headed *Last State*. It describes the
      previous run of the container, the one that has already ended. Copy two of its fields:
    ]
    #v(3pt)
    #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
      text(size: 8pt)[Reason], rule(100%),
      text(size: 8pt)[Exit Code], rule(100%),
    )
    #v(5pt)
    #text(size: 8pt)[
      Then go to the very bottom of the same output, to the block headed *Events*. One of
      its lines reads:
    ]
    #v(2pt)
    #raw("Warning  BackOff  ...  Back-off restarting failed container whalesay", lang: "console")
    #v(3pt)
    #text(size: 8pt)[
      Those two parts of one output describe the same container and do not agree about it.
      Which of them is wrong about what the container did, and what does that tell you
      about what a Deployment expects of a container?
    ]
    #writing(2)
  ]
]

#v(5pt)

#panelb("5 · Reading logs")[
  #text(size: 8.5pt)[
    A container has no screen. Whatever the program inside writes is kept by the cluster,
    and #raw("kubectl logs") prints it back. Type these with the kubectl from step 2, while
    the Deployment from step 3 still exists.
  ]
  #v(5pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 6pt, align: (top, top),

    raw("kubectl logs <pod>"),
    text(size: 8pt)[
      The plain form. Take a pod name from #raw("kubectl get pods"). Out comes the whale.
    ],

    raw("kubectl logs deploy/whale"),
    text(size: 8pt)[
      KIND/NAME, as in step 6. Logs belong to a container and the Deployment has three, so
      kubectl picks one and admits it on the first line:
      #raw("Found 3 pods, using pod/whale-…"). Run it twice. \
      *Does it pick the same pod both times, and is that what you would want?*
    ],

    raw("kubectl logs -l app=whale --prefix"),
    text(size: 8pt)[
      All three at once. #raw("-l") selects by *label* rather than by name, and step 3
      stamped #raw("app=whale") on every pod it created. #raw("--prefix") puts
      #raw("[pod/NAME/CONTAINER]") at the start of each line. \
      *Take #raw("--prefix") away and the same output becomes useless. Why?*
    ],

    raw("kubectl logs <pod> --timestamps"),
    text(size: 8pt)[
      Puts the time each line was written in front of it. Compare the first timestamp with
      the last one. \
      *How long did the program take to run, and what does that explain about step 4?*
    ],

    raw("kubectl logs <pod> --previous"),
    text(size: 8pt)[
      The run *before* the current one. Plain #raw("logs") only ever shows the container
      running now, so once a container is replaced its output is out of reach without this.
      Here it often answers #raw("unable to retrieve container logs") instead: these pods
      restart every few seconds and the dead container has already been cleared away. \
      *When is #raw("--previous") the only command that can answer the question?*
    ],
  )
  #v(5pt)
  #text(size: 8.5pt)[Answer that last one here.]
  #writing(2)
]

#v(6pt)

#checkpoint

#v(8pt)

// ══ EXTENSIONS — up to twenty minutes ═════════════════════════════════════
#panelb("6 · Run the image you built on Friday")[
  #text(size: 8.5pt)[
    Everything so far ran an image belonging to someone else. Now do step 3 again with your
    own: the one your GitHub Actions workflow pushed on Friday. Replace
    #raw("<your-handle>") with your GitHub username.
  ]
  #v(2pt)
  #raw("kubectl create deployment mine --image=ghcr.io/<your-handle>/whalesay", lang: "console")
  #v(3pt)
  #text(size: 8pt)[
    No #raw("--replicas") this time, so the default applies and there is one pod. It will
    restart for ever, for the reason written in panel 4. That is expected. What is being
    tested here is only whether the image arrives.
  ]
  #v(4pt)
  #text(size: 8pt)[
    Your handle #box(width: 45mm, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)
    #h(8pt) Did the pod start? #box(width: 20mm, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)
  ]
  #v(5pt)
  #text(size: 8.5pt)[
    If the image never arrived, STATUS reads #raw("ErrImagePull") or
    #raw("ImagePullBackOff"), and #raw("kubectl describe pod") carries the registry's own
    message in the *Events* block at the bottom. Write that message down, then fix it.
  ]
  #writing(2)
  #v(4pt)
  #text(size: 8.5pt)[
    A registry is a server that stores images and hands them out over HTTPS. Nobody told
    the cluster where #raw("ghcr.io") is, and nobody gave it a password, yet it fetched the
    image. What had to be true of your package for that to work?
  ]
  #writing(2)
  #v(4pt)
  #text(size: 8.5pt)[
    #raw("docker pull alpine") names no registry at all and still gets an image. Which
    registry serves it, and what is the full name that #raw("alpine") is short for?
  ]
  #writing(2)
]

#v(6pt)

#panel("7 · Read the cluster's event log")[
  #text(size: 8.5pt)[
    Every time the cluster decides something it writes the decision down: this pod goes on
    that node, this image was pulled and took 510 ms, this container was started, this one
    is being held back before another try. Those records are called *Events*. They are
    objects like pods, so #raw("kubectl get") lists them.
  ]
  #v(2pt)
  #raw("kubectl get events --sort-by=.lastTimestamp | tail -8", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("events"),
    text(size: 7.8pt)[The kind to list, exactly as #raw("pods") was in step 4. This covers the whole cluster, not one pod.],
    raw("--sort-by=.lastTimestamp"),
    text(size: 7.8pt)[Order by a field of the object, oldest first. Without it the order is arbitrary and the list is unreadable.],
    raw("| tail -8"),
    text(size: 7.8pt)[Ordinary shell, nothing to do with kubectl: keep the last eight lines, which are now the eight most recent events.],
  )
  #v(4pt)
  #text(size: 8.5pt)[
    The same events, narrowed to one pod, are the block at the bottom of the
    #raw("kubectl describe pod") output read in panel 4.
  ]
  #v(4pt)
  #text(size: 8.5pt)[
    Nobody typed any of these lines. Read them and say what they are a record of: the
    requests you made, or what the cluster did in order to meet them?
  ]
  #writing(2)
]

#v(6pt)

#panel("8 · The cluster has its own image store")[
  #text(size: 8.5pt)[
    k3s does not use the Docker daemon on the laptop. Inside the #raw("k8s") container it
    runs a container runtime of its own, *containerd*, which keeps its own copy of every
    image it pulls. #raw("crictl") is to containerd what #raw("docker") is to Docker, and
    k3s ships it.
  ]
  #v(4pt)
  #text(size: 8pt)[
    Both lines below are typed *on the laptop*, in a terminal that is not the kubectl one:
  ]
  #v(2pt)
  #raw("docker exec k8s crictl images     # the cluster's images\ndocker images                     # the laptop's images", lang: "console")
  #v(3pt)
  #text(size: 7.8pt, fill: luma(120))[
    #raw("docker exec k8s ...") runs a command inside the #raw("k8s") container.
    #raw("crictl") exists only in there, so typing it on the laptop, or in the kubectl
    container, finds no such command.
  ]
  #v(4pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[whalesay in #raw("crictl")?], rule(100%),
    text(size: 8pt)[in #raw("docker")?], rule(100%),
  )
  #v(6pt)
  #text(size: 8.5pt)[
    Nobody copied anything from the laptop into the cluster, and the two stores share no
    files. So where did the cluster's copy come from, and what would have happened in
    step 3 if that image had only ever existed on your laptop?
  ]
  #writing(2)
]

#v(6pt)

#panel("9 · Scale the Deployment, then delete a pod")[
  #text(size: 8.5pt)[
    A Deployment is a stored request, so changing how many pods run means editing the
    request. Nothing is started or stopped by hand.
  ]
  #v(2pt)
  #raw("kubectl scale deployment whale --replicas=5\nkubectl scale deployment whale --replicas=0", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("scale"),
    text(size: 7.8pt)[Edits one field, #raw("replicas"), of an object that already exists. It creates nothing.],
    raw("deployment whale"),
    text(size: 7.8pt)[KIND then NAME, written with a space. The long form of #raw("deploy/whale").],
  )
  #v(3pt)
  #text(size: 8pt)[Count the pods with #raw("kubectl get pods") a few seconds after each line.]
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[pods at 5], rule(100%),
    text(size: 8pt)[pods at 0], rule(100%),
  )
  #v(6pt)
  #text(size: 8.5pt, weight: "bold")[Now delete a pod that something is still asking for, and one that nothing is.]
  #v(2pt)
  #raw("kubectl scale deployment whale --replicas=3\nkubectl delete pod <one of the three>\nkubectl delete pod <the Job's pod from step 5>")
  #v(3pt)
  #text(size: 8pt)[
    Then #raw("kubectl get pods") again. One of the two is back within seconds and the
    other is simply gone. Which is which, and why are the answers different?
  ]
  #writing(2)
]

#v(6pt)

#panel("10 · Extra mile · make the Deployment stop restarting")[
  #text(size: 8.5pt)[
    Step 5 stopped the restarting by asking for a different *kind* of object. There is a
    second way, and it leaves the object a Deployment: same image, nothing rebuilt, nothing
    re-pushed, and the pods settle at #raw("Running") with #raw("RESTARTS 0").
  ]
  #v(3pt)
  #text(size: 8.5pt)[
    What you already know: the image runs one program and that program ends, and step 5
    showed how to replace the program a container runs. Delete the Deployment, then create
    it again with one thing added.
  ]
  #v(3pt)
  #text(size: 8pt, weight: "bold")[Write the command, then run it.]
  #writing(2)
  #v(4pt)
  #text(size: 8.5pt)[
    There are now two ways to keep this cluster content with this image. Which one fits a
    web server, and which fits a report that is produced once a night?
  ]
  #writing(2)
]

#v(8pt)

#panel("11 · Annex · why the image comes from ghcr.io and not Docker Hub")[
  #text(size: 8.5pt)[
    Two copies of this image exist, #raw("ghcr.io/oesteban/whalesay") and
    #raw("oesteban/whalesay"), and they are not the same thing. Run these two #emph[on the
    laptop], not in the kubectl container:
  ]
  #v(2pt)
  #raw("docker buildx imagetools inspect ghcr.io/oesteban/whalesay\ndocker buildx imagetools inspect oesteban/whalesay")
  #v(3pt)
  #text(size: 7.8pt, fill: luma(120))[
    #raw("imagetools inspect") asks a registry what a name points at, and prints the answer
    without downloading the image itself.
  ]
  #v(3pt)
  #text(size: 8.5pt)[
    A name in a registry can point at a single image, or at a *list* of images with one
    entry per CPU architecture. The first command prints such a list, headed
    #raw("Manifests:"), with #raw("Platform: linux/amd64") *and* #raw("Platform: linux/arm64").
    The second prints no list at all: one image, #raw("linux/amd64") only.
  ]
  #v(3pt)
  #text(size: 8.5pt)[
    An Apple Silicon Mac runs an *arm64* Linux VM, and the containerd inside k3s has no
    emulation to fall back on. The Docker Hub copy would fail there with
    #raw("exec format error") and the pod would never start. The GHCR copy was built for
    both architectures by GitHub Actions on Friday.
  ]
  #v(3pt)
  #text(size: 8.5pt)[
    *On Linux or Windows, on an Intel or AMD processor,* the Docker Hub copy is fine. Check
    the manifests above, then run it alongside:
  ]
  #v(2pt)
  #raw("kubectl create deployment hub --image=oesteban/whalesay --replicas=1", lang: "console")
  #v(3pt)
  #text(size: 8.5pt)[
    Which architecture is this laptop?
    #box(width: 35mm, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)
  ]
]

#v(8pt)
#align(center)[
  #text(size: 8pt, fill: luma(130), style: "italic")[
    Done when the referee can say, without reading this sheet, why the same image
    restarts forever as a Deployment and finishes as a Job.
  ]
]
