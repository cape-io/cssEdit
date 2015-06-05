# cssEdit

## Install
1. `cd ~/Sites/layouts`
1. `git clone git@github.com:cape-io/cssEdit.git`
2. `npm install`

## Configure
1. `cd cssEdit`
1. `open sites.yaml`
The sites.yaml file is just an object where each root key is a site id with two properties.
  * `url` is the remote url to proxy.
  * `layout` is the directory name of the local layout to use. If the local layout files are not found it will use the ones on the remote server.
  * `repo` will redirect to that url when visiting /repo 

## Run

1. `gulp --site bk`
1. Edit files in your layouts folder and they should be injected after each change is compiled.
