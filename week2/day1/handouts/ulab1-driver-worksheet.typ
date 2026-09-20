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
#panel("1 · Start the cluster · steps 1 and 2")[
  #step("1", "Create a container that is a Kubernetes cluster")[
    #raw("docker run -d --name k8s --privileged --tmpfs /run --tmpfs /var/run \\\n  -p 6443:6443 rancher/k3s:v1.31.5-k3s1 server --disable=traefik", lang: "console")
    #v(3pt)
    #grid(columns: (auto, 1fr), column-gutter: 7pt, row-gutter: 3.5pt, align: (top, top),
      raw("-d"),
      text(size: 7.8pt)[Detached. It runs in the background and you get your prompt back.],
      raw("--name k8s"),
      text(size: 7.8pt)[A name of your choosing. Without it, Docker still identifies the container,
        but by its id: \
        #raw("8d7726f96f7475544440565a92a034cda1f767726619081595bab18cfdf76987") \
        Every later command would have to carry that, or its short form #raw("8d7726f96f74").
        #raw("k8s") is easier to type and easier to get right.],
      raw("--privileged"),
      text(size: 7.8pt)[Lifts the usual restrictions. k3s mounts cgroups and runs *its own* container runtime inside this container.],
      raw("--tmpfs /run"),
      text(size: 7.8pt)[Two small writable in-memory filesystems that k3s needs (also #raw("/var/run")).],
      raw("-p 6443:6443"),
      text(size: 7.8pt)[*HOST:CONTAINER.* Port 6443 #emph[on your laptop] is forwarded to port 6443 #emph[inside the container]. The left one is yours, the right one is the container's. 6443 is where the Kubernetes API server listens.],
      raw("rancher/k3s:v1.31.5-k3s1"),
      text(size: 7.8pt)[The image. #raw("rancher/k3s") is the repository, #raw("v1.31.5-k3s1") is the tag. You named no registry, so Docker went to *Docker Hub* and fetched it from there.],
      raw("server"),
      text(size: 7.8pt)[*Not a docker flag.* Everything after the image name is the command handed to the program inside. #raw("server") tells k3s to be the control plane.],
      raw("--disable=traefik"),
      text(size: 7.8pt)[Also k3s's, not docker's. Traefik is an *ingress controller*: it routes HTTP arriving from outside to services inside. It claims ports 80 and 443 and adds startup time, and nothing today arrives from outside.],
    )
  ]
  #v(5pt)
  #step("2", "Step inside the container you just made")[
    #raw("docker exec -it k8s sh", lang: "console")
    #v(2pt)
    #text(size: 8pt)[
      #raw("-i") keeps the input open, #raw("-t") gives you a terminal. Together they get you an
      *interactive shell running inside that container* — not on your laptop. Your
      prompt changes; that is the sign.
    ]
    #v(3pt)
    #text(size: 8pt)[
      Prove it before you go on. Type #raw("hostname") and write down what it says:
      #box(width: 40mm, stroke: (bottom: 0.5pt + luma(120)), height: 9pt)
    ]
    #v(2pt)
    #text(size: 7.8pt, fill: luma(120))[
      Keep that value. It comes back in panel 3, and it is not a coincidence.
      #raw("exit") leaves the shell; the container keeps running without you.
    ]
    #v(4pt)
    #block(width: 100%, inset: (x: 6pt, y: 5pt), radius: 2pt,
           stroke: 1pt + accent, fill: rgb("#fff0f6"))[
      #text(size: 8.5pt, weight: "bold")[Do not close this shell.]
      #v(1pt)
      #text(size: 8pt)[
        Steps 3 to 6 and every #raw("kubectl") in panels 5 to 9 are typed *here*, at this
        prompt. If you type them on your laptop instead, you will get
        #raw("kubectl: command not found") — the cluster's tools live in the container,
        not on your machine.
      ]
      #v(2pt)
      #text(size: 8pt)[
        Closed it by accident? #raw("docker exec -it k8s sh") puts you straight back.
        Nothing is lost: the cluster never stopped.
      ]
    ]
  ]
]

#v(5pt)

#panel("2 · Drive the cluster · steps 3 to 6")[
  #text(size: 8.5pt, weight: "bold", fill: accent)[
    Type these at the shell from step 2, inside the container.
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
  #step("4", "Look at what the controller made")[
    #raw("kubectl get pods", lang: "console") — once straight away, once about a minute later.
    #v(1pt)
    #text(size: 8pt)[
      This lists the *pods* the Deployment created on your behalf. Two columns
      matter: *STATUS*, what the pod is doing right now, and *RESTARTS*, how many
      times the container inside it has been started again.
    ]
    #v(2pt)
    #text(size: 7.8pt, fill: luma(120))[
      Take the two readings *early*. Kubernetes waits longer before each retry —
      10s, 20s, 40s, and so on up to a five-minute cap — so an hour in, two readings
      a minute apart can show the same number and tell you nothing.
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

#panel("3 · What you started")[
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

#panel("4 · The two readings, and the reason")[
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
    Compare the NAME in panel 3 with the #raw("hostname") you wrote in step 2. \
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

#panel("5 · What the logs will tell you")[
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
#panel("6 · Now use the image you built on Friday")[
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

#panel("7 · The controller's own account")[
  #text(size: 8.5pt)[
    In panel 4 you read *Last State* from #raw("kubectl describe pod"). The same output ends
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

#panel("8 · Two image stores, one name")[
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

#panel("9 · A wish is not a command")[
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

#panel("10 · Extra mile · satisfy the Deployment instead of abandoning it")[
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
