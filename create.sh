#will create swift container
#source
cd ~/db/swift
rm -rf docker-swift-onlyone

docker stop blob-storage
docker rm blob-storage
echo

docker rm swift_data
docker rmi blob-store
echo

# Pull the latest code from GIT
git clone https://github.com/tburnett80/docker-swift-onlyone.git

cd docker-swift-onlyone
echo

git reset --hard HEAD
git clean -f
git pull
echo

#get rid of extraneous files
rm -rf .git
rm -rf .gitignore
rm -rf LICENSE
rm -rf README.md
echo

#build image
docker build -t blob-store .
echo

#cleanup
cd ~/db/swift
rm -rf docker-swift-onlyone
echo

# build data only container
docker run -d --name swift_data -v /srv blob-store
echo
sleep 3s

docker stop swift_data
sleep 2s

docker run -d -p 8081:8080 --volumes-from swift_data --name blob-storage blob-store
echo
sleep 5s

docker ps
echo
sleep 5s

#set create container, set read only user
shopt -s extglob # Required to trim whitespace; see below

while IFS=':' read key value; do
    # trim whitespace in "value"
    value=${value##+([[:space:]])}; value=${value%%+([[:space:]])}

    case "$key" in
        X-Auth-Token) Auth="$value"
                ;;
        HTTP*) read PROTO STATUS MSG <<< "$key{$value:+:$value}"
                ;;
     esac
done < <(curl -i -H "X-Auth-User: test:tester" -H "X-Auth-Key: testing" http://localhost:8081/auth/v1.0)
#echo $STATUS

curl -i -XPUT -H "X-Auth-Token: $Auth" http://localhost:8081/v1/AUTH_test/blog_images

curl -i -XPOST -H "X-Auth-Token: $Auth" -H "X-Container-Read: .r:*" http://localhost:8081/v1/AUTH_test/blog_images
echo
                   