// ---------------------------------------------------------------------------
// ulab2-driver-worksheet.typ — one A4 sheet per group, for µLab 2 of week 2 day 1.
//
// The referee's grid records how the group worked. This records what the group
// produced, and it carries the four steps so that the answer to "what were we
// supposed to do again?" is on the table rather than on a slide that has moved on.
//
// The roles rotate between rounds: whoever drove µLab 1 is not driving this one.
//
// This round is the bridge. µLab 1 left a cluster running; this one puts Spark on
// it, and µLab 3 submits work to what this one builds.
//
// Two decisions worth not re-opening. The cluster is deployed from a manifest
// rather than from kubectl create, because kubectl create gives a pod no stable
// hostname: the driver then advertises a name cluster DNS cannot resolve and every
// submission hangs for ever, which was measured, not guessed. And the image is
// left for the cluster to download rather than imported from the laptop, because
// the whole point of panel 4 is that the two stores are separate; the import is
// panel 8, where it is an optimisation rather than a mystery.
//
// The sheet is cut in two by a checkpoint bar. AUTHORING.md rule G1 sizes a core
// at ten minutes, and this one is sized for fifteen to twenty, because the cluster
// spends one to three of them downloading a 535 MB image. The reader is not the
// clock here.
//
// Every number and every line of output quoted below was observed on a real run
// on 2026-09-21. The Pi value is the exception and is marked as such, because the
// estimate is random and differs every time.
//
// Committed BLANK and it must stay that way: a filled sheet carries a GitHub
// handle and is personally identifying. It is handed to the teacher at the end
// of the round, never returned, never photographed, and never enters git. See
// the PII doctrine in the repository CLAUDE.md.
//
//   typst compile ulab2-driver-worksheet.typ
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
  title: "µLab worksheet · Deploying Spark on your own cluster",
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

// ══ CORE — fifteen to twenty minutes ══════════════════════════════════════
#panelb("1 · Give the cluster a folder it can read · step 1")[
  #text(size: 8.5pt)[
    A container can only see the folders it was handed at the moment it was created.
    µLab 1 handed the cluster exactly one, #raw("kube"), so that it had somewhere to
    write its credentials. There is no command that adds a second folder afterwards: the
    only way is to throw the container away and make it again. So make an empty folder
    now and hand it over now, while rebuilding is free.
  ]
  #v(3pt)
  #step("1", "Make the folder, then rebuild the cluster around it.")[
    Work in the same folder you started the cluster in during µLab 1, the one with
    #raw("kube") in it.
  ]
  #v(2pt)
  #raw("mkdir lab", lang: "console")
  #v(3pt)
  #block(width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, fill: luma(245))[
    #text(size: 8pt)[
      *Do not skip this line.* If #raw("lab") does not exist when the next command runs,
      Docker creates it for you and it comes out owned by #raw("root"). Everything you
      try to write into it afterwards then fails with #raw("Permission denied"), and the
      only cure is to delete it with #raw("sudo") and start again.
    ]
  ]
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Now replace the cluster.]
  #v(1pt)
  #text(size: 8pt)[
    The first line deletes the µLab 1 cluster and everything on it, including the whale.
    That is intended: nothing from µLab 1 is needed again.
  ]
  #v(2pt)
  #raw("docker rm -f k8s\ndocker run -d --name k8s --privileged --tmpfs /run --tmpfs /var/run \\\n  -p 6443:6443 -v \"$PWD/kube:/output\" -v \"$PWD/lab:/lab\" \\\n  rancher/k3s:v1.36.4-k3s1 server --disable=traefik \\\n  --write-kubeconfig /output/config --write-kubeconfig-mode 644", lang: "console")
  #v(3pt)
  #text(size: 8pt)[
    This is the µLab 1 command with *one argument added*. The table repeats the rest in
    one line each so that nothing on this sheet is typed unexplained.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("rm -f k8s"),
    text(size: 7.8pt)[Delete the container named #raw("k8s"). The #raw("-f") kills it first if it is still running.],
    raw("-d"),
    text(size: 7.8pt)[Detached: the cluster keeps running after your prompt comes back.],
    raw("--name k8s"),
    text(size: 7.8pt)[Give it a name, so later commands can say #raw("k8s") instead of an id.],
    raw("--privileged"),
    text(size: 7.8pt)[Kubernetes runs containers, so it needs the kernel privileges a container is normally denied.],
    raw("--tmpfs /run"),
    text(size: 7.8pt)[A small in-memory filesystem. k3s writes sockets there and they must not survive a restart.],
    raw("--tmpfs /var/run"),
    text(size: 7.8pt)[The same, for the second conventional location.],
    raw("-p 6443:6443"),
    text(size: 7.8pt)[Publish the API port to your laptop, so a client outside the container can reach it.],
    raw("-v \"$PWD/kube:/output\""),
    text(size: 7.8pt)[Bind-mount: the #raw("kube") folder here appears inside at #raw("/output"), which is where the credentials file gets written.],
    text(fill: accent, weight: "bold", raw("-v \"$PWD/lab:/lab\"")),
    text(size: 7.8pt)[*The new one.* The #raw("lab") folder here appears inside the cluster at #raw("/lab"). It is empty, and it stays yours: a bind mount is the same folder seen twice, not a copy, so whatever you put in it later is visible inside at once.],
    raw("rancher/k3s:…"),
    text(size: 7.8pt)[The image: a whole Kubernetes in one binary. Pinned to #raw("v1.36.4-k3s1") so every laptop runs the same version.],
    raw("server"),
    text(size: 7.8pt)[Everything after the image name is handed to the program inside. #raw("server") means be the cluster, not join one.],
    raw("--disable=traefik"),
    text(size: 7.8pt)[Skip the bundled web router. Nothing here serves web traffic, and it takes time to start.],
    raw("--write-kubeconfig …"),
    text(size: 7.8pt)[Where to write the credentials file, and with which permissions. #raw("644") makes it readable by you rather than only by root.],
  )
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Then get a client. It is the µLab 1 line, unchanged.]
  #v(1pt)
  #text(size: 8pt)[
    Linux users who installed #raw("kubectl") in µLab 1 keep using it and skip this box.
    Nothing about the client changes this round: it talks to the cluster over the network
    and never touches #raw("lab").
  ]
  #v(2pt)
  #raw("docker run --rm -it --network container:k8s \\\n  -v \"$PWD/kube:/kube:ro\" -e KUBECONFIG=/kube/config \\\n  --entrypoint sh alpine/kubectl", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("--rm -it"),
    text(size: 7.8pt)[Disposable, and interactive: a shell you can type many commands into, deleted when you leave.],
    raw("--network container:k8s"),
    text(size: 7.8pt)[Join the cluster container's network instead of getting one. That is why #raw("127.0.0.1:6443") works in here.],
    raw("-v \"$PWD/kube:/kube:ro\""),
    text(size: 7.8pt)[The credentials, read-only. A client has no business editing them.],
    raw("-e KUBECONFIG=/kube/config"),
    text(size: 7.8pt)[Which cluster to talk to. The path is the one *inside this container*, not on your laptop.],
    raw("--entrypoint sh"),
    text(size: 7.8pt)[Run a shell instead of the single #raw("kubectl") the image is built for.],
    raw("alpine/kubectl"),
    text(size: 7.8pt)[The image: #raw("kubectl") and a small Alpine base, from Docker Hub.],
  )
  #v(4pt)
  #text(size: 8pt)[
    Check the cluster answers. The #raw("NAME") is the new container's id, so it is *not*
    the one µLab 1 showed: this is a different cluster.
  ]
  #v(2pt)
  #raw("kubectl get nodes", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[NAME], rule(100%),
    text(size: 8pt)[STATUS], rule(100%),
  )
]

#panelb("2 · Some definitions")[
  #text(size: 8pt)[
    Everything this round asks you to explain can be answered from this block. It is
    worth reading once before step 2 rather than hunting through it afterwards.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 5pt, align: (top, top),

    text(size: 8.5pt, weight: "bold")[image store],
    text(size: 8pt)[
      *The place a container runtime keeps the images it can start.* Your laptop's Docker
      has one. The cluster runs a different runtime, containerd, with a store of its own,
      and neither can read the other's files. They use the same names, which is what
      makes the confusion easy. Panel 4 lists both.
    ],

    text(size: 8.5pt, weight: "bold")[driver],
    text(size: 8pt)[
      *The program that runs your Spark code.* It decides what work exists, hands the
      pieces out, and collects the answers. There is exactly one per job, and when it
      stops the job is over.
    ],

    text(size: 8.5pt, weight: "bold")[executor],
    text(size: 8pt)[
      *A process that does pieces of work for one driver.* It is started for a job and
      exits with it. An executor holds a number of cores, and runs one piece of work per
      core at a time.
    ],

    text(size: 8.5pt, weight: "bold")[Spark master],
    text(size: 8pt)[
      *The process that hands out the cluster's cores.* It runs nothing itself. Drivers
      ask it for resources, it decides which machines will supply them, and it keeps a
      list of who is available. Not to be confused with the Kubernetes control plane,
      which hands out pods. This one hands out cores, and it is a pod itself.
    ],

    text(size: 8.5pt, weight: "bold")[Spark worker],
    text(size: 8pt)[
      *A process that offers cores and memory to a master, and starts executors when
      told to.* It announces itself to the master on startup, which is the line step 4
      looks for. A worker is long-lived; the executors it starts are not.
    ],

    text(size: 8.5pt, weight: "bold")[standalone mode],
    text(size: 8pt)[
      *Spark running its own master and workers, rather than asking another system for
      resources.* It is Spark's simplest arrangement and the one deployed here. It
      exists because Spark predates Kubernetes and had to schedule for itself.
    ],

    text(size: 8.5pt, weight: "bold")[Service],
    text(size: 8pt)[
      *A stable name for whichever pods currently carry a label.* The one new Kubernetes
      object this round adds. Pods are replaced and each replacement gets a new address,
      so nothing can be configured to talk to a pod directly. A Service is the name that
      does not change: workers are told #raw("spark://spark-master:7077") once and that
      stays true across every replacement.
    ],

    text(size: 8.5pt, weight: "bold")[cluster DNS],
    text(size: 8pt)[
      *The name server every pod is given, which answers for Service names.* It is what
      turns #raw("spark-master") into an address inside the cluster. It answers for pods
      that are behind a Service, and *for nothing else*, which is the trap panel 9
      describes.
    ],
  )
]

#panelb("3 · Create the master and the workers by hand · step 2")[
  #text(size: 8.5pt)[
    Spark's own cluster is three things: a master process that hands out cores, worker
    processes that supply them, and a name the workers can dial that keeps working when a
    pod is replaced. In Kubernetes terms that is *one Service and two Deployments*, and
    µLab 1 already made a Deployment with a single #raw("kubectl create") command. Three
    objects, so three commands, typed in this order.
  ]
  #v(3pt)
  #step("2", "Create the name first, then the master, then the workers.")[
    In the #raw("kubectl") shell. The order matters: the master looks its own name up
    when it starts, so if the Service is not there yet it fails and restarts until it is.
  ]
  #v(2pt)
  #raw("kubectl create service clusterip spark-master --clusterip=\"None\" --tcp=7077:7077", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("create service clusterip"),
    text(size: 7.8pt)[Make a Service of the ordinary kind, reachable only from inside the cluster. Nothing here is served to the outside world.],
    raw("spark-master"),
    text(size: 7.8pt)[Its name, and therefore *the name that will resolve*. It also becomes the label the Service looks for, #raw("app=spark-master"), which is the label the next command happens to give its pods.],
    raw("--clusterip=\"None\""),
    text(size: 7.8pt)[Do not give the Service an address of its own. Make the name answer with the pod's own address instead, because the master has to bind to whatever its name resolves to, and it cannot bind to an address that belongs to no machine.],
    raw("--tcp=7077:7077"),
    text(size: 7.8pt)[The port to carry, and the port on the pod to carry it to. 7077 is the one Spark listens on for submissions.],
  )
  #v(4pt)
  #raw("kubectl create deployment spark-master --image=spark:3.5.4-python3 \\\n  -- /opt/spark/bin/spark-class org.apache.spark.deploy.master.Master \\\n     --host spark-master", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("create deployment NAME"),
    text(size: 7.8pt)[The same command as #raw("kubectl create deployment whale …") in µLab 1. The name also becomes the pods' #raw("app") label, which is what the Service just asked for.],
    raw("--image=spark:3.5.4-python3"),
    text(size: 7.8pt)[Which image the pods run. Note there is no registry in the name, so *Docker Hub*, and the cluster will have to fetch it: panel 4 is about where from.],
    raw("--"),
    text(size: 7.8pt)[End of #raw("kubectl")'s own arguments. Everything after it is the command to run inside the container, exactly as in µLab 1's Job.],
    raw("spark-class …Master"),
    text(size: 7.8pt)[Run one named Java class and stay in the foreground, which is what a container needs. The image's own default would start something else.],
    raw("--host spark-master"),
    text(size: 7.8pt)[The master's own argument: which name to publish itself under. It must match what the workers dial, or they connect and are then sent somewhere they cannot reach.],
  )
  #v(4pt)
  #raw("kubectl create deployment spark-worker --image=spark:3.5.4-python3 --replicas=2 \\\n  -- /opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker \\\n     spark://spark-master:7077 --cores 1 --memory 1g", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("--replicas=2"),
    text(size: 7.8pt)[How many worker pods to ask for. Before the #raw("--"), so #raw("kubectl") reads it and Spark never sees it.],
    raw("spark://spark-master:7077"),
    text(size: 7.8pt)[Which master to report to. The Service name from the first command, so this stays true however often the master's pod is replaced.],
    raw("--cores 1 --memory 1g"),
    text(size: 7.8pt)[What one worker offers. Deliberately small, so the arithmetic is legible: the cluster has as many cores as it has worker pods.],
  )
  #v(4pt)
  #text(size: 8pt)[Then watch the pods appear:]
  #v(2pt)
  #raw("kubectl get pods", lang: "console")
  #v(3pt)
  #block(width: 100%, inset: (x: 6pt, y: 4pt), radius: 2pt, fill: luma(245))[
    #text(size: 8pt)[
      *The pods will sit in #raw("ContainerCreating") for a while.* One to three minutes
      here, and longer on a shared connection. Nothing is wrong: the cluster is
      downloading a 535 MB image, and panel 4 is about why it has to. Once the master has
      it the workers start in seconds, because by then it is already in the store.
    ]
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[master pod], rule(100%),
    text(size: 8pt)[READY], rule(24mm),
    text(size: 8pt)[worker pod], rule(100%),
    text(size: 8pt)[READY], rule(24mm),
    text(size: 8pt)[worker pod], rule(100%),
    text(size: 8pt)[seconds until all three], rule(24mm),
  )
]

#panelb("4 · Compare the cluster's image store with the laptop's · step 3")[
  #text(size: 8.5pt)[
    The wait in step 2 was a download, and it is worth knowing what was downloaded and
    from where. The cluster runs its containers with containerd, not with your laptop's
    Docker, and the two keep entirely separate collections of images. Neither can read
    the other's. List both and compare.
  ]
  #v(3pt)
  #step("3", "List the images the cluster has, then the ones the laptop has.")[
    Both lines are typed *on your laptop*, not in the #raw("kubectl") shell.
    #raw("crictl") exists only inside the cluster container, which is why the first line
    has to reach in there to run it.
  ]
  #v(2pt)
  #raw("docker exec k8s crictl images\ndocker image ls spark:3.5.4-python3", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("docker exec k8s"),
    text(size: 7.8pt)[Run a command *inside* the already-running #raw("k8s") container, rather than starting a new one.],
    raw("crictl images"),
    text(size: 7.8pt)[The cluster's own tool for talking to containerd, and its way of saying #emph[list the images you can start].],
    raw("docker image ls NAME"),
    text(size: 7.8pt)[Docker's list, narrowed to one name. No rows at all is a perfectly good answer here.],
  )
  #v(3pt)
  #text(size: 8pt)[As observed, with the laptop's copy present only because it had been pulled earlier:]
  #v(2pt)
  #raw("IMAGE                                        TAG                 IMAGE ID            SIZE
docker.io/library/spark                      3.5.4-python3       5908cada5243a       535MB

REPOSITORY   TAG             IMAGE ID       CREATED         SIZE
spark        3.5.4-python3   5908cada5243   21 months ago   982MB", block: true)
  #v(3pt)
  #text(size: 8pt)[
    The #raw("IMAGE ID") is the same in both, because it is the same image. The two
    #raw("SIZE") columns disagree because they measure different things, the download and
    the unpacked copy, not because the images differ.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[cluster IMAGE ID], rule(100%),
    text(size: 8pt)[laptop IMAGE ID], rule(100%),
  )
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Now answer the first question.]
  #v(1pt)
  #text(size: 8pt)[
    If your laptop already had that image, the cluster downloaded a second copy of
    something that was sitting on the same disk. Say why it had to. \
    Panel 2 defines *image store*, and the two listings above were produced by two
    different programs: read which command each one needed.
  ]
  #writing(2)
]

#panelb("5 · Read the master's log and find the workers · step 4")[
  #text(size: 8.5pt)[
    Three pods running proves Kubernetes started three programs. It does not prove they
    found each other, and they are two separate things: Kubernetes knows nothing about
    Spark, and would report a worker shouting into the void as perfectly healthy. The
    master writes down every worker that reports in, so its log is where the answer is.
  ]
  #v(3pt)
  #step("4", "Read what the master has logged since it started.")[
    In the #raw("kubectl") shell. #raw("deploy/spark-master") means #emph[the pod of that
    Deployment], so the pod's name does not have to be typed.
  ]
  #v(2pt)
  #raw("kubectl logs deploy/spark-master | grep Master:", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("logs"),
    text(size: 7.8pt)[Print what a container has written to its output since it started. Nothing is running or changed by this.],
    raw("deploy/spark-master"),
    text(size: 7.8pt)[KIND#raw("/")NAME. Given a Deployment, #raw("kubectl") picks one of its pods and says which.],
    raw("| grep Master:"),
    text(size: 7.8pt)[Ordinary shell again: keep only the lines the master class wrote, and drop several hundred lines of startup from every other part of Spark.],
  )
  #v(3pt)
  #text(size: 8pt)[The three lines that matter, as observed:]
  #v(2pt)
  #raw("INFO Master: Starting Spark master at spark://spark-master:7077
INFO Master: Registering worker 10.42.0.2:43581 with 1 cores, 1024.0 MiB RAM
INFO Master: Registering worker 10.42.0.3:39957 with 1 cores, 1024.0 MiB RAM", block: true)
  #v(3pt)
  #text(size: 8pt)[
    The address in the first line is the Service name from panel 2, not a pod. The other
    two are the workers announcing themselves, one line each, with what they are offering.
    Your addresses will differ; the shape will not.
  ]
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[workers registered], rule(100%),
    text(size: 8pt)[cores each], rule(100%),
    text(size: 8pt)[cores in total], rule(100%),
    text(size: 8pt)[RAM each], rule(100%),
  )
  #v(5pt)
  #text(size: 8.5pt, weight: "bold")[Now answer the question this round is about.]
  #v(1pt)
  #text(size: 8pt)[
    Two numbers now agree: the worker Deployment was asked for #raw("replicas: 2") and
    the master reports two workers. They are counted by different things and they are
    not the same number. Say which one is which, and which of the two would be wrong
    first if a worker pod were deleted. \
    Panel 2 defines both counters: what a *Spark master* keeps a list of, and what a
    *Service* stands in for. µLab 1 panel 9 is the other half, where a controller was
    shown replacing a deleted pod.
  ]
  #writing(2)
]

#v(6pt)

#text(size: 8pt, style: "italic", fill: luma(110))[
  Solved means panels 1 to 5 are done: the lab folder unzipped and handed to the cluster,
  master and two workers all reading #raw("1/1 Running"), both image stores listed and
  compared, and the master's log naming both workers with the cores each one offered.
]
#v(3pt)

#checkpoint

#v(8pt)

// ══ EXTENSIONS — up to twenty minutes ═════════════════════════════════════
#panelb("6 · Run a job on the cluster you just built")[
  #text(size: 8.5pt)[
    Everything so far shows Spark is *running*. This shows it *computes*. The job is the
    one that ships inside the image: throw darts at a square, count how many land inside
    a circle, and multiply. It needs no data, so nothing has to be copied anywhere, which
    makes it the cheapest possible proof that the master, the workers and a driver can
    all reach each other.
  ]
  #v(3pt)
  #text(size: 8pt)[
    Typed in the #raw("kubectl") shell. The driver runs *inside the master pod*, which
    looks like a detail and is not: panel 9 says what happens when it runs anywhere else.
  ]
  #v(2pt)
  #raw("kubectl exec deploy/spark-master -- /opt/spark/bin/spark-submit \\\n  --master spark://spark-master:7077 \\\n  --conf spark.driver.host=spark-master \\\n  --class org.apache.spark.examples.SparkPi \\\n  local:///opt/spark/examples/jars/spark-examples_2.12-3.5.4.jar 100", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("exec"),
    text(size: 7.8pt)[Run a command inside a container that is already running, the same idea as #raw("docker exec") in step 3, one level in.],
    raw("--"),
    text(size: 7.8pt)[End of #raw("kubectl")'s own arguments. Everything after it belongs to the command being run, so #raw("--master") is read by Spark and not by #raw("kubectl").],
    raw("spark-submit"),
    text(size: 7.8pt)[Spark's launcher: start a driver, ask a master for cores, run the code, print the result, exit.],
    raw("--master spark://…:7077"),
    text(size: 7.8pt)[Which master to ask. The Service name and port from step 2.],
    raw("--conf spark.driver.host=…"),
    text(size: 7.8pt)[*The one that is easy to leave out.* It tells the driver which name to give the executors so they can call it back. Left out, the driver gives them the pod's own name, which nothing can resolve, and the job hangs for ever. Panel 9 is what that looks like.],
    raw("--class org.apache…SparkPi"),
    text(size: 7.8pt)[Which program inside the jar to run. A jar holds many; this names one.],
    raw("local:///opt/spark/…jar"),
    text(size: 7.8pt)[Where the jar is. #raw("local:") means #emph[already present in the image on every machine], so Spark ships nothing. The third slash is the root of that filesystem.],
    raw("100"),
    text(size: 7.8pt)[The program's own argument: how many slices to split the darts into. More slices, more pieces of work, and a more precise answer.],
  )
  #v(4pt)
  #text(size: 8pt)[
    Several hundred lines scroll past and one line matters. On a two-worker cluster the
    whole thing took *8 seconds*:
  ]
  #v(2pt)
  #raw("Pi is roughly 3.1406367140636715", block: true)
  #v(3pt)
  #text(size: 8pt)[
    The digits after the third will not match anyone else's, including a second run of
    your own, because the darts are thrown at random. Anything near 3.14 is a success.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[your value], rule(100%),
    text(size: 8pt)[seconds], rule(100%),
  )
]

#v(6pt)

#panel("7 · Delete a worker pod and watch the master notice")[
  #text(size: 8.5pt)[
    µLab 1 deleted a pod and watched a controller put it back. The same thing happens
    here, except that something else was relying on that pod, so there are now two
    reactions to watch instead of one, written down by two different programs.
  ]
  #v(2pt)
  #raw("kubectl get pods\nkubectl delete pod <one of the two workers>\nkubectl get pods\nkubectl logs deploy/spark-master | grep Master: | tail -3", block: true)
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("delete pod"),
    text(size: 7.8pt)[Remove one pod. It removes nothing else: the Deployment that asked for it is untouched and still wants two.],
    raw("| tail -3"),
    text(size: 7.8pt)[Shell: keep the last three lines, which are now the three most recent things the master wrote.],
  )
  #v(3pt)
  #text(size: 8pt)[As observed, in this order:]
  #v(2pt)
  #raw("INFO Master: Removing worker worker-…-10.42.0.5-33537 on 10.42.0.5:33537
INFO Master: Telling app of lost worker: worker-…-10.42.0.5-33537
INFO Master: Registering worker 10.42.0.9:40593 with 1 cores, 1024.0 MiB RAM", block: true)
  #v(3pt)
  #text(size: 8pt)[
    The replacement pod starts in seconds rather than minutes, because the image is now
    in the cluster's store. Write down the new pod's name and the new address in the
    master's log, then say which of the two put the worker back, the Kubernetes
    controller or the Spark master, and what the other one did instead.
  ]
  #writing(2)
]

#v(6pt)

#panel("8 · Extra mile · hand the cluster the image instead of letting it download it")[
  #text(size: 8.5pt)[
    Step 2 waited while the cluster downloaded 535 MB that may already have been on the
    same disk. It does not have to: an image can be written out of one store and read
    into the other, over a pipe, with no network at all. Time it, and compare with the
    wait you recorded in step 2.
  ]
  #v(2pt)
  #text(size: 8pt)[
    On your laptop. If #raw("docker image ls") found nothing in panel 4, this needs
    #raw("docker pull spark:3.5.4-python3") first, which is the download you are trying
    to avoid, so the payoff is for the *next* cluster rather than this one.
  ]
  #v(2pt)
  #raw("docker save spark:3.5.4-python3 | docker exec -i k8s ctr -n k8s.io images import -", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("docker save NAME"),
    text(size: 7.8pt)[Write an image out as a plain stream of bytes. With no #raw("-o") file it goes to standard output.],
    raw("|"),
    text(size: 7.8pt)[Ordinary shell, nothing to do with Docker: send the left command's output straight into the right command's input, without ever writing a 1 GB file to disk.],
    raw("docker exec -i k8s"),
    text(size: 7.8pt)[#raw("-i") keeps the container's input open, which is what the pipe needs. There is no #raw("-t") because nothing here is typed by hand.],
    raw("ctr -n k8s.io"),
    text(size: 7.8pt)[containerd's own tool, and the namespace Kubernetes reads. An image imported into any other namespace is invisible to it.],
    raw("images import -"),
    text(size: 7.8pt)[Read an image stream and add it to the store. The #raw("-") is the other end of the pipe.],
  )
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, align: bottom,
    text(size: 8pt)[seconds to import], rule(100%),
    text(size: 8pt)[seconds to download, step 2], rule(100%),
  )
  #v(3pt)
  #text(size: 8pt)[
    Sixteen laptops downloading the same 535 MB at once is the slowest thing in this
    room. Say what you would do differently if you were setting this lab up for a class.
  ]
  #writing(2)
]

#v(8pt)

#panel("9 · Annex · why the driver has to run somewhere that has a name")[
  #text(size: 8pt)[
    Leave #raw("--conf spark.driver.host=spark-master") out of panel 6 and the job never
    starts. Executors are told to call the driver back by name, and the name they are
    given is the master pod's own, something like
    #raw("spark-master-cc5688b64-lt59r"). Cluster DNS answers for Service names, not for
    pod names, so every executor fails to resolve it and exits, and the driver waits for
    cores that never arrive, printing this every fifteen seconds:
  ]
  #v(2pt)
  #raw("WARN TaskSchedulerImpl: Initial job has not accepted any resources; check your
cluster UI to ensure that workers are registered and have sufficient resources", block: true)
  #v(2pt)
  #text(size: 8pt)[
    The message blames the workers, and the workers are fine. The flag is a workaround
    for something #raw("kubectl create") cannot do: give a pod a name of its own in
    cluster DNS. µLab 3 fixes it properly, and the flag is not needed again.
  ]
  #v(3pt)
  #text(size: 8pt)[
    *What production does instead.* Standalone mode is Spark scheduling for itself, from
    before Kubernetes existed. Given a real cluster, a submission made with
    #raw("--master k8s://…") skips all of this: Kubernetes is asked directly for a driver
    pod and executor pods, they exist only while the job runs, and there is no master, no
    workers and nothing standing idle in between. It is also several more things to get
    right, which is why it is here and not in step 2.
  ]
]

#v(6pt)

#panel("10 · Annex · what these numbers looked like here")[
  #text(size: 8pt)[
    Every figure below was measured on the teaching machine, on a fast connection, while
    this sheet was being written. *Yours will not match*, and they are not meant to: they
    are here so you can tell a slow laptop from a broken one. An order of magnitude out
    is worth asking about; a factor of two is not.
  ]
  #v(4pt)
  #grid(columns: (1fr, auto, auto), column-gutter: 10pt, row-gutter: 4pt, align: (left, right, left),
    text(size: 8pt, weight: "bold")[what], text(size: 8pt, weight: "bold")[measured], text(size: 8pt, weight: "bold")[where],
    text(size: 8pt)[cluster downloads the Spark image], text(size: 8pt)[1 m 9 s], text(size: 7.8pt, fill: luma(120))[step 2],
    text(size: 8pt)[the same download, slower connection], text(size: 8pt)[2 m 53 s], text(size: 7.8pt, fill: luma(120))[step 2],
    text(size: 8pt)[all three pods #raw("1/1 Running")], text(size: 8pt)[112 s to 182 s], text(size: 7.8pt, fill: luma(120))[step 2],
    text(size: 8pt)[workers restart once the image is in the store], text(size: 8pt)[about 20 s], text(size: 7.8pt, fill: luma(120))[panel 7],
    text(size: 8pt)[SparkPi on two workers], text(size: 8pt)[8 s], text(size: 7.8pt, fill: luma(120))[panel 6],
    text(size: 8pt)[handing the image over instead of downloading], text(size: 8pt)[37 s], text(size: 7.8pt, fill: luma(120))[panel 8],
    text(size: 8pt)[the image, as the cluster reports it], text(size: 8pt)[534'909'833 B], text(size: 7.8pt, fill: luma(120))[panel 4],
  )
  #v(4pt)
  #text(size: 8pt)[
    Write your own beside them as you go. The last two rows are the interesting pair: the
    import moves the same bytes as the download and does it without a network, which is
    the whole argument of panel 8.
  ]
]

#v(5pt)
#align(center)[
  #text(size: 8pt, fill: luma(130), style: "italic")[
    Done when the referee can say, without reading this sheet, why the cluster downloaded
    an image the laptop already had, and what a Service is for.
  ]
]
