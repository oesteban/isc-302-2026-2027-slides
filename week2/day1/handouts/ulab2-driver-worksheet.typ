// ---------------------------------------------------------------------------
// ulab2-driver-worksheet.typ — one A4 sheet per group, for µLab 2 of week 2 day 1.
//
// The referee's grid records how the group worked. This records what the group
// produced, and it carries the four steps so that the answer to "what were we
// supposed to do again?" is on the table rather than on a slide that has moved on.
//
// The roles rotate between rounds: whoever drove µLab 1 is not driving this one.
//
// This round is the bridge. µLab 1 left a cluster running and taught that the
// cluster has its own image store; here that fact stops being a demonstration and
// becomes the obstacle, because the Spark image is 982 MB and the cluster cannot
// see it. µLab 3 then submits work to what this round builds.
//
// The sheet is cut in two by a checkpoint bar. Everything above it is the core;
// everything below is extension work. AUTHORING.md rule G1 sizes a core at ten
// minutes, and this one is sized for fifteen to twenty, because two of its five
// panels wait on a machine: an image import of about forty seconds and a pod
// rollout. The reader is not the clock here.
//
// Every number and every line of output quoted below was observed on a real run
// on 2026-09-21, not reasoned out. The Pi value is the exception and is marked as
// such, because the estimate is random and differs every time.
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
#panelb("1 · Re-create the cluster with the lab folder attached · step 1")[
  #text(size: 8.5pt)[
    µLab 3 will run a word count over 18'846 files that live in this repository. The
    cluster from µLab 1 cannot read any of them, and no command will fix that: a
    container can only see the folders it was handed *at the moment it was created*,
    and that command said nothing about this repository. So the cluster is thrown away
    and made again, this time with the folder attached.
  ]
  #v(3pt)
  #step("1", "Get the repository, and work from inside it.")[
    Every command on this sheet is typed on your laptop, from this folder. If the
    clone is already there from the announcement, #raw("git pull") is enough.
  ]
  #v(2pt)
  #raw("git clone https://github.com/oesteban/isc-302-2026-2027-spark-lab\ncd isc-302-2026-2027-spark-lab", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("clone"),
    text(size: 7.8pt)[Copies the whole repository, history included, into a new folder named after it.],
    raw("https://github.com/…"),
    text(size: 7.8pt)[The address. 17.6 MiB to download, which is quick; then 18'846 small files to write to disk, which is not. A checkout that takes a minute is working, not hung.],
  )
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Now replace the cluster.]
  #v(1pt)
  #text(size: 8pt)[
    The first line deletes the µLab 1 cluster and everything on it, including the whale.
    That is intended: nothing from µLab 1 is needed again.
  ]
  #v(2pt)
  #raw("docker rm -f k8s\ndocker run -d --name k8s --privileged --tmpfs /run --tmpfs /var/run \\\n  -p 6443:6443 -v \"$PWD/kube:/output\" -v \"$PWD:/lab\" \\\n  rancher/k3s:v1.36.4-k3s1 server --disable=traefik \\\n  --write-kubeconfig /output/config --write-kubeconfig-mode 644", lang: "console")
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
    text(fill: accent, weight: "bold", raw("-v \"$PWD:/lab\"")),
    text(size: 7.8pt)[*The new one.* This whole folder, corpus included, appears inside the cluster container at #raw("/lab"). Pods will mount it from there in step 3.],
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
  #text(size: 8.5pt, weight: "bold")[Then get a client, and point it at the folder too.]
  #v(1pt)
  #text(size: 8pt)[
    Linux users who installed #raw("kubectl") in µLab 1 keep using it and skip this box.
    Everyone else runs the client in its own container, as in µLab 1, with *two changes*:
    the mount is now the whole folder rather than just #raw("kube"), so that the client
    can read the file applied in step 3.
  ]
  #v(2pt)
  #raw("docker run --rm -it --network container:k8s \\\n  -v \"$PWD:/lab:ro\" -e KUBECONFIG=/lab/kube/config \\\n  --entrypoint sh alpine/kubectl", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("--rm -it"),
    text(size: 7.8pt)[Disposable, and interactive: a shell you can type many commands into, deleted when you leave.],
    raw("--network container:k8s"),
    text(size: 7.8pt)[Join the cluster container's network instead of getting one. That is why #raw("127.0.0.1:6443") works in here.],
    text(fill: accent, weight: "bold", raw("-v \"$PWD:/lab:ro\"")),
    text(size: 7.8pt)[*Changed.* µLab 1 mounted only #raw("kube"). The client now needs the manifest file as well, so the whole folder comes in, read-only.],
    text(fill: accent, weight: "bold", raw("-e KUBECONFIG=/lab/kube/config")),
    text(size: 7.8pt)[*Changed to match.* The credentials are at the same place as before, one level further down the new mount.],
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
      has one; the cluster has a separate one of its own, and neither can read the other's.
      µLab 1 showed this by listing them side by side. Step 2 is what to do about it.
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
      which hands out pods; this one hands out cores, and it is a pod itself.
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

#panelb("3 · Put the Spark image into the cluster's image store · step 2")[
  #text(size: 8.5pt)[
    µLab 1 showed that the cluster keeps its own images. That was a demonstration; here
    it is the obstacle. The Spark image is on your laptop and the cluster cannot see it,
    so the pods in step 3 would never start. Left to itself the cluster would download
    its own copy, 535 MB from Docker Hub, sixteen times over one classroom connection.
    Handing it the copy you already have takes well under a minute and no network at all.
  ]
  #v(3pt)
  #step("2", "Check the image is on the laptop, then hand it to the cluster.")[
    Both lines are typed on your laptop, not in the #raw("kubectl") shell.
  ]
  #v(2pt)
  #raw("docker image ls spark:3.5.4-python3", lang: "console")
  #v(2pt)
  #text(size: 8pt)[One row means the image is on this laptop:]
  #v(2pt)
  #raw("REPOSITORY   TAG             IMAGE ID       CREATED         SIZE
spark        3.5.4-python3   5908cada5243   21 months ago   982MB", block: true)
  #v(2pt)
  #text(size: 8pt)[
    No rows at all means the pull in the announcement was missed. Run
    #raw("docker pull spark:3.5.4-python3") now, and say so out loud: it is 535 MB, and
    the Lab Master needs to know which machines are downloading.
  ]
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[Now copy it across.]
  #v(2pt)
  #raw("docker save spark:3.5.4-python3 | docker exec -i k8s ctr -n k8s.io images import -", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("docker save"),
    text(size: 7.8pt)[Write an image out as a plain stream of bytes. With no #raw("-o") file it goes to standard output.],
    raw("spark:3.5.4-python3"),
    text(size: 7.8pt)[Which image to write. NAME then #raw(":") then TAG, the same spelling as everywhere else.],
    raw("|"),
    text(size: 7.8pt)[Ordinary shell, nothing to do with Docker: send the left command's output straight into the right command's input, without ever writing a 1 GB file to disk.],
    raw("docker exec -i k8s"),
    text(size: 7.8pt)[Run a command *inside* the already-running #raw("k8s") container. #raw("-i") keeps its input open, which is what the pipe needs; there is no #raw("-t") because nothing here is typed by hand.],
    raw("ctr"),
    text(size: 7.8pt)[The cluster's own low-level image tool, and the reason this has to be run in there: #raw("ctr") exists only inside that container.],
    raw("-n k8s.io"),
    text(size: 7.8pt)[Which namespace of the store to write into. Kubernetes reads only #raw("k8s.io"), and an image imported anywhere else is invisible to it, so the pods still will not start.],
    raw("images import"),
    text(size: 7.8pt)[Read an image stream and add it to the store.],
    raw("-"),
    text(size: 7.8pt)[Read from standard input rather than from a file. This is the other end of the pipe.],
  )
  #v(4pt)
  #text(size: 8pt)[
    It prints one line per layer and then a total. Time it: on the teaching machine it
    took *37 seconds*, and a laptop will be slower. Then check the cluster's own list.
  ]
  #v(2pt)
  #raw("docker exec k8s crictl images", lang: "console")
  #v(2pt)
  #raw("IMAGE                                        TAG                 IMAGE ID            SIZE
docker.io/library/spark                      3.5.4-python3       5908cada5243a       995MB", block: true)
  #v(3pt)
  #text(size: 8pt)[
    Write down the #raw("IMAGE ID") from each of the two listings. They are the same
    image and they say so, which is exactly why the two stores are easy to confuse.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[laptop ID], rule(100%),
    text(size: 8pt)[cluster ID], rule(100%),
    text(size: 8pt)[seconds the import took], rule(100%),
    text(size: 8pt)[cluster SIZE], rule(100%),
  )
]

#panelb("4 · Start the master and two workers · step 3")[
  #text(size: 8.5pt)[
    Spark's own cluster is a master that hands out cores and workers that supply them.
    Both are ordinary programs, so on Kubernetes both are ordinary Deployments, and the
    file below asks for exactly that. Nothing in it is new except the Service.
  ]
  #v(3pt)
  #step("3", "Apply the file, then watch the pods appear.")[
    Typed in the #raw("kubectl") shell from step 1, where the folder is mounted at
    #raw("/lab"). With #raw("kubectl") installed on your laptop instead, drop the
    #raw("/lab/") and run it from the repository folder.
  ]
  #v(2pt)
  #raw("kubectl apply -f /lab/spark-standalone.yaml\nkubectl get pods", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("apply"),
    text(size: 7.8pt)[Make the cluster match what the file describes: create what is missing, change what differs, leave the rest. Running it twice is harmless.],
    raw("-f /lab/spark-standalone.yaml"),
    text(size: 7.8pt)[Read the description from this file. #raw("-f") is for #emph[file]. The path is the one *inside the client container*, not on your laptop.],
  )
  #v(3pt)
  #text(size: 8pt)[Three objects are created, and it says so:]
  #v(2pt)
  #raw("service/spark-master created
deployment.apps/spark-master created
deployment.apps/spark-worker created", block: true)
  #v(4pt)
  #text(size: 8.5pt, weight: "bold")[What the file asks for, in three parts.]
  #v(2pt)
  #raw("kind: Service          name: spark-master
  clusterIP: None                      # resolve the name to the pod itself
  selector: { app: spark-master }      # whichever pod carries this label
  ports: 7077 (submit), 8080 (web)

kind: Deployment       name: spark-master     replicas: 1
  image: spark:3.5.4-python3
  imagePullPolicy: IfNotPresent        # use the store, never download
  command: spark-class org.apache.spark.deploy.master.Master --host spark-master
  volumeMounts: /lab  (hostPath /lab, read-only)

kind: Deployment       name: spark-worker     replicas: 2
  command: spark-class org.apache.spark.deploy.worker.Worker \\
             spark://spark-master:7077 --cores 1 --memory 1g
  volumeMounts: /lab  (hostPath /lab, read-only)", block: true)
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("clusterIP: None"),
    text(size: 7.8pt)[Do not give the Service an address of its own; make the name answer with the pod's address. The master has to bind to the address its own name gives, and it cannot bind to a Service's.],
    raw("selector"),
    text(size: 7.8pt)[The label a pod must carry to be behind this Service. Not a pod name: that is the whole point, since pod names change.],
    raw("imagePullPolicy: IfNotPresent"),
    text(size: 7.8pt)[Use the store if the image is there, and only download if it is not. Without step 2 this is what would trigger the 535 MB download.],
    raw("--host spark-master"),
    text(size: 7.8pt)[Tells the master which name to publish itself under. It must match what the workers dial, or they connect and are then told to go somewhere they cannot reach.],
    raw("--cores 1 --memory 1g"),
    text(size: 7.8pt)[What one worker offers. Deliberately small, so the arithmetic is legible: the cluster has as many cores as it has worker pods.],
    raw("hostPath /lab"),
    text(size: 7.8pt)[Give the pod the folder the cluster container sees at #raw("/lab"), which step 1 attached. Both Deployments get it: in µLab 3 the master runs the driver, which reads the script, and the workers run the executors, which read the corpus.],
  )
  #v(4pt)
  #text(size: 8pt)[
    Run #raw("kubectl get pods") until all three read #raw("1/1 Running"). It took about
    twelve seconds on the teaching machine. Write down the three names.
  ]
  #v(2pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[master pod], rule(100%),
    text(size: 8pt)[READY], rule(24mm),
    text(size: 8pt)[worker pod], rule(100%),
    text(size: 8pt)[READY], rule(24mm),
    text(size: 8pt)[worker pod], rule(100%),
    text(size: 8pt)[READY], rule(24mm),
  )
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
INFO Master: Registering worker 10.42.0.5:33537 with 1 cores, 1024.0 MiB RAM
INFO Master: Registering worker 10.42.0.7:42663 with 1 cores, 1024.0 MiB RAM", block: true)
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
  Solved means panels 1 to 5 are done: the cluster re-created with the lab folder
  attached, the Spark image listed by #raw("crictl images"), master and two workers all
  reading #raw("1/1 Running"), and the master's log naming both workers with the cores
  each one offered.
]
#v(4pt)

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
  #raw("kubectl exec deploy/spark-master -- /opt/spark/bin/spark-submit \\\n  --master spark://spark-master:7077 \\\n  --class org.apache.spark.examples.SparkPi \\\n  local:///opt/spark/examples/jars/spark-examples_2.12-3.5.4.jar 100", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("exec"),
    text(size: 7.8pt)[Run a command inside a container that is already running, the same idea as #raw("docker exec") in step 2, one level in.],
    raw("--"),
    text(size: 7.8pt)[End of #raw("kubectl")'s own arguments. Everything after it belongs to the command being run, so #raw("--master") is read by Spark and not by #raw("kubectl").],
    raw("spark-submit"),
    text(size: 7.8pt)[Spark's launcher: start a driver, ask a master for cores, run the code, print the result, exit.],
    raw("--master spark://…:7077"),
    text(size: 7.8pt)[Which master to ask. The Service name from panel 2 and port 7077, which is the one the file labelled #emph[submit].],
    raw("--class org.apache…SparkPi"),
    text(size: 7.8pt)[Which program inside the jar to run. A jar holds many; this names one.],
    raw("local:///opt/spark/…jar"),
    text(size: 7.8pt)[Where the jar is. #raw("local:") means #emph[already present in the image on every machine], so Spark ships nothing. The third slash is the root of that filesystem.],
    raw("100"),
    text(size: 7.8pt)[The program's own argument: how many slices to split the darts into. More slices, more pieces of work, and a more precise answer.],
  )
  #v(4pt)
  #text(size: 8pt)[
    Several hundred lines scroll past and one line matters. On the teaching machine the
    whole thing took *7 seconds*:
  ]
  #v(2pt)
  #raw("Pi is roughly 3.1411035141103514", block: true)
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
    Write down the new pod's name and the new address in the master's log. Then say
    which of the two put the worker back, the Kubernetes controller or the Spark master,
    and what the other one did instead. Panel 2 defines what each keeps track of, and
    the three lines above are in the order the two of them acted.
  ]
  #writing(2)
]

#v(6pt)

#panel("8 · Extra mile · give the cluster more workers than the laptop has cores")[
  #text(size: 8.5pt)[
    Each worker was told #raw("--cores 1") in step 3, so the cluster's core count is its
    worker count. Nothing stops you asking for more workers than the laptop has cores.
    Predict what the master will report before you run it, then find out.
  ]
  #v(2pt)
  #raw("kubectl scale deployment spark-worker --replicas=8\nkubectl get pods\nkubectl logs deploy/spark-master | grep -c \"Registering worker\"", lang: "console")
  #v(3pt)
  #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
    raw("scale … --replicas=8"),
    text(size: 7.8pt)[Edit one field of a Deployment that already exists. It creates nothing and starts nothing by hand.],
    raw("grep -c"),
    text(size: 7.8pt)[Count matching lines instead of printing them. Note it counts *every* registration since the master started, including the ones from step 4 and panel 7.],
  )
  #v(3pt)
  #grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 6pt, row-gutter: 7pt, align: bottom,
    text(size: 8pt)[cores you predicted], rule(100%),
    text(size: 8pt)[cores reported], rule(100%),
    text(size: 8pt)[cores the laptop has], rule(100%),
    text(size: 8pt)[pods Running], rule(100%),
  )
  #v(3pt)
  #text(size: 8pt)[
    Then run panel 6 again and time it. Eight workers of one core each is eight cores as
    far as the master is concerned. Say whether the laptop agrees, and what the master
    would have to be told in order to find out.
  ]
  #writing(2)
]

#v(8pt)

#panel("9 · Annex · why the driver has to run somewhere that has a name")[
  #text(size: 8pt)[
    Panel 6 submitted the job from inside the master pod. Submitting from a pod of your own
    looks tidier and does not work. Executors are told to call the driver back by name,
    and cluster DNS answers only for pods that are behind a Service. A pod started on its
    own has no name anyone can resolve, so every executor exits immediately and the
    driver waits for cores that never arrive, printing this every fifteen seconds:
  ]
  #v(2pt)
  #raw("WARN TaskSchedulerImpl: Initial job has not accepted any resources; check your
cluster UI to ensure that workers are registered and have sufficient resources", block: true)
  #v(2pt)
  #text(size: 8pt)[
    The message blames the workers, and the workers are fine. The master pod already has
    a Service in front of it, which is the whole reason panel 6 borrows it.
  ]
  #v(3pt)
  #text(size: 8pt)[
    *What production does instead.* Standalone mode is Spark scheduling for itself, from
    before Kubernetes existed. Given a real cluster, a submission made with
    #raw("--master k8s://…") skips all of this: Kubernetes is asked directly for a driver
    pod and executor pods, they exist only while the job runs, and there is no master, no
    workers and nothing standing idle in between. It is also several more things to get
    right, which is why it is here and not in step 3.
  ]
]

#v(8pt)
#align(center)[
  #text(size: 8pt, fill: luma(130), style: "italic")[
    Done when the referee can say, without reading this sheet, why the cluster could not
    start the Spark image until it was handed a copy, and what a Service is for.
  ]
]
