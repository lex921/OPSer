image=$1
echo $1
img=`echo $image | sed 's/k8s\.gcr\.io/anjia0532\/google-containers/g;s/gcr\.io/anjia0532/g;s/\//\./g;s/ /\n/g;s/_/-/g;s/anjia0532\./anjia0532\//g' | uniq | awk '{print ""$1""}'`
echo "docker pull $img"
docker pull $img
echo  "docker tag $img $image"
docker tag $img $image
