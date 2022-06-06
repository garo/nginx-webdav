# nginx-webdav
Docker image to run webdav server using nginx

Usage:

- The image expects root directory to be mounted under `/media/root`
- The authentication is done using a standard Apache htpasswd which is expected to be found under `/config/webdavpasswd`

You can create the webdavpasswd using htpasswd: `htpasswd -cb webdavpasswd USERNAME PASSWORD`

Example Kubernetes manifest:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-webdav
  namespace: default
  labels:
    app: nginx-webdav
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-webdav
  template:
    metadata:
      labels:
        app: nginx-webdav
    spec:
      securityContext:
        runAsUser: 65534
        runAsGroup: 65534
      volumes:
        - name: data
          nfs:
            server: nfs.foobar.com
            path: /
        - name: tmp
          emptyDir: {}
        - name: webdavpasswd
          secret:
            secretName: webdavpasswd
      containers:
        - name: nginx
          image: garo5/nginx-webdav
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          env:
          volumeMounts:
          - name: data
            mountPath: /media
          - name: tmp
            mountPath: /tmp
          - name: tmp
            mountPath: /var/log/nginx
          - name: webdavpasswd
            mountPath: "/config"
            readOnly: true
          resources:
            limits:
              memory: 128Mi
            requests:
              memory: 64Mi
              cpu: "0.1"
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
              - ALL
            readOnlyRootFilesystem: false
          imagePullPolicy:  IfNotPresent
      restartPolicy: Always

---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: webdavpasswd
  namespace: default
data: # created with htpasswd -cb webdavpasswd USERNAME PASSWORD and then base64 encoding it
  webdavpasswd: REPLACE_ME
---
```
