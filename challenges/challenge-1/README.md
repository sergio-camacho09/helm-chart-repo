# Helm chart template 
## Challenge 1

In order to resolve this challenge, we will use [killercoda](https://killercoda.com/playgrounds/course/kubernetes-playgrounds/two-node) website as kubernetes lab. The selected one will be the playgroud with two nodes (2GB+2GB).

When we can see the kubernetes terminal, we will execute the following commands in order to test that challenge:

```sh
git clone https://github.com/sergio-camacho09/helm-chart-repo.git
cd helm-chart-repo && ./scripts/install-challenge-1.sh
```

With this commands we will clone a repository than contains the technical test and then we will execute a script that will prepare the environment.
The script creates a new namespace to install our applications. Then, it obtains all cluster nodes and assign them labels that will be use for the challenge (the helm chart template will be responsible for this). Also, the script will install the necessary helm chart template to complete the challenge.

## Key Features

### 1. **Node Isolation**

The chart uses `nodeSelector` and `affinity` to control scheduling but also `tolerations` and `taints` are a good option to isolate nodes.

#### Configuration in `values.yaml` and `_helpers.tpl`:

```yaml
nodeSelector:
  kubernetes.io/test: node2
```
- **`nodeSelector`**: Ensures pods are not shceduled on nodes with `kubernetes.io/test=node1`.

```yaml
{{- define "ping.podAffinity" -}}
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app.kubernetes.io/name
          operator: In
          values:
          - {{ include "ping.name" . }}
      topologyKey: kubernetes.io/hostname
{{- end }}
```
- **`podAntiAffinity`**: Prevents multiple pods of the same type from being scheduled on the same node.

### 2. **Availability Zone Distributions**

By using `topologyKey` and `topologySpreadConstraints`, pods are distributed across availability zones:

```yaml
{{- define "ping.podZoneDistribution" -}}
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: {{ include "ping.name" . }}
{{- end }}
```

### 3. **Init Container**

The `initContainers` ensures a dependent service is running before the main container starts:

```yaml
{{- define "ping.waitUntilServiceUp" -}}
initContainers:
  - name: wait-for-service
    image: curlimages/curl:7.85.0
    args:
      - "-f"
      - "http://{{ .Values.dependentService.url }}"
    resources:
      requests:
        cpu: 10m
        memory: 10Mi
{{- end }}
```

## Feature Enhancements

- Add more granular affinity rules for complex workloads.
- Integrate dynamic configuration for multi-environment support.
- Implement health checks for better validation of dependent services.

---

This Helm chart provides a robust solution for deploying Kubernetes workloads with strict scheduling and dependency requirements.
