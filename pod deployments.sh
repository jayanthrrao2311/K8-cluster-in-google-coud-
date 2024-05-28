  
Redis-deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redislabs/redismod
        ports:
        - containerPort: 6379
        volumeMounts:
        - mountPath: /data
          name: redis-storage
      volumes:
      - name: redis-storage
        persistentVolumeClaim:
          claimName: redis-pvc

---
apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  selector:
    app: redis
  ports:
    - protocol: TCP
      port: 6379
      targetPort: 6379


      locust-deployment1.yaml 

                                                                               
apiVersion: apps/v1
kind: Deployment
metadata:
  name: locust
spec:
  replicas: 1
  selector:
    matchLabels:
      app: locust
  template:
    metadata:
      labels:
        app: locust
    spec:
      containers:
      - name: locust
        image: 23jayanth/locust:2.18.4
        args: ["-f","/mnt/locust/redis_get_set.py"]
        ports:
        - containerPort: 8089
        volumeMounts:
        - name: locust-scripts
          mountPath: /mnt/locust
      volumes:
      - name: locust-scripts
        configMap:
          name: locustfile-config10
---
apiVersion: v1
kind: Service
metadata:
  name: locust
spec:
  type: NodePort
  ports:
  - port: 8089
    targetPort: 8089
    nodePort: 30001
  selector:
    app: locust

Create Persistent Volume
Create a file redis-pv.yaml with the following content:

apiVersion: v1
kind: PersistentVolume
metadata:
  name: redis-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"

Create Persistent Volume Claim
Create a file redis-pvc.yaml with the following content:  

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

kubectl apply -f redis-pv.yaml
kubectl apply -f redis-pvc.yaml

creating configmap from the directory 
kubectl create configmap locustfile-config --from-file=locustfiles/

kubectl apply -f locust-deployment.yaml

i have updated the locust- docker image and saved it in my locust directory . this was used for load testing of redis

////steps :

//create a Dockerfile

FROM locustio/locust

# Install redis package
RUN pip install redis

# Copy your Locust test scripts
COPY ./locust /mnt/locust

# Set the working directory
WORKDIR /mnt/locust

# Command to run Locust
CMD ["locust", "-f", "/mnt/locust/redis_get_set.py"]

// rebuild docker image

sudo docker build -t your-registry/locust:latest .

// push docker image to my registory/repository 

sudo docker push your-registry/locust:latest

//update the kubernetes deployment

kubectl set image deployment/locust locust=your-registry/locust:latest

both  pods are running (redis, locust)


cd load( directory which contains locust scripts)

sudo nano redis_orig.json

// for redis host :  POD IP address  

