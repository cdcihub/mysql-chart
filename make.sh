

function create-secrets(){
    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace staging-1-3 staging-1-3-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

    mkdir -pv private

    umask 0277

    (kubectl get secret --namespace staging-1-3 staging-1-3-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo) > private/password.txt
    kubectl --namespace staging-1-3 create secret generic db-user-pass  --from-file=./private/password.txt
}


function install() {
    helm install --namespace staging-1-3 --name staging-1-3-mysql stable/mysql --set persistence.storageClass=cdcicn-nfs
}

$@
