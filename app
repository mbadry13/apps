from fastapi import FastAPI
from kubernetes import client, config

app = FastAPI()

# Load Kubernetes/OpenShift config (Works inside OpenShift pod)
config.load_kube_config()

def get_k8s_client():
    return client.CoreV1Api()

@app.get("/cluster/nodes")
def get_nodes():
    v1 = get_k8s_client()
    nodes = v1.list_node()
    return [{"name": node.metadata.name, "status": node.status.conditions[-1].type} for node in nodes]

@app.get("/cluster/pods")
def get_pods():
    v1 = get_k8s_client()
    pods = v1.list_pod_for_all_namespaces()
    return [{"name": pod.metadata.name, "namespace": pod.metadata.namespace, "status": pod.status.phase} for pod in pods]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
