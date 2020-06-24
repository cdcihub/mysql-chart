ENVIRONMENT=staging-1-3

function create-secrets(){
    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace $ENVIRONMENT $ENVIRONMENT-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

    mkdir -pv private

    rm -fv ./private/url.txt

    umask 0277


    echo -n "mysql+pool://dqueue:$(cat private/dqueue-password.txt)@mysql/dqueue?max_connections=42&stale_timeout=8001.2" > ./private/url.txt

    kubectl delete secret -n ${ENVIRONMENT} dqueue-database-url
    kubectl --namespace $ENVIRONMENT create secret generic dqueue-database-url  --from-file=./private/url.txt
}

function install() {
    helm3 install --namespace $ENVIRONMENT mysql stable/mysql --set persistence.storageClass=cdcicn-nfs
}

$@
