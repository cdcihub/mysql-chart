ENVIRONMENT=staging-1-3

function create-secrets(){
    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace $ENVIRONMENT mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

    mkdir -pv private

    rm -fv ./private/url.txt

    umask 0277


    echo -n "mysql+pool://dqueue:$(cat private/dqueue-password.txt)@mysql/dqueue?max_connections=42&stale_timeout=8001.2" > ./private/url.txt

    kubectl delete secret -n ${ENVIRONMENT} dqueue-database-url
    kubectl --namespace $ENVIRONMENT create secret generic dqueue-database-url  --from-file=./private/url.txt
}

function install() {
    helm install --namespace $ENVIRONMENT mysql stable/mysql --set persistence.storageClass=nfs-client
   # helm install --namespace $ENVIRONMENT oda-mysql stable/mysql --set persistence.storageClass=cdcicn-nfs
}

function create-user(){
    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace $ENVIRONMENT mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

    MYSQL_HOST=127.0.0.1
    MYSQL_PORT=3307

    # Execute the following command to route the connection:
    kubectl port-forward svc/mysql ${MYSQL_PORT}:3306 -n staging-1-3 &
    proxy=$!

    sleep 1

    mysql --protocol=tcp -h ${MYSQL_HOST} -P${MYSQL_PORT} -u root -p${MYSQL_ROOT_PASSWORD} < create-user.sql

    kill -9 $proxy
}

function dqueue-longtext(){
    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace $ENVIRONMENT mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

    MYSQL_HOST=127.0.0.1
    MYSQL_PORT=3307

    # Execute the following command to route the connection:
    kubectl port-forward svc/mysql ${MYSQL_PORT}:3306 -n staging-1-3 &
    proxy=$!

    sleep 1

    mysql --protocol=tcp -h ${MYSQL_HOST} -P${MYSQL_PORT} -u root -p${MYSQL_ROOT_PASSWORD} < dqueue-longtext.sql

    kill -9 $proxy
}

$@
