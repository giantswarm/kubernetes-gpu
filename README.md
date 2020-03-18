
# GPU device installation for Kubernetes and CoreOS

In order to have GPU instances running CoreOS we need to follow these steps to install and configure the right libraries and drivers on the host machine.

## Install the Nvidia GPU drivers on the CoreOS instances

The idea here it is run a pod in every worker node to download, compile and install the Nvidia drivers on CoreOS. It is a copy from [Shelman Group](https://github.com/shelmangroup/coreos-gpu-installer) but adding the pod security policy needed to work in hardened clusters.

```bash
$ kubectl apply -f https://raw.githubusercontent.com/giantswarm/kubernetes-gpu/master/manifests/drivers.yaml
```

It will create a daemon set which will run a bunch of different commands by node. At the end, it will display a succesful message in case there was not trouble found.

```bash
$ kubectl logs -f $(kubectl get pod -l app="nvidia-driver-installer" --no-headers | head -n 1 | awk '{print $1}') -c nvidia-driver-installer
... 
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 396.26                 Driver Version: 396.26                    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla V100-SXM2...  Off  | 00000000:00:1E.0 Off |                    0 |
| N/A   47C    P0    43W / 300W |      0MiB / 16160MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
Finished installing the drivers.
Updating host's ld cache
```

## Installing the device plugin

Instead of the official nvidia device plugin, which requires a custom docker runtime, we choose to use Google's approach. In short, this device plugin expects that all the nvidia libraries needed by the containers are present under a single directory on the host (`/opt/nvidia`). 

```bash
$ kubectl apply -f https://raw.githubusercontent.com/giantswarm/kubernetes-gpu/master/manifests/device-plugin-ds.yaml
```

Same as before we deploy a daemon set in the cluster which will mount the `/dev` host path and the `/var/lib/kubelet/device-plugin` path to make available the GPU device to pods that request it. Pointing out the we passed a flag to the container to indicate where the nvidia libraries and binaries has been installed in our host.

```bash
$ kubectl logs -f $(kubectl get pod -l k8s-app="nvidia-gpu-device-plugin" --no-headers | head -n 1 | awk '{print $1}')
```

When everything has gone as expected you should see some logs like
```
device-plugin started
Found Nvidia GPU "nvidia0"
will use alpha API
starting device-plugin server at: /device-plugin/nvidiaGPU-1544782516.sock
device-plugin server started serving
falling back to v1beta1 API
device-plugin registered with the kubelet
device-plugin: ListAndWatch start
ListAndWatch: send devices &ListAndWatchResponse{Devices:[&Device{ID:nvidia0,Health:Healthy,}],}
```

# Verification

To run a test we are going to use a [cuda vecadd example](https://github.com/giantswarm/kubernetes-gpu/blob/master/demo-pod/vecadd.cu). It performs a simple vector addition using the device plugin installed before.

```bash
$ kubectl apply -f https://raw.githubusercontent.com/giantswarm/kubernetes-gpu/master/manifests/test-pod.yaml
```

If we inspect the logs, we should be able to see something like

```bash
$ kubectl  logs -f cuda-vector-add
Begin
Allocating device memory on host..
Copying to device..
Doing GPU Vector add
Doing CPU Vector add
10000000 0.000007 0.046845
```

Now you have installed successfully all needed to run GPU workloads over your Kubernetes cluster.
