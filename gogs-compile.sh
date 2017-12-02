#!/bin/tcsh
# Gogs compile script for FreeNAS
echo "Fetching gogs from Github"
su - git -c "setenv GOPATH /usr/home/git/go; go get -u github.com/gogits/gogs"
echo "Patch ssh_key.go to allow local forwards to http port"
sed -i -e 's/no-port-forwarding/permitopen="127.0.0.1:%s"/g' /home/git/go/src/github.com/gogits/gogs/models/ssh_key.go
sed -i -e 's/\(fmt.Sprintf(_TPL_PUBLICK_KEY, setting.AppPath, k.ID, setting.CustomConf, \)\(k.Content)\)/\1setting.HTTPPort, \2/g' /home/git/go/src/github.com/gogits/gogs/models/ssh_key.go
echo "Getting gogs compile tags"
su - git -c "setenv GOPATH /usr/home/git/go; cd /home/git/go/src/github.com/gogits/gogs; go get -u -tags 'sqlite redis memcache cert' github.com/gogits/gogs"
echo "Compiling gogs"
su - git -c "setenv GOPATH /usr/home/git/go; cd /home/git/go/src/github.com/gogits/gogs; go build -tags 'sqlite redis memcache cert'"
echo "Copying gogs build to git home"
su - git -c "cp -R /usr/home/git/go/src/github.com/gogits/gogs /home/git/"
# Change ownership of everything in the git directory
chown -R git:git /usr/home/git/
echo "Copying startup script to rc.d, enabling & starting gogs"
#/usr/bin/sed 's/\/home\/git/\/home\/git\/gogs/g' /home/git/go/src/github.com/gogits/gogs/scripts/init/freebsd/gogs
cp /home/git/go/src/github.com/gogits/gogs/scripts/init/freebsd/gogs /usr/local/etc/rc.d/
sed -i -e 's/\/home\/git/\/home\/git\/gogs/g' /usr/local/etc/rc.d/gogs
chmod +x /usr/local/etc/rc.d/gogs
