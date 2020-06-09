# Kubernetes GPU as an app in the Giant Swarm Playground Catalog

**What is it?**
It is a recipe to install the GPU drivers into our nodes to let customers run GPU workloads.

**Why did we add it?**
So far, customers have needed to run it by themselves. We've had to sync all time every time there is a change. Now we can provide a new release when a new driver version is out (and tested) and they can easily install it.

**Who can use it?**
Our customers on AWS that need to run GPU apps.

**How to use it?**
Install the app via App Platform by selecting the version of the driver desired (CUDA version of your apps).

This repository's content is available in two forms:

- Embedded into the Recipes section in https://docs.giantswarm.io/guides/
- As raw content in the `docs/` folder.
